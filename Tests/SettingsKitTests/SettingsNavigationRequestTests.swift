import XCTest
@testable import SettingsKit

final class SettingsNavigationRequestTests: XCTestCase {
    func testResolvesPageInsideInlineSectionAndNestedPage() {
        let shortcut = SettingsNode.group(id: UUID(), title: "Shortcuts", tags: [],
                                          presentation: .navigation, children: [])
        let integrations = SettingsNode.group(id: UUID(), title: "Integrations", tags: [],
                                              presentation: .inline, children: [shortcut])
        let request = SettingsNavigationRequest(groupTitles: ["Shortcuts"])
        XCTAssertEqual(request.resolve(in: [integrations]), [shortcut])

        let nested = SettingsNode.group(id: UUID(), title: "Advanced", tags: [],
                                        presentation: .navigation, children: [shortcut])
        XCTAssertEqual(SettingsNavigationRequest(groupTitles: ["Advanced", "Shortcuts"])
            .resolve(in: [nested]), [nested, shortcut])
    }

    func testRejectsMissingAndAmbiguousDestinations() {
        let first = SettingsNode.group(id: UUID(), title: "Shortcuts", tags: [],
                                       presentation: .navigation, children: [])
        let second = SettingsNode.group(id: UUID(), title: "Shortcuts", tags: [],
                                        presentation: .navigation, children: [])
        XCTAssertNil(SettingsNavigationRequest(groupTitles: ["Shortcuts"]).resolve(in: [first, second]))
        XCTAssertNil(SettingsNavigationRequest(groupTitles: ["Other"]).resolve(in: [first]))
        XCTAssertNil(SettingsNavigationRequest(groupTitles: []).resolve(in: [first]))
    }
}
