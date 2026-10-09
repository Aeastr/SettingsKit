import SwiftUI

/// The built-in settings search with normalized relevance scoring.
///
/// Exact title matches rank above prefixes, substrings, and tag matches. Results with equal scores retain their declaration order. See <doc:IndexingAndSearch> for the indexing model.
public struct DefaultSettingsSearch: SettingsSearch {
    /// Creates the default settings search.
    public init() {}

    /// Searches and relevance-sorts a settings metadata hierarchy.
    ///
    /// - Parameters:
    ///   - nodes: The root metadata nodes to traverse.
    ///   - query: The text to match against titles and tags.
    /// - Returns: Deduplicated results ordered by relevance and declaration.
    public func search(nodes: [SettingsNode], query: String) -> [SettingsSearchResult] {
        var results: [SettingsSearchResult] = []
        var orderIndex = 0
        searchNodes(nodes, query: query.lowercased(), results: &results, orderIndex: &orderIndex)

        // Collapse matches under the same destination while preserving every
        // matched indexed control for custom result renderers.
        var seenIDs: [UUID: SettingsSearchResult] = [:]
        for result in results {
            let id = result.group.id
            let score = matchScore(for: result.group, query: query.lowercased())

            if let existing = seenIDs[id] {
                let existingScore = matchScore(for: existing.group, query: query.lowercased())
                let preferred = score > existingScore ? result : existing
                let matchedItems = (existing.matchedItems + result.matchedItems).reduce(into: [SettingsNode]()) { items, item in
                    guard !items.contains(where: { $0.id == item.id }) else { return }
                    items.append(item)
                }

                seenIDs[id] = SettingsSearchResult(
                    group: preferred.group,
                    matchedItems: matchedItems,
                    isNavigation: existing.isNavigation || result.isNavigation,
                    orderIndex: min(existing.orderIndex, result.orderIndex),
                    parentGroup: preferred.parentGroup ?? existing.parentGroup ?? result.parentGroup
                )
            } else {
                seenIDs[id] = result
            }
        }

        let uniqueResults = Array(seenIDs.values)

        // Sort results by match quality, then by original order, then alphabetically
        return uniqueResults.sorted { lhs, rhs in
            let lhsScore = matchScore(for: lhs.group, query: query.lowercased())
            let rhsScore = matchScore(for: rhs.group, query: query.lowercased())
            if lhsScore == rhsScore {
                // Same score: preserve original order
                if lhs.orderIndex == rhs.orderIndex {
                    // Same position (shouldn't happen): sort alphabetically
                    return lhs.group.title < rhs.group.title
                }
                return lhs.orderIndex < rhs.orderIndex
            }
            return lhsScore > rhsScore
        }
    }

    private func normalize(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "&", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
    }

    private func matchScore(for node: SettingsNode, query: String) -> Int {
        let title = node.title
        let normalizedTitle = normalize(title)
        let normalizedQuery = normalize(query)

        // Exact match (normalized)
        if normalizedTitle == normalizedQuery {
            return 1000
        }

        // Starts with (normalized)
        if normalizedTitle.hasPrefix(normalizedQuery) {
            return 500
        }

        // Starts with (original, case-insensitive)
        if title.lowercased().hasPrefix(query) {
            return 400
        }

        // Contains (normalized)
        if normalizedTitle.contains(normalizedQuery) {
            return 300
        }

        // Contains (original, case-insensitive)
        if title.lowercased().contains(query) {
            return 200
        }

        // Tag match
        if node.tags.contains(where: { normalize($0).contains(normalizedQuery) }) {
            return 100
        }

        return 0
    }

