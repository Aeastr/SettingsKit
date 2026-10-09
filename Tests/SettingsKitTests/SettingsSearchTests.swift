import XCTest
import SwiftUI
@testable import SettingsKit

final class SettingsSearchTests: XCTestCase {
    @MainActor
    func testSameNamedDynamicRowsKeepTheirOwnIdentity() throws {
        let group = SettingsGroup("Activity", .inline) {
            Text("Yesterday").indexed("Upload", tags: [], id: "yesterday")
            Text("Today").indexed("Upload", tags: [], id: "today")
        }
        let node = try XCTUnwrap(group.makeNodes().first)
        XCTAssertNotEqual(node.children?[0].id, node.children?[1].id)
        XCTAssertEqual(DefaultSettingsSearch().search(nodes: [node], query: "upload").first?.matchedItems.count, 2)
    }

    @MainActor
    func testRepeatedPageAndControlTitlesHavePathScopedIdentity() throws {
        let hierarchy = SettingsGroup("Root") {
            SettingsGroup("iCloud") {
                SettingsGroup("Status", .inline) { Text("Cloud").indexed("State") }
            }
            SettingsGroup("Image Search") {
                SettingsGroup("Status", .inline) { Text("Images").indexed("State") }
            }
        }
        let root = try XCTUnwrap(hierarchy.makeNodes().first)
        let pages = try XCTUnwrap(root.children)
        let firstSection = try XCTUnwrap(pages[0].children?.first)
        let secondSection = try XCTUnwrap(pages[1].children?.first)
        XCTAssertNotEqual(firstSection.id, secondSection.id)
        XCTAssertNotEqual(firstSection.children?.first?.id, secondSection.children?.first?.id)
        let repeated = try XCTUnwrap(hierarchy.makeNodes().first)
        XCTAssertEqual(repeated.children?[0].children?.first?.id, firstSection.id)
        XCTAssertEqual(DefaultSettingsSearch().search(nodes: [root], query: "state").count, 2)
    }

    @MainActor
    func testExplicitIdentityDistinguishesSameNamedSiblings() throws {
        let hierarchy = SettingsGroup("Stickers") {
            SettingsGroup("Photo") { Text("First").indexed("Filename") }.settingsID("first")
            SettingsGroup("Photo") { Text("Second").indexed("Filename") }.settingsID("second")
        }
        let children = try XCTUnwrap(hierarchy.makeNodes().first?.children)
        XCTAssertNotEqual(children[0].id, children[1].id)
        XCTAssertNotEqual(children[0].children?.first?.id, children[1].children?.first?.id)
    }

    func testMixedSectionSearchIncludesDirectControlsAndNestedPages() {
        let control = SettingsNode.item(id: UUID(), title: "Save to Photos", tags: [], searchable: true)
        let deepControl = SettingsNode.item(id: UUID(), title: "Rebuild Image Index", tags: [], searchable: true)
        let deepPage = SettingsNode.group(id: UUID(), title: "Live Controls", tags: [],
                                         presentation: .navigation, children: [deepControl])
        let child = SettingsNode.group(id: UUID(), title: "Image Search", tags: [],
                                      presentation: .navigation, children: [deepPage])
        let section = SettingsNode.group(id: UUID(), title: "Library", tags: [],
                                        presentation: .inline, children: [control, child])
        let search = DefaultSettingsSearch()
        XCTAssertEqual(search.search(nodes: [section], query: "photos").first?.matchedItems, [control])
        XCTAssertEqual(search.search(nodes: [section], query: "photos").first?.isNavigation, false)
        XCTAssertEqual(search.search(nodes: [section], query: "rebuild").first?.group.id, deepPage.id)
        XCTAssertEqual(search.search(nodes: child.children ?? [], query: "rebuild").first?.matchedItems, [deepControl])
        XCTAssertTrue(search.search(nodes: [section], query: "library").contains { $0.matchedItems.contains(control) })
    }

    func testMixedNestedSectionControlResolvesToItsNavigationOwner() {
        let control = SettingsNode.item(id: UUID(), title: "Force Pro", tags: [], searchable: true)
        let child = SettingsNode.group(id: UUID(), title: "Image Search", tags: [],
                                      presentation: .navigation, children: [])
        let section = SettingsNode.group(id: UUID(), title: "Actions", tags: [],
                                        presentation: .inline, children: [control, child])
        let page = SettingsNode.group(id: UUID(), title: "Debug Options", tags: [],
                                     presentation: .navigation, children: [section])
        let results = DefaultSettingsSearch().search(nodes: [page], query: "force")
        XCTAssertEqual(results.first?.group.id, page.id)
        XCTAssertEqual(results.first?.matchedItems, [control])
        XCTAssertEqual(results.first?.isNavigation, true)
    }

