import SwiftUI
import SettingsKit

struct AccessibilitySettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Vision", .inline) {
            SettingsGroup("VoiceOver") {
                Toggle(isOn: $state.voiceOver) {
                    Text("VoiceOver")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Picker("Speaking Rate", selection: $state.siriResponses) {
                    Text("Slow").tag("Slow")
                    Text("Medium").tag("Automatic")
                    Text("Fast").tag("Fast")
                }
                SettingsValueRow(title: "Speech", value: "Samantha")
                SettingsValueRow(title: "Braille", value: "English Unified")
                SettingsValueRow(title: "VoiceOver Recognition", value: "On")
                SettingsValueRow(title: "Verbosity", value: "Default")
                SettingsValueRow(title: "Rotor", value: "12 Items")
                SettingsValueRow(title: "Typing", value: "Standard Typing")
                SettingsValueRow(title: "Audio", value: "Auto-select Speaker")
            }
            SettingsGroup("Zoom") {
                Toggle(isOn: $state.zoom) {
                    Text("Zoom")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Zoom Region", value: "Full Screen Zoom")
                SettingsValueRow(title: "Zoom Filter", value: "None")
                SettingsValueRow(title: "Maximum Zoom Level", value: "5×")
            }
            SettingsGroup("Display & Text Size") {
                Toggle(isOn: $state.boldText) {
                    Text("Bold Text")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.largerAccessibilityText) {
                    Text("Larger Text")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Button Shapes", value: "Off")
                SettingsValueRow(title: "On/Off Labels", value: "Off")
                SettingsValueRow(title: "Reduce Transparency", value: "Off")
                SettingsValueRow(title: "Increase Contrast", value: "Off")
                SettingsValueRow(title: "Differentiate Without Color", value: "Off")
                SettingsValueRow(title: "Smart Invert", value: "Off")
                SettingsValueRow(title: "Classic Invert", value: "Off")
                SettingsValueRow(title: "Color Filters", value: "Off")
                Toggle(isOn: $state.autoBrightness) {
                    Text("Auto-Brightness")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            SettingsGroup("Motion") {
                Toggle(isOn: $state.motionReduce) {
                    Text("Reduce Motion")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.motionReduce) {
                    Text("Prefer Cross-Fade Transitions")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Auto-Play Message Effects", value: "On")
                SettingsValueRow(title: "Auto-Play Video Previews", value: "On")
                SettingsValueRow(title: "Dim Flashing Lights", value: "On")
                SettingsValueRow(title: "Limit Frame Rate", value: "Off")
            }
            SettingsGroup("Spoken Content") {
                Toggle(isOn: $state.spokenContent) {
                    Text("Speak Selection")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.spokenContent) {
                    Text("Speak Screen")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Voices", value: "Samantha")
                SettingsValueRow(title: "Speaking Rate", value: "50%")
                SettingsValueRow(title: "Pronunciations", value: "None")
            }
            Toggle(isOn: $state.audioDescriptions) {
                Text("Audio Descriptions")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }

        SettingsGroup("Physical and Motor", .inline) {
            SettingsGroup("Touch") {
                Toggle(isOn: $state.touchAccommodations) {
                    Text("AssistiveTouch")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.reachability) {
                    Text("Reachability")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Haptic Touch", value: "Default")
                SettingsValueRow(title: "Touch Accommodations", value: "Off")
                SettingsValueRow(title: "Tap to Wake", value: "On")
                SettingsValueRow(title: "Shake to Undo", value: "On")
                SettingsValueRow(title: "Vibration", value: "On")
                SettingsValueRow(title: "Call Audio Routing", value: state.callAudioRouting)
                SettingsValueRow(title: "Back Tap", value: "Off")
            }
            SettingsGroup("Face ID & Attention") {
                SettingsValueRow(title: "Require Attention for Face ID", value: "On")
                SettingsValueRow(title: "Attention-Aware Features", value: "On")
                SettingsValueRow(title: "Haptic on Successful Authentication", value: "On")
            }
            SettingsGroup("Switch Control") {
                SettingsValueRow(title: "Switch Control", value: "Off")
                SettingsValueRow(title: "Switches", value: "None")
                SettingsValueRow(title: "Recipes", value: "None")
                SettingsValueRow(title: "Scanning Style", value: "Auto Scanning")
            }
            SettingsGroup("Voice Control") {
                SettingsValueRow(title: "Voice Control", value: "Off")
                SettingsValueRow(title: "Language", value: "English (United States)")
                SettingsValueRow(title: "Commands", value: "All Enabled")
                SettingsValueRow(title: "Vocabulary", value: "None")
            }
            SettingsGroup("Side Button") {
                SettingsValueRow(title: "Click Speed", value: "Default")
                SettingsValueRow(title: "Press and Hold to Speak", value: "Siri")
                SettingsValueRow(title: "Use Passcode for Payments", value: "Off")
            }
            SettingsValueRow(title: "Apple TV Remote", value: "Directional Buttons")
            SettingsValueRow(title: "Keyboards", value: "Full Keyboard Access Off")
        }

        SettingsGroup("Hearing", .inline) {
            SettingsGroup("Hearing Devices") {
                SettingsValueRow(title: "MFi Hearing Devices", value: "Not Connected")
                SettingsValueRow(title: "Hearing Aid Compatibility", value: "Off")
            }
            SettingsGroup("Sound Recognition") {
                Toggle(isOn: $state.soundRecognition) {
                    Text("Sound Recognition")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Sounds", value: "Smoke Alarm, Doorbell")
            }
            SettingsGroup("Audio & Visual") {
                Toggle(isOn: $state.headphoneAccommodations) {
                    Text("Headphone Accommodations")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.backgroundSounds) {
                    Text("Background Sounds")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Mono Audio", value: "Off")
                SettingsValueRow(title: "Phone Noise Cancellation", value: "On")
                SettingsValueRow(title: "LED Flash for Alerts", value: "Off")
                SettingsValueRow(title: "Balance", value: "0.00")
            }
            SettingsGroup("Subtitles & Captioning") {
                Toggle(isOn: $state.subtitlesSDH) {
                    Text("Closed Captions + SDH")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Style", value: "Transparent Background")
                Toggle(isOn: $state.subtitlesSDH) {
                    Text("Show When Muted")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                Toggle(isOn: $state.subtitlesSDH) {
                    Text("Show on Skip Back")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
            }
            SettingsGroup("Live Captions") {
                Toggle(isOn: $state.liveCaptions) {
                    Text("Live Captions")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                    .toggleStyle(.switch)
                    .smallControlSizeOnMacOS()
                SettingsValueRow(title: "Appearance", value: "Default")
                SettingsValueRow(title: "Live Captions in FaceTime", value: "Off")
            }
        }

        SettingsGroup("Speech", .inline) {
            SettingsValueRow(title: "Live Speech", value: "Off")
            SettingsValueRow(title: "Personal Voice", value: "Not Set Up")
            SettingsValueRow(title: "Vocal Shortcuts", value: "None")
        }

        SettingsGroup("General", .inline) {
            Toggle(isOn: $state.guidedAccess) {
                Text("Guided Access")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.assistiveAccess) {
                Text("Assistive Access")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsGroup("Accessibility Shortcut") {
                Picker("Triple-Click Side Button", selection: $state.accessibilityShortcut) {
                    Text("Magnifier").tag("Magnifier")
                    Text("VoiceOver").tag("VoiceOver")
                    Text("Zoom").tag("Zoom")
                    Text("Color Filters").tag("Color Filters")
                    Text("AssistiveTouch").tag("AssistiveTouch")
                }
            }
            SettingsValueRow(title: "Per-App Settings", value: "2 Apps")
        }
    }
}

struct IntelligenceAndSiriSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Apple Intelligence", .inline) {
            Toggle(isOn: $state.appleIntelligenceEnabled) {
                Text("Apple Intelligence")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
                .indexed("Apple Intelligence", tags: ["AI", "writing tools", "summaries"])
            SettingsValueRow(title: "About Apple Intelligence & Privacy", value: "Learn More")
            SettingsValueRow(title: "Language", value: "English (United States)")
            SettingsValueRow(title: "Storage", value: "7.1 GB")
        }
        SettingsGroup("Siri Requests", .inline) {
            Picker("Talk & Type to Siri", selection: $state.talkToSiri) {
                Text("Off").tag("Off")
                Text("Hey Siri").tag("Hey Siri")
                Text("Siri or Hey Siri").tag("Siri or Hey Siri")
            }
            Picker("Siri Voice", selection: $state.siriVoice) {
                Text("American (Voice 4)").tag("American (Voice 4)")
                Text("American (Voice 1)").tag("American (Voice 1)")
                Text("British (Voice 2)").tag("British (Voice 2)")
            }
            Picker("Siri Responses", selection: $state.siriResponses) {
                Text("Automatic").tag("Automatic")
                Text("Prefer Silent Responses").tag("Prefer Silent Responses")
                Text("Prefer Spoken Responses").tag("Prefer Spoken Responses")
            }
            Toggle(isOn: $state.liveCaptions) {
                Text("Always Show Siri Captions")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.spokenContent) {
                Text("Always Show Speech")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Call Hang Up", value: "Off")
            SettingsValueRow(title: "Messaging with Siri", value: "Automatically Send")
        }
        SettingsGroup("Suggestions", .inline) {
            Toggle(isOn: $state.siriSuggestions) {
                Text("Allow Notifications")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.siriSuggestions) {
                Text("Show in App Library")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.siriSuggestions) {
                Text("Show When Sharing")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.siriSuggestions) {
                Text("Show When Listening")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Announcements", .inline) {
            Toggle(isOn: $state.announceNotifications) {
                Text("Announce Notifications")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Announce Calls", value: "Headphones & Car")
        }
        SettingsGroup("Siri History", .inline) {
            Button("Siri & Dictation History") {}
            Button("Delete Siri & Dictation History", role: .destructive) {}
        }
        SettingsGroup("Access", .inline) {
            Toggle(isOn: $state.allowSiriWhenLocked) {
                Text("Allow Siri When Locked")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "My Information", value: "Sample User")
            SettingsValueRow(title: "Apps", value: "120 Apps")
        }
    }
}

struct CameraSettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Capture", .inline) {
            Picker("Formats", selection: $state.cameraFormats) {
                Text("High Efficiency").tag("High Efficiency")
                Text("Most Compatible").tag("Most Compatible")
            }
            Picker("Photo Mode", selection: $state.photoModeResolution) {
                Text("12 MP").tag("12 MP")
                Text("24 MP").tag("24 MP")
            }
            SettingsValueRow(title: "Pro Default", value: "HEIF Max (up to 48 MP)")
            Picker("Record Video", selection: $state.recordVideo) {
                Text("1080p HD at 30 fps").tag("1080p HD at 30 fps")
                Text("4K at 30 fps").tag("4K at 30 fps")
                Text("4K at 60 fps").tag("4K at 60 fps")
            }
            SettingsValueRow(title: "Record Cinematic", value: "4K at 30 fps")
            Picker("Record Slo-mo", selection: $state.recordSloMo) {
                Text("1080p at 120 fps").tag("1080p at 120 fps")
                Text("1080p at 240 fps").tag("1080p at 240 fps")
            }
            Toggle(isOn: $state.stereoSound) {
                Text("Record Stereo Sound")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Preserve Settings", .inline) {
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Camera Mode")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Creative Controls")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Depth Control")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.macroControl) {
                Text("Macro Control")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Exposure Adjustment")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Night Mode")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Portrait Zoom")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Action Mode")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.preserveCameraMode) {
                Text("Live Photo")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Composition", .inline) {
            Toggle(isOn: $state.grid) {
                Text("Grid")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.level) {
                Text("Level")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.mirrorFrontCamera) {
                Text("Mirror Front Camera")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.viewOutsideFrame) {
                Text("View Outside the Frame")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Photo Capture", .inline) {
            Toggle(isOn: $state.useVolumeUpBurst) {
                Text("Use Volume Up for Burst")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.prioritizeFasterShooting) {
                Text("Prioritize Faster Shooting")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.lensCorrection) {
                Text("Lens Correction")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.macroControl) {
                Text("Macro Control")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Photographic Styles", value: "Standard")
        }
        SettingsGroup("System Features", .inline) {
            Toggle(isOn: $state.scanQRCodes) {
                Text("Scan QR Codes")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.showDetectedText) {
                Text("Show Detected Text")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Keep Normals", value: "Off")
        }
    }
}

struct DisplaySettings: SettingsContent {
    @Bindable var state: SettingsState

    @SettingsContentBuilder
    var body: some SettingsContent {
        SettingsGroup("Appearance", .inline) {
            Picker("Appearance", selection: $state.appearance) {
                Text("Light").tag("Light")
                Text("Dark").tag("Dark")
                Text("Automatic").tag("Automatic")
            }
            Toggle(isOn: $state.darkMode) {
                Text("Automatic")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            SettingsValueRow(title: "Options", value: "Light Until Sunset")
        }
        SettingsGroup("Brightness", .inline) {
            Slider(value: $state.textSize, in: 0...1) {
                Text("Brightness")
            } minimumValueLabel: {
                Image(systemName: "sun.min")
            } maximumValueLabel: {
                Image(systemName: "sun.max.fill")
            }
            Toggle(isOn: $state.trueTone) {
                Text("True Tone")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.autoBrightness) {
                Text("Auto-Brightness")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Text", .inline) {
            SettingsGroup("Text Size") {
                Slider(value: $state.textSize, in: 0...1)
                SettingsNote("Apps that support Dynamic Type adjust to your preferred reading size.")
            }
            Toggle(isOn: $state.boldText) {
                Text("Bold Text")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Night Shift") {
            SettingsValueRow(title: "Scheduled", value: state.nightShift)
            SettingsValueRow(title: "Manually Enable Until Tomorrow", value: "Off")
            Slider(value: $state.textSize, in: 0...1) {
                Text("Color Temperature")
            }
        }
        SettingsGroup("Lock Screen", .inline) {
            Picker("Auto-Lock", selection: $state.autoLock) {
                Text("30 Seconds").tag("30 Seconds")
                Text("1 Minute").tag("1 Minute")
                Text("2 Minutes").tag("2 Minutes")
                Text("3 Minutes").tag("3 Minutes")
                Text("4 Minutes").tag("4 Minutes")
                Text("5 Minutes").tag("5 Minutes")
                Text("Never").tag("Never")
            }
            Toggle(isOn: $state.raiseToWake) {
                Text("Raise to Wake")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
            Toggle(isOn: $state.alwaysOnDisplay) {
                Text("Always On Display")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
                .toggleStyle(.switch)
                .smallControlSizeOnMacOS()
        }
        SettingsGroup("Display", .inline) {
            Picker("Display Zoom", selection: $state.displayZoom) {
                Text("Default").tag("Default")
                Text("Larger Text").tag("Larger Text")
            }
        }
    }
}
