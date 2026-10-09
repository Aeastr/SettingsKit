import SwiftUI

/// One observable model shared by every demo presentation.
@Observable
final class SettingsState {
    // Apple Account
    var profileDisplayName = "Sample User"
    var profileEmail = "sample.user@example.com"
    var syncProfileSettings = true
    var iCloudDrive = true
    var iCloudPhotos = true
    var privateRelay = true
    var advancedDataProtection = true
    var findMyIPhone = true
    var shareMyLocation = true
    var purchaseSharing = true

    // Connectivity
    var airplaneModeEnabled = false
    var wifiEnabled = true
    var askToJoinNetworks = "Notify"
    var autoJoinHotspot = "Ask to Join"
    var preferredWiFiNetwork = "Sample Home Wi-Fi"
    var wifiAutoJoin = true
    var wifiPrivateAddress = true
    var wifiLimitIPTracking = true
    var wifiLowDataMode = false
    var configureIP = "Automatic"
    var configureDNS = "Automatic"
    var httpProxy = "Off"
    var bluetoothEnabled = true
    var bluetoothDiscoverable = false
    var bluetoothSystemNotifications = true
    var cellularDataEnabled = true
    var cellularLineEnabled = true
    var dataRoaming = false
    var voiceAndData = "5G Auto"
    var dataMode = "Standard"
    var cellularLimitIPTracking = true
    var wifiAssist = true
    var iCloudDriveCellular = true
    var personalHotspotEnabled = false
    var hotspotMaxCompatibility = false
    var hotspotPassword = "settingskit"
    var vpnQuickEnabled = false

    // General
    var automaticSoftwareUpdates = true
    var downloadIOSUpdates = true
    var installIOSUpdates = true
    var securityResponsesEnabled = true
    var betaSoftwareUpdates = false
    var airDropReceiving = "Contacts Only"
    var bringDevicesTogether = true
    var airPlayAutomatically = "Ask"
    var transferToHomePod = true
    var handoffEnabled = true
    var continuityCamera = true
    var pipEnabled = true
    var pipAutoStart = true
    var offloadUnusedApps = true
    var autoFillPasswords = true
    var autoFillPasskeys = true
    var deleteAfterUse = true
    var setAutomatically = true
    var use24Hour = false
    var timeZone = "Los Angeles"
    var autoCapitalization = true
    var autoCorrect = true
    var checkSpelling = true
    var capsLock = true
    var predictiveText = true
    var inlinePredictions = true
    var smartPunctuation = true
    var characterPreview = true
    var slideToType = true
    var dictation = true
    var autoPunctuation = true
    var language = "English (US)"
    var region = "United States"
    var calendar = "Gregorian"
    var temperatureUnit = "System"
    var measurementSystem = "US"

    // Accessibility
    var voiceOver = false
    var zoom = false
    var displayTextSize = "Default"
    var largerAccessibilityText = false
    var motionReduce = false
    var spokenContent = false
    var audioDescriptions = false
    var touchAccommodations = false
    var reachability = true
    var callAudioRouting = "Automatic"
    var soundRecognition = false
    var headphoneAccommodations = false
    var backgroundSounds = false
    var liveCaptions = false
    var subtitlesSDH = false
    var guidedAccess = false
    var assistiveAccess = false
    var accessibilityShortcut = "Magnifier"

    // Intelligence, interface, and media
    var actionButtonAction = "Silent Mode"
    var appleIntelligenceEnabled = true
    var siriSuggestions = true
    var talkToSiri = "Siri or Hey Siri"
    var siriVoice = "American (Voice 4)"
    var siriResponses = "Automatic"
    var announceNotifications = true
    var allowSiriWhenLocked = true
    var cameraFormats = "High Efficiency"
    var photoModeResolution = "24 MP"
    var recordVideo = "4K at 60 fps"
    var recordSloMo = "1080p at 240 fps"
    var stereoSound = true
    var preserveCameraMode = true
    var useVolumeUpBurst = false
    var scanQRCodes = true
    var showDetectedText = true
    var grid = false
    var level = true
    var mirrorFrontCamera = false
    var viewOutsideFrame = true
    var prioritizeFasterShooting = true
    var lensCorrection = true
    var macroControl = true
    var accessWithinApps = true
    var resetControlCenter = false
    var appearance = "Automatic"
    var textSize = 0.55
    var boldText = false
    var autoBrightness = true
    var trueTone = true
    var nightShift = "10:00 PM to 7:00 AM"
    var autoLock = "2 Minutes"
    var raiseToWake = true
    var alwaysOnDisplay = true
    var displayZoom = "Default"
    var newlyDownloadedApps = "App Library Only"
    var notificationBadgesInLibrary = true
    var showOnHomeScreen = true
    var showInAppLibrary = true
    var autoStandby = true
    var standbyDisplay = "Automatically"
    var standbyNightMode = true
    var standbyMotionToWake = true

