import XCTest
import SwiftUI
@testable import SettingsKit

final class UnindexedSettingsContentTests: XCTestCase {
    @MainActor
    func testExcludedSubtreeKeepsNavigationButNeverMatchesRootOrPageSearch() throws {
        let registry = SettingsNodeViewRegistry()
        let scope = SettingsContentScope(registry: registry)
        let hierarchy = SettingsGroup("iCloud") {
            SettingsGroup("Sync Issues", systemImage: "icloud") {
                SettingsGroup("Error Details") {
                    Text("Failure").indexed("Private diagnostics")
                }
            }.unindexed()
            Text("Enabled").indexed("Status")
        }
        let nodes = hierarchy.makeNodes(in: scope)
        let root = try XCTUnwrap(nodes.first)
        let issue = try XCTUnwrap(root.children?.first)
        let detail = try XCTUnwrap(issue.children?.first)
        XCTAssertEqual(issue.title, "Sync Issues")
        XCTAssertEqual(issue.presentation, .navigation)
        XCTAssertEqual(issue.systemImage, "icloud")
        XCTAssertNotNil(registry.view(for: issue.id))
        XCTAssertNotNil(registry.view(for: detail.id))
        XCTAssertFalse(issue.isIncludedInSearch)
        XCTAssertFalse(detail.isIncludedInSearch)
        let search = DefaultSettingsSearch()
        for query in ["sync", "error", "private"] {
            XCTAssertTrue(search.search(nodes: nodes, query: query).isEmpty)
            XCTAssertTrue(search.search(nodes: registry.children(for: issue.id) ?? [], query: query).isEmpty)
        }
        // Matching the parent must not leak an excluded immediate child.
        XCTAssertEqual(search.search(nodes: nodes, query: "iCloud").map(\.group.id), [root.id])
        XCTAssertEqual(search.search(nodes: nodes, query: "status").first?.matchedItems.count, 1)
    }

    @MainActor
    func testExcludedInlineGroupAndIndexedControlKeepTheirRenderingRoles() throws {
        let section = SettingsGroup("Diagnostics", .inline) {
            Text("Value").indexed("Secret")
        }
        let excluded = section.unindexed()
        let originalItem = SettingsContentGroup([section]).renderItems[0]
        let excludedItem = SettingsContentGroup([excluded]).renderItems[0]
        XCTAssertEqual(originalItem.id, excludedItem.id)
        guard case .inlineGroup = excludedItem.rowRole else { return XCTFail("Lost inline styling") }
        XCTAssertTrue(DefaultSettingsSearch().search(nodes: excluded.makeNodes(), query: "diagnostics").isEmpty)

        let root = SettingsGroup("General") {
            Text("Value").indexed("Secret").unindexed()
            Text("Value").indexed("Public")
        }
        let results = DefaultSettingsSearch().search(nodes: root.makeNodes(), query: "general")
        XCTAssertEqual(results.first?.matchedItems.map(\.title), ["Public"])
    }

    @MainActor
    func testCustomGroupExclusionRetainsDestinationAndHostIsolation() throws {
        let first = SettingsNodeViewRegistry()
        let second = SettingsNodeViewRegistry()
        let group = CustomSettingsGroup("Activity") { Text("Live content") }
        let hidden = try XCTUnwrap(group.unindexed().makeNodes(in: SettingsContentScope(registry: first)).first)
        let visible = try XCTUnwrap(group.makeNodes(in: SettingsContentScope(registry: second)).first)
        XCTAssertEqual(hidden.id, visible.id)
        XCTAssertNotNil(first.view(for: hidden.id))
        XCTAssertFalse(hidden.isSearchable)
        XCTAssertTrue(visible.isSearchable)
    }
}
