import XCTest
import SwiftUI
@testable import SettingsKit

final class SettingsIntroductionTests: XCTestCase {
    @MainActor
    func testPresentationContextIntroductionLookupIsHostLocal() throws {
        let registry = SettingsNodeViewRegistry()
        let page = SettingsGroup("Account") {
            Text("Welcome").settingsIntroduction()
        }
        let node = try XCTUnwrap(page.makeNodes(in: SettingsContentScope(registry: registry)).first)
        let group = node.asGroupConfiguration(registry: registry)
        func context(_ registry: SettingsNodeViewRegistry) -> SettingsPresentationContext {
            SettingsPresentationContext(
                title: "Settings", searchText: .constant(""),
                navigationPath: .constant(NavigationPath()), selectedGroup: .constant(nil),
                nodes: [node], searchResults: [], rootContent: AnyView(EmptyView()),
                searchContent: AnyView(EmptyView()), content: AnyView(EmptyView()),
                registry: registry,
                makeGroupConfiguration: { $0.asGroupConfiguration(registry: registry) },
                makeIndexedView: { registry.view(for: $0.id) }
            )
        }
        XCTAssertTrue(context(registry).hasIntroduction(in: group))
        XCTAssertFalse(context(SettingsNodeViewRegistry()).hasIntroduction(in: group))
    }

    @MainActor
    func testUnindexedPageContentPreservesIntroWithoutIndexingItsRows() throws {
        let registry = SettingsNodeViewRegistry()
        let page = SettingsGroup("iCloud") {
            IntroductionPageFixture().unindexed()
        }
        let nodes = page.makeNodes(in: SettingsContentScope(registry: registry))
        let root = try XCTUnwrap(nodes.first)
        XCTAssertTrue(registry.hasIntroduction(in: root.id))
        XCTAssertEqual(DefaultSettingsSearch().search(nodes: nodes, query: "iCloud").count, 1)
        XCTAssertTrue(DefaultSettingsSearch().search(nodes: nodes, query: "Transient status").isEmpty)
    }

    @MainActor
    func testUnmarkedPagesKeepNormalTitleAndNestedIntroductionStaysLocal() throws {
        let registry = SettingsNodeViewRegistry()
        let page = SettingsGroup("Parent") {
            SettingsGroup("Child") {
                Text("Welcome").settingsIntroduction()
            }
        }
        let root = try XCTUnwrap(page.makeNodes(in: SettingsContentScope(registry: registry)).first)
        let child = try XCTUnwrap(root.children?.first)
        XCTAssertFalse(registry.hasIntroduction(in: root.id))
        XCTAssertTrue(registry.hasIntroduction(in: child.id))
        XCTAssertTrue(child.children?.isEmpty == true)
    }

    @MainActor
    func testInlineIntroductionIsDetectedWithoutChangingSearchMetadata() throws {
        let registry = SettingsNodeViewRegistry()
        let page = SettingsGroup("Account") {
            SettingsGroup("", .inline) {
                Text("Welcome").settingsIntroduction()
            }
            Text("Enabled").indexed("Status")
        }
        let root = try XCTUnwrap(page.makeNodes(in: SettingsContentScope(registry: registry)).first)
        XCTAssertTrue(registry.hasIntroduction(in: root.id))
        XCTAssertEqual(root.children?.count, 2)
        XCTAssertEqual(DefaultSettingsSearch().search(nodes: [root], query: "status").first?.matchedItems.count, 1)
        XCTAssertTrue(DefaultSettingsSearch().search(nodes: [root], query: "welcome").isEmpty)
        registry.clear()
        XCTAssertFalse(registry.hasIntroduction(in: root.id))
    }

    @MainActor
    func testIntroductionWorksInsideUnindexedGroupAndRemainsHostLocal() throws {
        let registry = SettingsNodeViewRegistry()
        let otherHost = SettingsNodeViewRegistry()
        let page = SettingsGroup("Activity") {
            Text("Welcome").settingsIntroduction()
        }.unindexed()
        let root = try XCTUnwrap(page.makeNodes(in: SettingsContentScope(registry: registry)).first)
        XCTAssertTrue(registry.hasIntroduction(in: root.id))
        XCTAssertFalse(otherHost.hasIntroduction(in: root.id))
        XCTAssertFalse(root.isIncludedInSearch)
        XCTAssertNotNil(registry.view(for: root.id))
    }
}

private struct IntroductionPageFixture: SettingsContent {
    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("", .inline) {
            Text("iCloud").settingsIntroduction()
        }
        Text("Checking").indexed("Transient status")
    }
}
