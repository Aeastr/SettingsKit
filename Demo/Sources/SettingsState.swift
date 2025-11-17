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

    // Accessibility
    var voiceOverEnabled = false
    var zoomEnabled = false
    var displayAccommodations = false
    var textSize: Double = 3.0 // 1-7 scale

    // Action Button
    var actionButtonFunction = 0 // 0: Silent Mode, 1: Camera, 2: Flashlight, 3: Voice Memo, 4: Shortcuts

    // Camera
    var preserveSettings = true
    var gridEnabled = false
    var scanQRCodes = true
    var recordVideoFormat = 0 // 0: High Efficiency, 1: Most Compatible
    var recordStereoAudio = true

    // Test input state
    var testToggle = false
    var testSlider = 0.5
    var testText = ""
    var testPicker = 0
    var testStepper = 0
    var testCounter = 0
}
