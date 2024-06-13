//
//  KeyMapView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/12/24.
//

import SwiftUI

extension TerminalSettingsView {
    typealias KeyMatch = SettingsData.TerminalSettings.KeyMatch
    typealias Modifiers = SettingsData.TerminalSettings.Modifiers

    struct KeyMapView: View {
        @State private var keyMap: [KeyMatch: String]

        @State private var selection: KeyMatch.ID?
        @State private var isNewItem: Bool = false
        @State private var editItem: KeyMatch?

        init() {
            self.keyMap = Settings.shared.preferences.terminal.keyMap
        }

        var body: some View {
            Table(keyMap.keys.sorted(by: <), selection: $selection) {
                TableColumn("Key", value: \.label)
                TableColumn("Text") {
                    Text(keyMap[$0] ?? "")
                }
            }
            .frame(minHeight: 96)
            .overlay {
                if keyMap.isEmpty {
                    Text("No key maps")
                        .foregroundStyle(Color(.secondaryLabelColor))
                }
            }
            .actionBar {
                Button {
                    isNewItem = true
                    editItem = KeyMatch(key: .f1, modifiers: [])
                } label: {
                    Image(systemName: "plus")
                }
                Divider()
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection == nil)
            }
            .onDeleteCommand {
                onDelete()
            }
            .onSubmit {
                onEdit()
            }
            .contextMenu(forSelectionType: KeyMatch.ID.self) { items in
                Button("Edit") {
                    onEdit(items.first)
                }
                Button("Remove") {
                    onDelete(items.first)
                }
            } primaryAction: { items in
                onEdit(items.first)
            }
            .sheet(item: $editItem) { editItem in
                KeyMapEditSheet(item: editItem, value: isNewItem ? nil : keyMap[editItem]) { keyMatch, value in
                    keyMap.removeValue(forKey: editItem)
                    keyMap[keyMatch] = value
                    selection = keyMatch.id
                }
                .onAppear {
                    isNewItem = false
                }
            }
            .onChange(of: keyMap) { newValue in
                Settings.shared.preferences.terminal.keyMap = newValue
            }
        }

        private func onDelete(_ selection: KeyMatch.ID? = nil) {
            let selection = selection ?? self.selection
            if let keyMapMatch = selection, let match = KeyMatch(id: keyMapMatch) {
                keyMap.removeValue(forKey: match)
            }
        }

        private func onEdit(_ selection: KeyMatch.ID? = nil) {
            let selection = selection ?? self.selection
            if let keyMapMatch = selection, let match = KeyMatch(id: keyMapMatch) {
                editItem = match
            }
        }
    }

    struct KeyMapEditSheet: View {
        @Environment(\.presentationMode)
        var presentationMode

        @AppSettings(\.terminal)
        var settings

        private let originalItem: KeyMatch

        @State private var key: SettingsData.TerminalSettings.Key
        @State private var modifiers: SettingsData.TerminalSettings.Modifiers
        @State private var value: String

        var onSave: (KeyMatch, String) -> Void

        init(item: KeyMatch, value: String?, onSave: @escaping ((KeyMatch, String) -> Void)) {
            self.originalItem = item
            self.key = item.key
            self.modifiers = item.modifiers
            self.value = value ?? ""
            self.onSave = onSave
        }

        var body: some View {
            Form {
                Picker("Key", selection: $key) {
                    ForEach(SettingsData.TerminalSettings.Key.allCases) { key in
                        Text(key.label).tag(key)
                    }
                }
                Picker("Modifiers", selection: $modifiers) {
                    Text("None").tag(Modifiers(rawValue: 0))
                    Text("^ Control").tag(Modifiers.ctrl)
                    Text("⌥ Option").tag(Modifiers.option)
                    Text("⇧ Shift").tag(Modifiers.shift)
                    Text("^⌥ Control-Option").tag(Modifiers([Modifiers.ctrl, Modifiers.option]))
                    Text("^⇧ Control-Shift").tag(Modifiers([Modifiers.ctrl, Modifiers.shift]))
                    Text("⌥⇧ Option-Shift").tag(Modifiers([Modifiers.option, Modifiers.shift]))
                    Text("^⌥⇧ Control-Option-Shift").tag(Modifiers([Modifiers.ctrl, Modifiers.option, Modifiers.shift]))
                }
                TextField("Inserted Text", text: $value)
                Text("Insert control characters using a backslash followed by 3 octal digits.")
                + Text("To insert a backslash, enter two backslashes.")
                HStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    Button {
                        let newKeyMatch = KeyMatch(key: key, modifiers: modifiers)

                        // If we're potentially overwriting an existing map, check w/ the user.
                        if settings.keyMap[newKeyMatch] != nil // Map exists
                            && newKeyMatch != originalItem // Not the same key as we started with
                            && !verifyOverwriteSetting() { // User didn't confirm
                            return
                        }

                        onSave(newKeyMatch, value)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
            .padding()
        }

        private func verifyOverwriteSetting() -> Bool {
            let alert = NSAlert()
            alert.messageText = "Overwrite Key Map"
            alert.informativeText = "A key map with this trigger already exists. Do you want to overwrite it?"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Overwrite")
            alert.addButton(withTitle: "Cancel")
            let response = alert.runModal()
            return response == .alertFirstButtonReturn
        }
    }
}
