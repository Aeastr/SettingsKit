import SwiftUI

@Observable
class SettingsState {
    var airplaneModeEnabled = false
    var bluetoothEnabled = true
    var personalHotspotEnabled = false
    var vpnQuickEnabled = false
    var appleIntelligenceEnabled = true
    var autoBrightness = true
    var siriSuggestions = true
    var autoStandby = true
    var debugMode = false
    var verboseLogging = false
    var showHiddenFeatures = false
    var networkDebugging = false
    var airDropEnabled = true
    var pipEnabled = true
    var autoFillPasswords = true
    var use24Hour = false
    var autoCorrect = true
    var vpnManagementEnabled = false
    var darkMode = false
    var autoJoinWiFi = true

    // Test input state
    var testToggle = false
    var testSlider = 0.5
    var testText = ""
    var testPicker = 0
    var testStepper = 0
    var testCounter = 0
}