    @MainActor
    func testContentGroupsUseSemanticIdentityInsteadOfArrayPosition() {
        let general = SettingsContentGroup([
            SettingsGroup("General", .inline) { EmptyView() }
        ])
        let style = SettingsContentGroup([
            SettingsGroup("Style", .inline) { EmptyView() }
        ])
        let repeatedGeneral = SettingsContentGroup([
            SettingsGroup("General", .inline) { EmptyView() }
        ])

        let generalID = general.renderItems[0].id
        let styleID = style.renderItems[0].id
        let repeatedGeneralID = repeatedGeneral.renderItems[0].id

        XCTAssertNotEqual(generalID, styleID)
        XCTAssertEqual(generalID, repeatedGeneralID)
    }

    func testIndexedItemsInsideInlineGroupsAreSearchable() {
        let itemID = UUID()
        let groupID = UUID()
        let nodes: [SettingsNode] = [
            .group(
                id: groupID,
                title: "Appearance",
                tags: [],
                presentation: .inline,
                children: [
                    .item(
                        id: itemID,
                        title: "Accent Intensity",
                        tags: ["theme", "color"],
                        searchable: true
                    )
                ]
            )
        ]

        let results = DefaultSettingsSearch().search(nodes: nodes, query: "accent")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.group.id, groupID)
        XCTAssertEqual(results.first?.matchedItems.first?.id, itemID)
        XCTAssertEqual(results.first?.isNavigation, false)
    }

    func testChildMatchDoesNotIncludeUnmatchedSiblings() {
        let launchID = UUID()
        let notificationsID = UUID()
        let group = SettingsNode.group(
            id: UUID(),
            title: "Startup",
            tags: [],
            presentation: .inline,
            children: [
                .item(
                    id: launchID,
                    title: "Launch at login",
                    tags: ["boot"],
                    searchable: true
                ),
                .item(
                    id: notificationsID,
                    title: "Show notifications",
                    tags: ["alerts"],
                    searchable: true
                )
            ]
        )

        let results = DefaultSettingsSearch().search(nodes: [group], query: "launch")

        XCTAssertEqual(results.first?.matchedItems.map(\.id), [launchID])
    }

    func testGroupTitleMatchIncludesTheGroupsSearchableControls() {
        let firstID = UUID()
        let secondID = UUID()
        let group = SettingsNode.group(
            id: UUID(),
            title: "Application",
            tags: [],
            presentation: .inline,
            children: [
                .item(id: firstID, title: "Launch at login", tags: [], searchable: true),
                .item(id: secondID, title: "Show notifications", tags: [], searchable: true)
            ]
        )

        let results = DefaultSettingsSearch().search(nodes: [group], query: "application")

        XCTAssertEqual(results.first?.matchedItems.map(\.id), [firstID, secondID])
    }

    func testControlMatchInsideNavigationGroupReturnsTheDestinationAndMatchedControl() {
        let toggleID = UUID()
        let wifiID = UUID()
        let wifi = SettingsNode.group(
            id: wifiID,
            title: "Wi-Fi",
            tags: ["network"],
            presentation: .navigation,
            children: [
                .item(
                    id: toggleID,
                    title: "Enable Wi-Fi",
                    tags: ["wireless"],
                    searchable: true
                )
            ]
        )

        let results = DefaultSettingsSearch().search(nodes: [wifi], query: "enable wi-fi")

        XCTAssertEqual(results.first?.group.id, wifiID)
        XCTAssertEqual(results.first?.matchedItems.map(\.id), [toggleID])
        XCTAssertEqual(results.first?.isNavigation, true)
    }

    func testControlsInsideInlineSectionsBubbleToAndMergeUnderNavigationDestination() {
        let enableID = UUID()
        let joinID = UUID()
        let wifiID = UUID()
        let wifi = SettingsNode.group(
            id: wifiID,
            title: "Wi-Fi",
            tags: [],
            presentation: .navigation,
            children: [
                .group(
                    id: UUID(),
                    title: "Connectivity",
                    tags: [],
                    presentation: .inline,
                    children: [
                        .item(id: enableID, title: "Enable Wi-Fi", tags: ["wireless"], searchable: true)
                    ]
                ),
                .group(
                    id: UUID(),
                    title: "Joining",
                    tags: [],
                    presentation: .inline,
                    children: [
                        .item(id: joinID, title: "Ask to Join Networks", tags: ["wireless"], searchable: true)
                    ]
                )
            ]
        )

        let results = DefaultSettingsSearch().search(nodes: [wifi], query: "wireless")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.group.id, wifiID)
        XCTAssertEqual(results.first?.matchedItems.map(\.id), [enableID, joinID])
        XCTAssertEqual(results.first?.isNavigation, true)
    }

    func testSearchResultIdentityUsesTheMatchedGroup() {
        let groupID = UUID()
        let group = SettingsNode.group(
            id: groupID,
            title: "General",
            tags: [],
            presentation: .navigation,
            children: []
        )

        let result = SettingsSearchResult(
            group: group,
            matchedItems: [],
            isNavigation: true,
            orderIndex: 0
        )

        XCTAssertEqual(result.id, groupID)
    }

    func testNavigationGroupSearchBehaviorIsPreserved() {
        let groupID = UUID()
        let nodes: [SettingsNode] = [
            .group(
                id: groupID,
                title: "Developer Tools",
                tags: ["debug"],
                presentation: .navigation,
                children: []
            )
        ]

        let results = DefaultSettingsSearch().search(nodes: nodes, query: "debug")

        XCTAssertEqual(results.map(\.group.id), [groupID])
        XCTAssertEqual(results.first?.isNavigation, true)
    }

    @MainActor
    func testGroupSystemImageIsPreservedForNavigationAndSearch() throws {
        let group = SettingsGroup("Timetable", systemImage: "calendar") {
            EmptyView()
        }

        let node = try XCTUnwrap(group.makeNodes().first)
        let configuration = node.asGroupConfiguration()

        XCTAssertEqual(node.systemImage, "calendar")
        XCTAssertEqual(configuration.systemImage, "calendar")
    }

    @MainActor
    func testNavigationGroupsCanNestToThreeLevels() throws {
        let hierarchy = SettingsGroup("General") {
            SettingsGroup("Software Update") {
                SettingsGroup("Advanced Update Options") {
                    EmptyView()
                }
            }
        }

        let general = try XCTUnwrap(hierarchy.makeNodes().first)
        let softwareUpdate = try XCTUnwrap(general.children?.first)
        let advancedOptions = try XCTUnwrap(softwareUpdate.children?.first)

        XCTAssertEqual(general.title, "General")
        XCTAssertEqual(softwareUpdate.title, "Software Update")
        XCTAssertEqual(advancedOptions.title, "Advanced Update Options")
        XCTAssertEqual(
            [general, softwareUpdate, advancedOptions].map(\.presentation),
            [.navigation, .navigation, .navigation]
        )
    }

    @MainActor
    func testSearchDestinationDefersRegisteredContentUntilPresentation() {
        let id = UUID()
        let registry = SettingsNodeViewRegistry()
        var resolutionCount = 0

        registry.register(id: id) {
            resolutionCount += 1
            return AnyView(Text("Live destination"))
        }

        let node = SettingsNode.group(
            id: id,
            title: "General",
            tags: [],
            presentation: .navigation,
            children: []
        )

        _ = node.asGroupConfiguration(registry: registry)

        XCTAssertEqual(resolutionCount, 0)
    }

    @MainActor
    func testSettingsHostDoesNotBuildIndexDuringBodyEvaluation() {
        let counter = SettingsBodyEvaluationCounter()
        let host = SettingsHost(
            container: CountingSettingsContainer(counter: counter)
        ) { _ in
            EmptyView()
        }

        _ = host.body

        XCTAssertEqual(counter.value, 0)
    }
}

@MainActor
private final class SettingsBodyEvaluationCounter {
    var value = 0
}

private struct CountingSettingsContainer: SettingsContainer {
    let counter: SettingsBodyEvaluationCounter

    @SettingsContentBuilder
    var settingsBody: some SettingsContent {
        let _ = counter.value += 1

        SettingsGroup("General", .inline) {
            EmptyView()
        }
    }
}
