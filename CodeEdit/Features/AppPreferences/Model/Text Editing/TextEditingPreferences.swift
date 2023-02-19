//
//  TextEditingPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/08.
//

import AppKit
import Foundation

extension AppPreferences {

    /// The global settings for text editing
    struct TextEditingPreferences: Codable {
        enum IndentType: String, Codable {
            case spaces
            case tabs
        }

        /// An integer indicating how many indentation units a `tab` will generate
        var defaultTabWidth: Int = 4

        /// The number of spaces a tab will use, ignored if the indentUnit is a tab
        var indentWidth: Int = 4 {
            didSet {
                indentUnit = calculateIndentUnit()
            }
        }

        /// The unit of indentation to use.
        var indentType: IndentType = .spaces {
            didSet {
                indentUnit = calculateIndentUnit()
            }
        }

        /// The unit of indentation to use. Calculated using `intentType` and `indentWidth`.
        /// This will not need to be set manually, and will be re-calculated when `indentType` or `indentWidth` change.
        var indentUnit: String = ""

        /// The font to use in editor.
        var font: EditorFont = .init()

        /// A flag indicating whether type-over completion is enabled
        var enableTypeOverCompletion: Bool = true

        /// A flag indicating whether braces are automatically completed
        var autocompleteBraces: Bool = true

        /// A flag indicating whether to wrap lines to editor width
        var wrapLinesToEditorWidth: Bool = true

        /// A multiplier for setting the line height. Defaults to `1.45`
        var lineHeightMultiple: Double = 1.45

        /// Default initializer
        init() {
            self.populateCommands()
            indentUnit = calculateIndentUnit()
        }

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.defaultTabWidth = try container.decodeIfPresent(Int.self, forKey: .defaultTabWidth) ?? 4
            self.indentWidth = try container.decodeIfPresent(Int.self, forKey: .indentWidth) ?? 4
            self.indentType = try container.decodeIfPresent(IndentType.self, forKey: .indentType) ?? .spaces
            self.font = try container.decodeIfPresent(EditorFont.self, forKey: .font) ?? .init()
            self.enableTypeOverCompletion = try container.decodeIfPresent(
                Bool.self,
                forKey: .enableTypeOverCompletion
            ) ?? true
            self.autocompleteBraces = try container.decodeIfPresent(
                Bool.self,
                forKey: .autocompleteBraces
            ) ?? true
            self.wrapLinesToEditorWidth = try container.decodeIfPresent(
                Bool.self,
                forKey: .wrapLinesToEditorWidth
            ) ?? true
            self.lineHeightMultiple = try container.decodeIfPresent(
                Double.self,
                forKey: .lineHeightMultiple
            ) ?? 1.45

            self.populateCommands()
            indentUnit = calculateIndentUnit()
        }

        /// Adds toggle-able preferences to the command palette via shared `CommandManager`
        private func populateCommands() {
            let mgr = CommandManager.shared

            mgr.addCommand(
                name: "Toggle Type-Over Completion",
                title: "Toggle Type-Over Completion",
                id: "prefs.text_editing.type_over_completion",
                command: CommandClosureWrapper {
                    AppPreferencesModel.shared.preferences.textEditing.enableTypeOverCompletion.toggle()
                }
            )

            mgr.addCommand(
                name: "Toggle Autocomplete Braces",
                title: "Toggle Autocomplete Braces",
                id: "prefs.text_editing.autocomplete_braces",
                command: CommandClosureWrapper {
                    AppPreferencesModel.shared.preferences.textEditing.autocompleteBraces.toggle()
                }
            )

            mgr.addCommand(
                name: "Toggle Word Wrap",
                title: "Toggle Word Wrap",
                id: "prefs.text_editing.wrap_lines_to_editor_width",
                command: CommandClosureWrapper {
                    AppPreferencesModel.shared.preferences.textEditing.wrapLinesToEditorWidth.toggle()
                }
            )
        }

        private func calculateIndentUnit() -> String {
            return indentType == IndentType.spaces ? String(repeating: " ", count: max(1, indentWidth)) : "\t"
        }
    }

    struct EditorFont: Codable, Equatable {
        /// Indicates whether or not to use a custom font
        var customFont: Bool = false

        /// The font size for the custom font
        var size: Int = 12

        /// The name of the custom font
        var name: String = "SFMono-Medium"

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customFont = try container.decodeIfPresent(Bool.self, forKey: .customFont) ?? false
            self.size = try container.decodeIfPresent(Int.self, forKey: .size) ?? 11
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "SFMono-Medium"
        }

        /// Returns an NSFont representation of the current configuration.
        ///
        /// Returns the custom font, if enabled and able to be instantiated.
        /// Otherwise returns a default system font monospaced, size 12.
        func current() -> NSFont {
            guard customFont,
                  let customFont = NSFont(name: name, size: Double(size)) else {
                return NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            }
            return customFont
        }
    }
}
