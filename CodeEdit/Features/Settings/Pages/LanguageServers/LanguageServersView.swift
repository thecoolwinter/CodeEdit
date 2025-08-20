//
//  ExtensionsSettingsView.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import SwiftUI

/// Displays a searchable list of packages from the ``RegistryManager``.
struct LanguageServersView: View {
    enum Mode {
        case configured
        case install
    }

    @AppSettings(\.languageServers.installedLanguageServers)
    private var installedLanguageServers: [SettingsData.InstalledLanguageServer]

    @StateObject var registryManager: RegistryManager = .shared

    @StateObject private var searchModel = FuzzySearchUIModel<RegistryItem>()
    @State private var searchText: String = ""

    @State private var listMode: Mode = .install
    @State private var selectedInstall: PackageManagerInstallOperation?

    var body: some View {
        Group {
            SettingsForm {
                if !registryManager.installedLanguageServers.isEmpty {
                    Picker("", selection: $listMode) {
                        Text("Installed").tag(Mode.install)
                        Text("Search").tag(Mode.configured)
                    }
                }

                switch listMode {
                case .configured:
                    configuredList
                case .install:
                    installList
                }
            }
            .sheet(item: $selectedInstall) { operation in
                LanguageServerInstallView(operation: operation)
            }
        }
        .environmentObject(registryManager)
    }

    @ViewBuilder private var configuredList: some View {
        Section {
//            List(installedLanguageServers) { server in
//
//            }
        }
    }

    @ViewBuilder private var installList: some View {
        if registryManager.isDownloadingRegistry {
            HStack {
                Spacer()
                ProgressView()
                    .controlSize(.small)
                Spacer()
            }
        }

        Section {
            List(searchModel.items ?? registryManager.registryItems, id: \.name) { item in
                LanguageServerRowView(
                    package: item,
                    onCancel: {
                        registryManager.cancelInstallation()
                    },
                    onInstall: { [item] in
                        do {
                            selectedInstall = try registryManager.installOperation(package: item)
                        } catch {
                            // Display the error
                            NSAlert(error: error).runModal()
                        }
                    }
                )
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                searchModel.searchTextUpdated(searchText: newValue, allItems: registryManager.registryItems)
            }
        }
    }
}
