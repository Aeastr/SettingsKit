import SwiftUI

/// The default settings search implementation.
public struct DefaultSettingsSearch: SettingsSearch {
    public init() {}

    public func search(nodes: [SettingsNode], query: String) -> [SettingsSearchResult] {
        print("🔍 Search called with query: '\(query)', nodes count: \(nodes.count)")
        var results: [SettingsSearchResult] = []
        var orderIndex = 0
        searchNodes(nodes, query: query.lowercased(), results: &results, orderIndex: &orderIndex)
        print("🔍 Search found \(results.count) results")

        // Deduplicate by group ID (keep the one with higher score)
        var seenIDs: [UUID: SettingsSearchResult] = [:]
        for result in results {
            let id = result.group.id
            let score = matchScore(for: result.group, query: query.lowercased())

            if let existing = seenIDs[id] {
                let existingScore = matchScore(for: existing.group, query: query.lowercased())
                if score > existingScore {
                    seenIDs[id] = result
                }
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

    private func searchNodes(_ nodes: [SettingsNode], query: String, results: inout [SettingsSearchResult], orderIndex: inout Int) {
        for node in nodes {
            let currentIndex = orderIndex
            orderIndex += 1

            switch node {
            case .group(_, let title, _, let tags, let presentation, let children):
                let normalizedQuery = normalize(query)
                let groupMatches = normalize(title).contains(normalizedQuery) ||
                                  tags.contains(where: { normalize($0).contains(normalizedQuery) })

                let isLeafGroup = children.allSatisfy { !$0.isGroup }

                if groupMatches {
                    print("🔍 Group '\(title)' matches query '\(query)' - isLeaf: \(isLeafGroup), presentation: \(presentation)")
                }

                if isLeafGroup {
                    // Leaf group: check if group or any searchable children match
                    let searchableChildren = children.filter { $0.isSearchable }
                    let childMatches = searchableChildren.contains { child in
                        normalize(child.title).contains(normalizedQuery) ||
                        child.tags.contains(where: { normalize($0).contains(normalizedQuery) })
                    }

                    // Only add navigation groups as leaf results, skip inline groups
                    if presentation == .navigation && (groupMatches || childMatches) {
                        results.append(SettingsSearchResult(group: node, matchedItems: children, isNavigation: false, orderIndex: currentIndex))
                    }
                } else {
                    // Parent group
                    if groupMatches {
                        if presentation == .navigation {
                            // Navigation group that matches: add it as a navigation result
                            results.append(SettingsSearchResult(group: node, matchedItems: [], isNavigation: true, orderIndex: currentIndex))

                            // Add all immediate navigation children as separate results
                            for child in children {
                                let childIndex = orderIndex
                                orderIndex += 1

                                if case .group(_, _, _, _, let childPresentation, let grandchildren) = child {
                                    // Skip inline child groups
                                    guard childPresentation == .navigation else { continue }

                                    let isLeafChild = grandchildren.allSatisfy { !$0.isGroup }
                                    if isLeafChild {
                                        results.append(SettingsSearchResult(group: child, matchedItems: grandchildren, isNavigation: false, orderIndex: childIndex))
                                    } else {
                                        results.append(SettingsSearchResult(group: child, matchedItems: [], isNavigation: true, orderIndex: childIndex))
                                    }
                                }
                            }
                        } else {
                            // Inline group that matches: add all its navigation children as results
                            for child in children {
                                let childIndex = orderIndex
                                orderIndex += 1

                                if case .group(_, _, _, _, let childPresentation, let grandchildren) = child {
                                    // Only add navigation child groups
                                    guard childPresentation == .navigation else { continue }

                                    let isLeafChild = grandchildren.allSatisfy { !$0.isGroup }
                                    if isLeafChild {
                                        results.append(SettingsSearchResult(group: child, matchedItems: grandchildren, isNavigation: false, orderIndex: childIndex))
                                    } else {
                                        results.append(SettingsSearchResult(group: child, matchedItems: [], isNavigation: true, orderIndex: childIndex))
                                    }
                                }
                            }
                        }
                    }
                    // Always recurse into children to find deeper matches
                    searchNodes(children, query: query, results: &results, orderIndex: &orderIndex)
                }

            case .item:
                // Items should be handled by their parent group
                break
            }
        }
    }
}
