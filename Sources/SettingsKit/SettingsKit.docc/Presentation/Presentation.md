# Presentation

> Recommended integration: use ``SettingsHost`` with app-owned navigation, layout, and toolbars. The complete styled presentation APIs and implicit container body are deprecated but remain available for compatibility. Examples of `SettingsView` and `SettingsStyle` below describe the legacy integration. See <doc:CustomPresentation>.


Choose a built-in settings interface or integrate the same runtime into your app’s own layout.

@Options {
    @TopicsVisualStyle(detailedGrid)
}

## Overview

Use ``SettingsHost`` to own navigation, tabs, toolbars, and layout. Style groups independently with ``SettingsGroupStyle``. The sidebar and single-column styles are legacy compatibility APIs.

## Topics

### Build an Interface

- <doc:CustomPresentation>
- ``SettingsKit/SettingsView``
- ``SettingsKit/SettingsHost``
- ``SettingsKit/SettingsPresentationContext``

### Style Settings

- <doc:StylingSettings>
- ``SettingsKit/SettingsStyle``
- ``SettingsKit/SettingsGroupStyle``
- ``SettingsKit/SettingsContainerConfiguration``
- ``SettingsKit/SettingsGroupConfiguration``

### Configure Built-in Navigation

- <doc:IntroductionAndTitles>
- ``SettingsKit/SettingsSearchPlacement``
- ``SettingsKit/SidebarSettingsStyle``
- ``SettingsKit/SingleColumnSettingsStyle``
