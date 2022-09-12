//
//  SwiftUIView.swift
//  
//
//  Created by Khan Winter on 9/9/22.
//

import SwiftUI
import CodeEditUI

/// View for displaying the navigation preferences. Loads and stores values in the global `AppPreferencesModel`
/// object.
public struct NavigationPreferencesView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var selectedFilePattern: String?

    public init() {}

    public var body: some View {
        PreferencesContent {
            hiddenFilesView
        }
    }

    /*
     Text("Hidden File Patterns")
     // swiftlint:disable line_length
     Text("Configure glob patterns for excluding files and folders. The project navigator decides which files and folders to show or hide based on this setting.")
         .lineLimit(nil)
         .font(.caption)
     */

    var hiddenFilesView: some View {
        VStack(alignment: .center, spacing: 16) {
            PreferencesSection("Hidden Files", hideLabels: false) {
                Toggle("Show Hidden Files", isOn: $prefs.preferences.navigation.showHiddenFiles)
            }
            .toggleStyle(.checkbox)
            PreferencesSection("Hidden File Patterns", hideLabels: false) {
                VStack(spacing: 0) {
                    List(prefs.preferences.navigation.hiddenFilePatterns,
                         id: \.self,
                         selection: $selectedFilePattern) { pattern in
                        Text(pattern)
                    }
                    .background(EffectView(.contentBackground))
                    .padding(0)
                    PreferencesToolbar {
                        HStack {
                            Button {

                            } label: {
                                Image(systemName: "plus")
                            }
                            .help("Add a new glob pattern")
                            .buttonStyle(.plain)
                            Button {

                            } label: {
                                Image(systemName: "minus")
                            }
                            // Disable the remove button when no glob is selected
                            .disabled(selectedFilePattern == nil)
                            .help("Remove the selected glob pattern")
                            .buttonStyle(.plain)
                            Spacer()
                        }
                    }
                }
                .padding(1)
                .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
                .frame(width: 400, height: 200)
                // swiftlint:disable line_length
                Text("Configure glob patterns for excluding files and folders. The project navigator decides which files and folders to show or hide based on this setting.")
                    .lineLimit(nil)
                    .font(.caption)
                    .frame(width: 400, alignment: .leading)
            }
        }
    }
}

struct NavigationPreferncesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationPreferencesView()
    }
}