    private func searchNodes(
        _ nodes: [SettingsNode],
        query: String,
        results: inout [SettingsSearchResult],
        orderIndex: inout Int,
        navigationAncestors: [SettingsNode] = []
    ) {
        for node in nodes {
            guard node.isIncludedInSearch else { continue }
            let currentIndex = orderIndex
            orderIndex += 1

            switch node {
            case .group(_, let title, _, let tags, let presentation, let children, _):
                let normalizedQuery = normalize(query)
                let groupMatches = normalize(title).contains(normalizedQuery) ||
                                  tags.contains(where: { normalize($0).contains(normalizedQuery) })

                let isLeafGroup = !children.isEmpty && children.allSatisfy { !$0.isGroup }

                let navigationParent = navigationAncestors.last
                let ancestorsForChildren = presentation == .navigation
                    ? navigationAncestors + [node]
                    : navigationAncestors

                if isLeafGroup {
                    // Leaf group: check if group or any searchable children match
                    let searchableChildren = children.filter { $0.isSearchable }
                    let matchingChildren = searchableChildren.filter { child in
                        normalize(child.title).contains(normalizedQuery) ||
                        child.tags.contains(where: { normalize($0).contains(normalizedQuery) })
                    }
                    let childMatches = !matchingChildren.isEmpty

                    // Root inline groups remain directly renderable. Matches nested in
                    // navigation content resolve to their nearest destination while
                    // retaining the matching controls for custom result renderers.
                    if groupMatches || childMatches {
                        // A group-title match represents the whole group. A child-only
                        // match contains only the controls that actually matched.
                        let matchedItems = groupMatches ? searchableChildren : matchingChildren
                        let resultGroup: SettingsNode
                        let resultParent: SettingsNode?
                        let isNavigation: Bool

                        if presentation == .navigation {
                            resultGroup = node
                            resultParent = navigationParent
                            isNavigation = true
                        } else if let navigationParent {
                            resultGroup = navigationParent
                            resultParent = navigationAncestors.dropLast().last
                            isNavigation = true
                        } else {
                            resultGroup = node
                            resultParent = nil
                            isNavigation = false
                        }

                        results.append(SettingsSearchResult(
                            group: resultGroup,
                            matchedItems: matchedItems,
                            isNavigation: isNavigation,
                            orderIndex: currentIndex,
                            parentGroup: resultParent
                        ))
                    }
                } else {
                    // Mixed groups can contain controls alongside subpages. Those
                    // controls must not disappear merely because a sibling is a group.
                    let directItems = children.filter { !$0.isGroup && $0.isSearchable }
                    let matchingItems = groupMatches ? directItems : directItems.filter {
                        matchScore(for: $0, query: query) > 0
                    }
                    if !matchingItems.isEmpty {
                        let destination = presentation == .navigation ? node : (navigationParent ?? node)
                        results.append(SettingsSearchResult(
                            group: destination,
                            matchedItems: matchingItems,
                            isNavigation: presentation == .navigation || navigationParent != nil,
                            orderIndex: currentIndex,
                            parentGroup: presentation == .navigation
                                ? navigationParent : navigationAncestors.dropLast().last
                        ))
                    }
                    // Parent group
                    if groupMatches {
                        if presentation == .navigation {
                            // Navigation group that matches: add it as a navigation result
                            results.append(SettingsSearchResult(group: node, matchedItems: [], isNavigation: true, orderIndex: currentIndex, parentGroup: navigationParent))

                            // Add all immediate navigation children as separate results
                            for child in children where child.isIncludedInSearch {
                                let childIndex = orderIndex
                                orderIndex += 1

                                if case .group(_, _, _, _, let childPresentation, let grandchildren, _) = child {
                                    // Skip inline child groups
                                    guard childPresentation == .navigation else { continue }

                                    // Leaf child = has indexed items (not groups). Empty children = navigation group.
                                    let isLeafChild = !grandchildren.isEmpty && grandchildren.allSatisfy { !$0.isGroup }
                                    if isLeafChild {
                                        results.append(SettingsSearchResult(group: child, matchedItems: grandchildren.filter { $0.isSearchable }, isNavigation: false, orderIndex: childIndex, parentGroup: node))
                                    } else {
                                        results.append(SettingsSearchResult(group: child, matchedItems: [], isNavigation: true, orderIndex: childIndex, parentGroup: node))
                                    }
                                }
                            }
                        } else {
                            // Inline group that matches: add all its navigation children as results
                            for child in children where child.isIncludedInSearch {
                                let childIndex = orderIndex
                                orderIndex += 1

                                if case .group(_, _, _, _, let childPresentation, let grandchildren, _) = child {
                                    // Only add navigation child groups
                                    guard childPresentation == .navigation else { continue }

                                    // Leaf child = has indexed items (not groups). Empty children = navigation group.
                                    let isLeafChild = !grandchildren.isEmpty && grandchildren.allSatisfy { !$0.isGroup }
                                    if isLeafChild {
                                        results.append(SettingsSearchResult(group: child, matchedItems: grandchildren.filter { $0.isSearchable }, isNavigation: false, orderIndex: childIndex, parentGroup: navigationParent))
                                    } else {
                                        results.append(SettingsSearchResult(group: child, matchedItems: [], isNavigation: true, orderIndex: childIndex, parentGroup: navigationParent))
                                    }
                                }
                            }
                        }
                    }
                    // Always recurse into children to find deeper matches
                    searchNodes(
                        children,
                        query: query,
                        results: &results,
                        orderIndex: &orderIndex,
                        navigationAncestors: ancestorsForChildren
                    )
                }

            case .item:
                // Items should be handled by their parent group
                break
            }
        }
    }
}
