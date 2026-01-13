import SwiftUI

@Observable
class SettingsState {
    var airplaneModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "airplaneModeEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "airplaneModeEnabled") }
    }
    var bluetoothEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "bluetoothEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "bluetoothEnabled") }
    }
    var personalHotspotEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "personalHotspotEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "personalHotspotEnabled") }
    }
    var vpnQuickEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "vpnQuickEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "vpnQuickEnabled") }
    }
    var appleIntelligenceEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "appleIntelligenceEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "appleIntelligenceEnabled") }
    }
    var autoBrightness: Bool {
        get { UserDefaults.standard.object(forKey: "autoBrightness") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "autoBrightness") }
    }
    var siriSuggestions: Bool {
        get { UserDefaults.standard.object(forKey: "siriSuggestions") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "siriSuggestions") }
    }
    var autoStandby: Bool {
        get { UserDefaults.standard.object(forKey: "autoStandby") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "autoStandby") }
    }
    var debugMode: Bool {
        get { UserDefaults.standard.bool(forKey: "debugMode") }
        set { UserDefaults.standard.set(newValue, forKey: "debugMode") }
    }
    var verboseLogging: Bool {
        get { UserDefaults.standard.bool(forKey: "verboseLogging") }
        set { UserDefaults.standard.set(newValue, forKey: "verboseLogging") }
    }
    var showHiddenFeatures: Bool {
        get { UserDefaults.standard.bool(forKey: "showHiddenFeatures") }
        set { UserDefaults.standard.set(newValue, forKey: "showHiddenFeatures") }
    }
    var networkDebugging: Bool {
        get { UserDefaults.standard.bool(forKey: "networkDebugging") }
        set { UserDefaults.standard.set(newValue, forKey: "networkDebugging") }
    }
    var airDropEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "airDropEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "airDropEnabled") }
    }
    var pipEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "pipEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "pipEnabled") }
    }
    var autoFillPasswords: Bool {
        get { UserDefaults.standard.object(forKey: "autoFillPasswords") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "autoFillPasswords") }
    }
    var use24Hour: Bool {
        get { UserDefaults.standard.bool(forKey: "use24Hour") }
        set { UserDefaults.standard.set(newValue, forKey: "use24Hour") }
    }
    var autoCorrect: Bool {
        get { UserDefaults.standard.object(forKey: "autoCorrect") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "autoCorrect") }
    }
    var vpnManagementEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "vpnManagementEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "vpnManagementEnabled") }
    }
    var darkMode: Bool {
        get { UserDefaults.standard.bool(forKey: "darkMode") }
        set { UserDefaults.standard.set(newValue, forKey: "darkMode") }
    }
    var autoJoinWiFi: Bool {
        get { UserDefaults.standard.object(forKey: "autoJoinWiFi") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "autoJoinWiFi") }
    }

    // Test input state
    var testToggle: Bool {
        get { UserDefaults.standard.bool(forKey: "testToggle") }
        set { UserDefaults.standard.set(newValue, forKey: "testToggle") }
    }
    var testSlider: Double {
        get { UserDefaults.standard.object(forKey: "testSlider") as? Double ?? 0.5 }
        set { UserDefaults.standard.set(newValue, forKey: "testSlider") }
    }
    var testText: String {
        get { UserDefaults.standard.string(forKey: "testText") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "testText") }
    }
    var testPicker: Int {
        get { UserDefaults.standard.integer(forKey: "testPicker") }
        set { UserDefaults.standard.set(newValue, forKey: "testPicker") }
    }
    var testStepper: Int {
        get { UserDefaults.standard.integer(forKey: "testStepper") }
        set { UserDefaults.standard.set(newValue, forKey: "testStepper") }
    }
    var testCounter: Int {
        get { UserDefaults.standard.integer(forKey: "testCounter") }
        set { UserDefaults.standard.set(newValue, forKey: "testCounter") }
    }
}
