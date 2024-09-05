//
//  UtilityAreaTerminalSidebar.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/19/24.
//

import SwiftUI

/// The view that displays the list of available terminals in the utility area.
/// See ``UtilityAreaTerminalView`` for use.
struct UtilityAreaTerminalSidebar: View {
    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    var body: some View {
        List(selection: $utilityAreaViewModel.selectedTerminals) {
            ForEach(utilityAreaViewModel.terminals, id: \.self.id) { terminal in
                UtilityAreaTerminalTab(
                    terminal: terminal,
                    removeTerminals: utilityAreaViewModel.removeTerminals,
                    isSelected: utilityAreaViewModel.selectedTerminals.contains(terminal.id),
                    selectedIDs: utilityAreaViewModel.selectedTerminals
                )
                .tag(terminal.id)
                .listRowSeparator(.hidden)
            }
            .onMove { [weak utilityAreaViewModel] (source, destination) in
                utilityAreaViewModel?.moveItems(from: source, to: destination)
            }
        }
        .focusedObject(utilityAreaViewModel)
        .listStyle(.automatic)
        .accentColor(.secondary)
        .contextMenu {
            Button("New Terminal") {
                utilityAreaViewModel.addTerminal(workspace: workspace)
            }
            Menu("New Terminal With Profile") {
                Button("Default") {
                    utilityAreaViewModel.addTerminal(workspace: workspace)
                }
                Divider()
                ForEach(Shell.allCases, id: \.self) { shell in
                    Button(shell.rawValue) {
                        utilityAreaViewModel.addTerminal(shell: shell, workspace: workspace)
                    }
                }
            }
        }
        .onChange(of: utilityAreaViewModel.terminals) { newValue in
            if newValue.isEmpty {
                utilityAreaViewModel.addTerminal(workspace: workspace)
            }
        }
        .paneToolbar {
            PaneToolbarSection {
                Button {
                    utilityAreaViewModel.addTerminal(workspace: workspace)
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    utilityAreaViewModel.removeTerminals(utilityAreaViewModel.selectedTerminals)
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(utilityAreaViewModel.terminals.count <= 1)
                .opacity(utilityAreaViewModel.terminals.count <= 1 ? 0.5 : 1)
            }
            Spacer()
        }
    }
}

#Preview {
    UtilityAreaTerminalSidebar()
}