//
//  ShortcutMetadata.swift
//  SettingsKit
//
//  Created by Aether on 11/17/25.
//


import SwiftUI

// MARK: - Models

enum ColorMode: String, CaseIterable, Hashable {
    case base = "Base"
    case dark = "Dark"
    case system = "System"
}

struct ShortcutMetadata: Identifiable {
    let id: String
    let name: String
    let iconColor: Int64
    let iconGlyph: Int64
    let iconURL: String?
    let iCloudLink: String
}

extension ShortcutMetadata {
    private static let colorMap: [Int64: (baseTop: String, baseBottom: String, darkTop: String, darkBottom: String)] = [
        4282601983: ("eb7677", "e16667", "bc5f5f", "b45252"),     // Red
        12365313: ("eb7677", "e16667", "bc5f5f", "b45252"),       // Red (alt)
        43634177: ("f09979", "ed8566", "c07a61", "be6a52"),       // Dark orange
        4251333119: ("f09979", "ed8566", "c07a61", "be6a52"),     // Dark orange (alt) -> Orange
        4271458815: ("f4ba66", "eba755", "c39552", "bc8644"),     // Orange -> Orange-Yellow
        23508481: ("f4ba66", "eba755", "c39552", "bc8644"),       // Orange (alt) -> Orange-Yellow
        4274264319: ("f6d947", "e7c63b", "c5ae39", "b99e2f"),     // Yellow
        20702977: ("f6d947", "e7c63b", "c5ae39", "b99e2f"),       // Yellow (alt)
        4292093695: ("6fd670", "60c35f", "599e58", "4d9c4c"),     // Green
        2873601: ("6fd670", "60c35f", "599e58", "4d9c4c"),        // Green (alt)
        431817727: ("5be0c1", "3ccaac", "49b39a", "30a289"),      // Teal
        1440408063: ("95defb", "80c9ed", "78b2c7", "66a1bd"),     // Light blue
        463140863: ("509ef8", "438df7", "407ec6", "366fc5"),      // Blue
        946986751: ("627bd7", "4d66c3", "4f629c", "3e529c"),      // Dark blue -> Deep-Blue-Purple
        2071128575: ("8c63c8", "774eb3", "704f9f", "5f3e90"),     // Dark purple -> Purple
        3679049983: ("bf87f0", "aa72da", "996bbf", "885bae"),     // Light purple -> Magenta
        61591313: ("bf87f0", "aa72da", "996bbf", "885bae"),       // Light purple (alt) -> Magenta
        314141441: ("ee96de", "e184cb", "be78ae", "b369a2"),      // Pink
        3980825855: ("ee96de", "e184cb", "be78ae", "b369a2"),     // Pink (alt)
        255: ("96a0a9", "848d97", "78818a", "6a7179"),            // Dark gray -> Gray
        1263359489: ("96a0a9", "848d97", "78818a", "6a7179"),     // Gray
        3031607807: ("aec3b0", "98ad9a", "899c8b", "7a8a7c"),     // Gray (alt) -> Green-Gray
        1448498689: ("cdb799", "baa487", "a4916e", "96836c"),     // Brown -> Light Brown
        2846468607: ("cdb799", "baa487", "a4916e", "96836c"),     // Brown (alt) -> Light Brown
    ]

    func gradient(mode: ColorMode = .base) -> LinearGradient {
        // Normalize negative values by taking absolute value
        let normalizedColor = abs(iconColor)

        guard let colors = Self.colorMap[normalizedColor] else {
            return LinearGradient(colors: [.gray], startPoint: .bottom, endPoint: .top)
        }
        
        let topColor: Color
        let bottomColor: Color
        
        switch mode {
        case .base:
            topColor = Color(hex: colors.baseTop)
            bottomColor = Color(hex: colors.baseBottom)
        case .dark:
            topColor = Color(hex: colors.darkTop)
            bottomColor = Color(hex: colors.darkBottom)
        case .system:
            topColor = Color(lightHex: colors.baseTop, darkHex: colors.darkTop)
            bottomColor = Color(lightHex: colors.baseBottom, darkHex: colors.darkBottom)
        }
        
        return LinearGradient(
            colors: [bottomColor, topColor],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

extension Color {
    init(lightHex: String, darkHex: String) {
#if canImport(UIKit)
        self.init(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(hex: darkHex)
            } else {
                return UIColor(hex: lightHex)
            }
        })
#else
        self.init(NSColor(name: nil) { appearance in
            if appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return NSColor(hex: darkHex)
            } else {
                return NSColor(hex: lightHex)
            }
        })
#endif
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}
#else
extension NSColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}
#endif