    // Notifications, sound, focus, and Screen Time
    var notificationDisplay = "Stack"
    var scheduledSummary = false
    var showPreviews = "When Unlocked"
    var screenSharingNotifications = false
    var siriNotificationSuggestions = true
    var ringerVolume = 0.62
    var changeWithButtons = false
    var ringtone = "Reflection"
    var textTone = "Note"
    var keyboardFeedbackSound = false
    var keyboardFeedbackHaptics = true
    var systemHaptics = true
    var headphoneSafety = true
    var reduceLoudAudio = false
    var doNotDisturb = false
    var shareFocusStatus = true
    var focusAcrossDevices = true
    var screenTimeEnabled = true
    var downtimeEnabled = true
    var appLimitsEnabled = true
    var communicationSafety = true
    var contentPrivacyRestrictions = false

    // Battery
    var lowPowerMode = false
    var batteryPercentage = true
    var optimizedCharging = true
    var chargingLimit = "100%"
    var cleanEnergyCharging = true

    // Safety and privacy
    var emergencyCallHold = true
    var emergencyCallFivePresses = true
    var callAfterSevereCrash = true
    var emergencySatelliteDemo = false
    var locationServices = true
    var appTrackingRequests = false
    var safetyCheckComplete = true
    var analyticsSharing = false
    var personalizedAds = false
    var lockdownMode = false
    var contactsAccess = "Limited"
    var photosAccess = "Selected Photos"
    var microphoneAccess = true
    var cameraAccess = true
    var localNetworkAccess = true
    var bluetoothAppAccess = true

    // Wallet, Game Center, and apps
    var doubleClickSideButton = true
    var walletOrderTracking = true
    var expressTransit = true
    var gameCenterEnabled = true
    var nearbyPlayers = true
    var connectWithFriends = true
    var profilePrivacy = "Friends Only"
    var safariSearchEngine = "Google"
    var safariPreventTracking = true
    var safariBlockPopups = true
    var messagesIMessage = true
    var messagesSendAsSMS = true
    var messagesMMS = true
    var mailPrivacyProtection = true
    var mapsPreferredTransport = "Driving"
    var mapsAvoidTolls = false
    var musicDolbyAtmos = "Automatic"
    var musicLossless = false
    var photosCellularData = true

    // Fully custom destination example
    var customDashboardEnabled = true
    var customDashboardProfile = "Balanced"
    var customDashboardIntensity = 0.72
    var customDashboardRefreshCount = 0

    // Tabbed cards example
    var launchAtLogin = true
    var showNotifications = true
    var automaticUpdates = true
    var newWindowBehavior = "Last Workspace"
    var restoreDocuments = true
    var defaultWorkspace = "Projects"
    var confirmBeforeClosing = false
    var shortcutsEnabled = true
    var shortcutBehavior = "Show Window"
    var downloadUpdatesAutomatically = true
    var installUpdatesAutomatically = false
    var updateChannel = "Stable"
    var interfaceTheme = "System"
    var accentColorName = "Purple"
    var compactSpacing = false
    var interfaceScale = 1.0
    var automationsEnabled = true
    var runAutomationsInBackground = false
    var automationNotifications = true

    // Developer and diagnostics examples
    var debugMode = false
    var verboseLogging = false
    var showHiddenFeatures = false
    var networkDebugging = false
    var darkMode = false
    var testToggle = false
    var testSlider = 0.5
    var testText = ""
    var testPicker = 0
    var testStepper = 0
    var testCounter = 0
}
