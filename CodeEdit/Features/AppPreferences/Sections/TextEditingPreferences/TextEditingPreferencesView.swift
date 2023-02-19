//
//  TextEditingPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `Text Editing` preference section
struct TextEditingPreferencesView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// only allows integer values in the range of `[1...8]`
    private var tabWidthFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 100

        return formatter
    }

    /// only allows float values in the range of `[0.75...2.00]`
    /// and formats to 2 decimal places.
    private var lineHeightFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.minimum = 0.75
        formatter.maximum = 2.0

        return formatter
    }

    var body: some View {
        PreferencesContent {
            PreferencesSection("Prefer Indent Using") {
                indentSection
            }
            PreferencesSection("Tab Width") {
                tabWidth
            }
            PreferencesSection("Font") {
                fontSelector
            }
            PreferencesSection("Line Height") {
                lineHeight
            }
            PreferencesSection("Code completion") {
                autocompleteBraces
                enableTypeOverCompletion
            }
            PreferencesSection("Line Wrapping") {
                wrapLinesToEditorWidth
            }
        }
    }

    @ViewBuilder
    private var indentSection: some View {
        Picker("Prefer Indent Using:", selection: $prefs.preferences.textEditing.indentType) {
            Text("Tabs").tag(AppPreferences.TextEditingPreferences.IndentType.tabs)
            Text("Spaces").tag(AppPreferences.TextEditingPreferences.IndentType.spaces)
        }
        if prefs.preferences.textEditing.indentType == .spaces {
            HStack(spacing: 5) {
                TextField("", value: $prefs.preferences.textEditing.indentWidth, formatter: tabWidthFormatter)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 40)
                Stepper(
                    "Indent Width:",
                    value: $prefs.preferences.textEditing.indentWidth,
                    in: 1...100
                )
                Text("spaces")
            }
            .help("The number of spaces to use in an indent.")
        }
    }

    @ViewBuilder
    private var tabWidth: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.preferences.textEditing.defaultTabWidth, formatter: tabWidthFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Tab Width:",
                value: $prefs.preferences.textEditing.defaultTabWidth,
                in: 1...100
            )
            Text("spaces")
        }
        .disabled(true)
        .help("The visual width of tab characters.")
    }

    @ViewBuilder
    private var fontSelector: some View {
        Picker("Font:", selection: $prefs.preferences.textEditing.font.customFont) {
            Text("System Font")
                .tag(false)
            Text("Custom")
                .tag(true)
        }
        .fixedSize()
        if prefs.preferences.textEditing.font.customFont {
            FontPicker(
                "\(prefs.preferences.textEditing.font.name) \(prefs.preferences.textEditing.font.size)",
                name: $prefs.preferences.textEditing.font.name, size: $prefs.preferences.textEditing.font.size
            )
        }
    }

    private var autocompleteBraces: some View {
        HStack {
            Toggle("Autocomplete braces", isOn: $prefs.preferences.textEditing.autocompleteBraces)
            Text("Automatically insert closing braces (\"}\")")
        }
    }

    private var enableTypeOverCompletion: some View {
        HStack {
            Toggle("Enable type-over completion", isOn: $prefs.preferences.textEditing.enableTypeOverCompletion)
            Text("Enable type-over completion")
        }
    }

    private var wrapLinesToEditorWidth: some View {
        HStack {
            Toggle("Wrap lines to editor width", isOn: $prefs.preferences.textEditing.wrapLinesToEditorWidth)
            Text("Wrap lines to editor width")
        }
    }

    private var lineHeight: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.preferences.textEditing.lineHeightMultiple, formatter: lineHeightFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Line Height:",
                value: $prefs.preferences.textEditing.lineHeightMultiple,
                in: 0.75...2.0,
                step: 0.05
            )
        }
    }
}