// MARK: - API Response Structures

struct CloudKitResponse: Codable {
    let recordName: String
    let fields: Fields
    
    struct Fields: Codable {
        let name: ValueWrapper<String>
        let icon_color: ValueWrapper<Int64>
        let icon_glyph: ValueWrapper<Int64>
        let icon: IconAsset?
        
        struct ValueWrapper<T: Codable>: Codable {
            let value: T
        }
        
        struct IconAsset: Codable {
            let value: AssetValue
            
            struct AssetValue: Codable {
                let downloadURL: String
            }
        }
    }
}

// MARK: - Service

struct ShortcutMetadataService {
    func fetchMetadata(from iCloudLink: String) async throws -> ShortcutMetadata {
        // Extract shortcut ID from URL
        guard let shortcutID = extractShortcutID(from: iCloudLink) else {
            throw URLError(.badURL)
        }
        
        // Build API URL
        let apiURL = "https://www.icloud.com/shortcuts/api/records/\(shortcutID)"
        
        guard let url = URL(string: apiURL) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let cloudKitResponse = try JSONDecoder().decode(CloudKitResponse.self, from: data)
        
        return ShortcutMetadata(
            id: cloudKitResponse.recordName,
            name: cloudKitResponse.fields.name.value,
            iconColor: cloudKitResponse.fields.icon_color.value,
            iconGlyph: cloudKitResponse.fields.icon_glyph.value,
            iconURL: cloudKitResponse.fields.icon?.value.downloadURL,
            iCloudLink: normalizeShortcutURL(iCloudLink)
        )
    }
    
    private func extractShortcutID(from link: String) -> String? {
        // Extract the ID from URLs like:
        // https://www.icloud.com/shortcuts/e6d68e32ffad4e39b3e43940c030db3b
        // or https://www.icloud.com/shortcuts/api/records/e6d68e32ffad4e39b3e43940c030db3b
        guard let url = URL(string: link) else { return nil }
        let path = url.path
        
        // If it's an API URL, extract the ID after "records/"
        if path.contains("/api/records/") {
            return path.components(separatedBy: "/api/records/").last
        }
        
        // Otherwise just get the last path component
        return url.lastPathComponent
    }
    
    private func normalizeShortcutURL(_ link: String) -> String {
        // Convert API URLs back to regular iCloud links
        // from: https://www.icloud.com/shortcuts/api/records/ABC123
        // to: https://www.icloud.com/shortcuts/ABC123
        if link.contains("/api/records/") {
            if let shortcutID = extractShortcutID(from: link) {
                return "https://www.icloud.com/shortcuts/\(shortcutID)"
            }
        }
        return link
    }
}

// MARK: - Views

