//
//  ProjectNavigatorNSOutlineView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/10/25.
//

import AppKit

final class ProjectNavigatorNSOutlineView: NSOutlineView, NSMenuItemValidation {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.window === window && window?.firstResponder === self else {
            return super.performKeyEquivalent(with: event)
        }

        if event.charactersIgnoringModifiers == "v"
            && event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command {
            guard let menu = menu as? ProjectNavigatorMenu else {
                return super.performKeyEquivalent(with: event)
            }
            menu.delegate?.menuNeedsUpdate?(menu)
            for fileItem in selectedRowIndexes.compactMap({ item(atRow: $0) as? CEWorkspaceFile }) {
                menu.item = fileItem
                menu.newFileFromClipboard()
            }
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(ProjectNavigatorMenu.newFileFromClipboard) {
            return !selectedRowIndexes.isEmpty
        }
        return false
    }

    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let row = row(at: point)
        let column = column(at: point)

        guard event.clickCount == 2 && row >= 0 && column >= 0,
              let rowView = view(atColumn: column, row: row, makeIfNecessary: false) as? NSTableCellView else {
            super.mouseDown(with: event)
            return
        }

        window?.makeFirstResponder(rowView.textField)
    }
}
