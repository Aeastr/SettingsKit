import SwiftUI

@Observable
class SettingsState {
    var airplaneModeEnabled = UserDefaults.standard.bool(forKey: "airplaneModeEnabled") {
        didSet { UserDefaults.standard.set(airplaneModeEnabled, forKey: "airplaneModeEnabled") }
    }
    var bluetoothEnabled = UserDefaults.standard.object(forKey: "bluetoothEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(bluetoothEnabled, forKey: "bluetoothEnabled") }
    }
    var personalHotspotEnabled = UserDefaults.standard.bool(forKey: "personalHotspotEnabled") {
        didSet { UserDefaults.standard.set(personalHotspotEnabled, forKey: "personalHotspotEnabled") }
    }
    var vpnQuickEnabled = UserDefaults.standard.bool(forKey: "vpnQuickEnabled") {
        didSet { UserDefaults.standard.set(vpnQuickEnabled, forKey: "vpnQuickEnabled") }
    }
    var appleIntelligenceEnabled = UserDefaults.standard.object(forKey: "appleIntelligenceEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(appleIntelligenceEnabled, forKey: "appleIntelligenceEnabled") }
    }
    var autoBrightness = UserDefaults.standard.object(forKey: "autoBrightness") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoBrightness, forKey: "autoBrightness") }
    }
    var siriSuggestions = UserDefaults.standard.object(forKey: "siriSuggestions") as? Bool ?? true {
        didSet { UserDefaults.standard.set(siriSuggestions, forKey: "siriSuggestions") }
    }
    var autoStandby = UserDefaults.standard.object(forKey: "autoStandby") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoStandby, forKey: "autoStandby") }
    }
    var debugMode = UserDefaults.standard.bool(forKey: "debugMode") {
        didSet { UserDefaults.standard.set(debugMode, forKey: "debugMode") }
    }
    var verboseLogging = UserDefaults.standard.bool(forKey: "verboseLogging") {
        didSet { UserDefaults.standard.set(verboseLogging, forKey: "verboseLogging") }
    }
    var showHiddenFeatures = UserDefaults.standard.bool(forKey: "showHiddenFeatures") {
        didSet { UserDefaults.standard.set(showHiddenFeatures, forKey: "showHiddenFeatures") }
    }
    var networkDebugging = UserDefaults.standard.bool(forKey: "networkDebugging") {
        didSet { UserDefaults.standard.set(networkDebugging, forKey: "networkDebugging") }
    }
    var airDropEnabled = UserDefaults.standard.object(forKey: "airDropEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(airDropEnabled, forKey: "airDropEnabled") }
    }
    var pipEnabled = UserDefaults.standard.object(forKey: "pipEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(pipEnabled, forKey: "pipEnabled") }
    }
    var autoFillPasswords = UserDefaults.standard.object(forKey: "autoFillPasswords") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoFillPasswords, forKey: "autoFillPasswords") }
    }
    var use24Hour = UserDefaults.standard.bool(forKey: "use24Hour") {
        didSet { UserDefaults.standard.set(use24Hour, forKey: "use24Hour") }
    }
    var autoCorrect = UserDefaults.standard.object(forKey: "autoCorrect") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoCorrect, forKey: "autoCorrect") }
    }
    var vpnManagementEnabled = UserDefaults.standard.bool(forKey: "vpnManagementEnabled") {
        didSet { UserDefaults.standard.set(vpnManagementEnabled, forKey: "vpnManagementEnabled") }
    }
    var darkMode = UserDefaults.standard.bool(forKey: "darkMode") {
        didSet { UserDefaults.standard.set(darkMode, forKey: "darkMode") }
    }
    var autoJoinWiFi = UserDefaults.standard.object(forKey: "autoJoinWiFi") as? Bool ?? true {
        didSet { UserDefaults.standard.set(autoJoinWiFi, forKey: "autoJoinWiFi") }
    }

    // Test input state
    var testToggle = UserDefaults.standard.bool(forKey: "testToggle") {
        didSet { UserDefaults.standard.set(testToggle, forKey: "testToggle") }
    }
    var testSlider = UserDefaults.standard.object(forKey: "testSlider") as? Double ?? 0.5 {
        didSet { UserDefaults.standard.set(testSlider, forKey: "testSlider") }
    }
    var testText = UserDefaults.standard.string(forKey: "testText") ?? "" {
        didSet { UserDefaults.standard.set(testText, forKey: "testText") }
    }
    var testPicker = UserDefaults.standard.integer(forKey: "testPicker") {
        didSet { UserDefaults.standard.set(testPicker, forKey: "testPicker") }
    }
    var testStepper = UserDefaults.standard.integer(forKey: "testStepper") {
        didSet { UserDefaults.standard.set(testStepper, forKey: "testStepper") }
    }
    var testCounter = UserDefaults.standard.integer(forKey: "testCounter") {
        didSet { UserDefaults.standard.set(testCounter, forKey: "testCounter") }
    }
}
