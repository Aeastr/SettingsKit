# ``SettingsKit``

Build settings pages that users can navigate and search while interacting with your app’s live SwiftUI controls.

@Options {
    @TopicsVisualStyle(detailedGrid)
}

## Overview

Declare a hierarchy with ``SettingsContainer`` and ``SettingsGroup``, then opt individual controls into search with an `indexed` modifier. Your app owns values, persistence, validation, and actions; SettingsKit supplies the semantic hierarchy, indexing, search, and live content.

Use ``SettingsHost`` as the recommended entry point, with navigation, toolbars, and layout owned by your app. The complete styled ``SettingsView`` integration is deprecated and retained for compatibility. Begin with <doc:Essentials>, then explore composition, search, and presentation as needed.

## Topics

### Start Here

- <doc:Essentials>

### Build Your Settings Interface

- <doc:Composition>
- <doc:Search>
- <doc:Presentation>

### Understand the Runtime

- <doc:Architecture>
