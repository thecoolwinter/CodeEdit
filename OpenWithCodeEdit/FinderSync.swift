//
//  FinderSync.swift
//  openInCodeEdit
//
//  Created by Wesley de Groot on 03/05/2022.
//

/**
 * For anyone working on this file.
 * print does not output to the console, use NSLog.
 * open "console.app" to debug,
 */

import Cocoa
import FinderSync
import os.log

class CEOpenWith: FIFinderSync {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "FinderSync")

    override init() {
        super.init()
        // Add finder sync
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: nil,
            options: [.skipHiddenVolumes]
        ) {
            finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
        // Monitor volumes
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(
            forName: NSWorkspace.didMountNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let volumeURL = notification.userInfo?[NSWorkspace.volumeURLUserInfoKey] as? URL {
                finderSync.directoryURLs.insert(volumeURL)
            }
        }
    }

    /// Open in CodeEdit (menu) action
    /// - Parameter sender: sender
    @objc
    func openInCodeEditAction(_ sender: AnyObject?) {
        guard let items = FIFinderSyncController.default().selectedItemURLs() else {
            return
        }

        let openURLs = items.compactMap { URL(string: "codeedit://" + $0.absoluteURL.path(percentEncoded: false)) }

        guard let codeEdit = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "app.codeedit.CodeEdit") else {
            return
        }

        NSWorkspace.shared.open(
            openURLs,
            withApplicationAt: codeEdit,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }

    // MARK: - Menu and toolbar item support
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        guard let defaults = UserDefaults.init(suiteName: "app.codeedit.CodeEdit.shared") else {
            logger.error("Unable to load defaults")
            return NSMenu(title: "")
        }

        let menu = NSMenu(title: "")
        let menuItem = NSMenuItem(
            title: "Open in CodeEdit",
            action: #selector(openInCodeEditAction(_:)),
            keyEquivalent: ""
        )
        menuItem.image = NSImage.init(named: "icon")

        let enableOpenInCE = defaults.bool(forKey: "enableOpenInCE")
        logger.info("Enable Open In CodeEdit value is \(enableOpenInCE, privacy: .public)")
        if enableOpenInCE {
            menu.addItem(menuItem)
        }
        return menu
    }
}