public struct ShortcutsGalleryView: View {
    @StateObject private var viewModel = ShortcutGalleryViewModel()
    @State private var colorMode: ColorMode = .base
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]
    
    public init(){}
    
    public var body: some View {
        TabView {
            NavigationStack {
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading shortcuts...")
                    } else if viewModel.shortcuts.isEmpty {
                        Text("No shortcuts loaded")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.shortcuts) { shortcut in
                                    ShortcutCardView(shortcut: shortcut, colorMode: colorMode)
                                        .onTapGesture {
                                            print("Name: \(shortcut.name)")
                                            print("iconColor: \(shortcut.iconColor)")
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Shortcuts Gallery")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Reload") {
                            Task {
                                await viewModel.loadShortcuts()
                            }
                        }
                    }
                    ToolbarItem(placement: .automatic) {
                        Picker("Color Mode", selection: $colorMode) {
                            ForEach(ColorMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .task {
                    await viewModel.loadShortcuts()
                }
            }
            .tabItem {
                Label("Gallery", systemImage: "square.grid.2x2")
            }
            
            ColorMappingDebugView()
                .tabItem {
                    Label("Colors", systemImage: "paintpalette")
                }
        }
    }
}

struct ShortcutCardView: View {
    let iCloudLink: String
    let colorMode: ColorMode
    @State private var shortcut: ShortcutMetadata?
    @State private var iconImage: Image?
    
    init(shortcut: ShortcutMetadata, colorMode: ColorMode = .system) {
        self.iCloudLink = shortcut.iCloudLink
        self.colorMode = colorMode
        self._shortcut = State(initialValue: shortcut)
    }
    
    init(shortcut: Shortcut, colorMode: ColorMode = .system) {
        self.iCloudLink = shortcut.iCloudLink
        self.colorMode = colorMode
        // Shortcut only has iCloudLink, so we always need to fetch metadata
        self._shortcut = State(initialValue: nil)
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading) {
                // Icon in top-left - reserve space even if no image
                Group {
                    if let iconImage = iconImage {
                        iconImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        Color.clear
                    }
                }
                .frame(width: 25, height: 25)
                .clipShape(.rect(cornerRadius: 6))
                
                Spacer()
                
                // Shortcut name at bottom
                let name = shortcut?.name ?? ""
                Text(name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            
            .aspectRatio(1.5, contentMode: .fit)
            .background(shortcut?.gradient(mode: colorMode))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            
        }
        .task {
            await loadMetadataAndIcon()
        }
    }
    
    private func loadMetadataAndIcon() async {
        // Add a small random delay to stagger API requests
        try? await Task.sleep(nanoseconds: UInt64.random(in: 100_000_000...500_000_000)) // 0.1-0.5 seconds
        
        // Fetch metadata if we don't have it
        if shortcut == nil {
            do {
                let service = ShortcutMetadataService()
                let metadata = try await service.fetchMetadata(from: iCloudLink)
                shortcut = metadata
            } catch {
                print("Failed to fetch metadata for \(iCloudLink): \(error)")
                return
            }
        }
        
        // Now load the icon
        guard let iconURLString = shortcut?.iconURL,
              let url = URL(string: iconURLString) else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
#if os(iOS)
            if let uiImage = UIImage(data: data) {
                iconImage = Image(uiImage: uiImage)
            }
#else
            if let nsImage = NSImage(data: data) {
                iconImage = Image(nsImage: nsImage)
            }
#endif
        } catch {
            print("Failed to load icon: \(error)")
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ShortcutGalleryViewModel: ObservableObject {
    @Published var shortcuts: [ShortcutMetadata] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service = ShortcutMetadataService()
    
    // Add your shortcut URLs here!
    let shortcutLinks = [
        "https://www.icloud.com/shortcuts/f00836becd2845109809720d2a70e32f",
        "https://www.icloud.com/shortcuts/d598f4dc52d9469f9161b302f1257350",
        "https://www.icloud.com/shortcuts/51a9b025884545e7b7a4c9f3d3c86e35",
        "https://www.icloud.com/shortcuts/85cff63584314ae48ad2c7a8bacc1733",
        "https://www.icloud.com/shortcuts/19a26fc124ec413788a4a72720e58b6f",
        "https://www.icloud.com/shortcuts/005a1482aa654f1cb874fd6443b0593a",
        "https://www.icloud.com/shortcuts/bb87343631e84c2bb1f4dabf46e4aae2",
        "https://www.icloud.com/shortcuts/891705370975472b880c72860a05b221",
        "https://www.icloud.com/shortcuts/7557e130f1be4ceba01e69e6b065bacf"
    ]
    //
    func loadShortcuts() async {
        isLoading = true
        shortcuts = []
        error = nil
        defer { isLoading = false }
        
        // Sequential fetching for now to debug
        for link in shortcutLinks {
            do {
                let metadata = try await service.fetchMetadata(from: link)
                shortcuts.append(metadata)
                
                // Log the shortcut info
                let colorName = getColorName(for: metadata.iconColor)
                print("📱 '\(metadata.name)' -> \(colorName) (iconColor: \(metadata.iconColor))")
            } catch {
                print("Failed to fetch \(link): \(error)")
            }
        }
        
        // Sort by name
        shortcuts.sort { $0.name < $1.name }
    }
    
    private func getColorName(for iconColor: Int64) -> String {
        let colorNames: [Int64: String] = [
            4282601983: "Red",
            43634177: "Dark orange",
            4271458815: "Orange",
            4274264319: "Yellow",
            4292093695: "Green",
            431817727: "Teal",
            1440408063: "Light blue",
            463140863: "Blue",
            946986751: "Dark blue",
            2071128575: "Dark purple",
            3679049983: "Light purple",
            314141441: "Pink",
            255: "Dark gray",
            1263359489: "Gray",
            1448498689: "Brown",
            2873601: "Green (alt)",
            12365313: "Red (alt)",
            20702977: "Yellow (alt)",
            23508481: "Orange (alt)",
            61591313: "Light purple (alt)",
            2846468607: "Brown (alt)",
            3031607807: "Gray (alt)",
            3980825855: "Pink (alt)",
            4251333119: "Dark orange (alt)",
        ]
        
        return colorNames[iconColor] ?? "Unknown (\(iconColor))"
    }
}

// MARK: - Color Mapping Debug View

struct ColorMappingDebugView: View {
    let colorMappings: [(value: Int64, name: String, baseTop: String, baseBottom: String, darkTop: String, darkBottom: String)] = [
        (4282601983, "Red", "eb7677", "e16667", "bc5f5f", "b45252"),
        (12365313, "Red (alt)", "eb7677", "e16667", "bc5f5f", "b45252"),
        (43634177, "Dark orange", "f09979", "ed8566", "c07a61", "be6a52"),
        (4251333119, "Dark orange (alt)", "f09979", "ed8566", "c07a61", "be6a52"),
        (4271458815, "Orange", "f4ba66", "eba755", "c39552", "bc8644"),
        (23508481, "Orange (alt)", "f4ba66", "eba755", "c39552", "bc8644"),
        (4274264319, "Yellow", "f6d947", "e7c63b", "c5ae39", "b99e2f"),
        (20702977, "Yellow (alt)", "f6d947", "e7c63b", "c5ae39", "b99e2f"),
        (4292093695, "Green", "6fd670", "60c35f", "599e58", "4d9c4c"),
        (2873601, "Green (alt)", "6fd670", "60c35f", "599e58", "4d9c4c"),
        (431817727, "Teal", "5be0c1", "3ccaac", "49b39a", "30a289"),
        (1440408063, "Light blue", "95defb", "80c9ed", "78b2c7", "66a1bd"),
        (463140863, "Blue", "509ef8", "438df7", "407ec6", "366fc5"),
        (946986751, "Dark blue", "627bd7", "4d66c3", "4f629c", "3e529c"),
        (2071128575, "Dark purple", "8c63c8", "774eb3", "704f9f", "5f3e90"),
        (3679049983, "Light purple", "bf87f0", "aa72da", "996bbf", "885bae"),
        (61591313, "Light purple (alt)", "bf87f0", "aa72da", "996bbf", "885bae"),
        (314141441, "Pink", "ee96de", "e184cb", "be78ae", "b369a2"),
        (3980825855, "Pink (alt)", "ee96de", "e184cb", "be78ae", "b369a2"),
        (255, "Dark gray", "96a0a9", "848d97", "78818a", "6a7179"),
        (1263359489, "Gray", "96a0a9", "848d97", "78818a", "6a7179"),
        (3031607807, "Gray (alt)", "aec3b0", "98ad9a", "899c8b", "7a8a7c"),
        (1448498689, "Brown", "cdb799", "baa487", "a4916e", "96836c"),
        (2846468607, "Brown (alt)", "cdb799", "baa487", "a4916e", "96836c"),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
                ], spacing: 16) {
                    ForEach(colorMappings, id: \.value) { mapping in
                        VStack(alignment: .leading, spacing: 8) {
                            // Base and Dark gradient swatches
                            HStack(spacing: 8) {
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(
                                            colors: [Color(hex: mapping.baseBottom), Color(hex: mapping.baseTop)],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        ))
                                        .frame(height: 60)
                                    
                                    Text("Base")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LinearGradient(
                                            colors: [Color(hex: mapping.darkBottom), Color(hex: mapping.darkTop)],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        ))
                                        .frame(height: 60)
                                    
                                    Text("Dark")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mapping.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text("\(mapping.value)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("B: #\(mapping.baseBottom) → #\(mapping.baseTop)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("D: #\(mapping.darkBottom) → #\(mapping.darkTop)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .cornerRadius(12)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Color Mappings")
        }
    }
    
    func rgbString(for hex: String) -> String {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0x00FF00) >> 8
        let b = rgbValue & 0x0000FF
        
        return "RGB(\(r), \(g), \(b))"
    }
}

// MARK: - Preview

#Preview("Gallery") {
    ShortcutsGalleryView()
}

#Preview("Color Mappings") {
    ColorMappingDebugView()
}
