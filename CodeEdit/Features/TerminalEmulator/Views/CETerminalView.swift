//
//  CETerminalView.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/12/24.
//

import Foundation
import AppKit
import SwiftTerm

protocol CETerminalViewDelegate: AnyObject {
    /// This method is invoked to notify that the terminal has been resized to the specified number of columns and rows
    /// the user interface code might try to adjust the containing scroll view, or if it is a top level window,
    /// the window itself
    /// - Parameter source: the sending instance
    /// - Parameter newCols: the new number of columns that should be shown
    /// - Parameter newRow: the new number of rows that should be shown
    func sizeChanged(source: CETerminalView, newCols: Int, newRows: Int)

    /// This method is invoked when the title of the terminal window should be updated to the provided title
    /// - Parameter source: the sending instance
    /// - Parameter title: the desired title
    func setTerminalTitle(source: CETerminalView, title: String)

    /// Invoked when the OSC command 7 for "current directory has changed" command is sent
    /// - Parameter source: the sending instance
    /// - Parameter directory: the new working directory
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?)

    /// This method will be invoked when the child process started by `startProcess` has terminated.
    /// - Parameter source: the local process that terminated
    /// - Parameter exitCode: the exit code returned by the process, or nil if this was an error caused during the IO reading/writing
    func processTerminated(source: TerminalView, exitCode: Int32?)
}

/// An `NSView` that hosts a local process. Based on ``SwiftTerm/MacLocalTerminalView`` and extended to support
/// certain functionality.
class CETerminalView: TerminalView, TerminalViewDelegate, LocalProcessDelegate {
    private var process: LocalProcess!
    public weak var processDelegate: CETerminalViewDelegate?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init? (coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        terminalDelegate = self
        process = LocalProcess(delegate: self)
    }

    // MARK: - Local Process Delegate

    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        guard process.running else {
            return
        }
        var size = getWindowSize()
        _ = PseudoTerminalHelpers.setWinSize(masterPtyDescriptor: process.childfd, windowSize: &size)

        processDelegate?.sizeChanged(source: self, newCols: newCols, newRows: newRows)
    }

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        processDelegate?.hostCurrentDirectoryUpdate(source: source, directory: directory)
    }

    func send(source: TerminalView, data: ArraySlice<UInt8>) {
        process.send(data: data)
    }

    func processTerminated(_ source: LocalProcess, exitCode: Int32?) {
        processDelegate?.processTerminated(source: self, exitCode: exitCode)
    }

    func dataReceived(slice: ArraySlice<UInt8>) {
        feed(byteArray: slice)
    }

    func getWindowSize() -> winsize {
        let terminal = getTerminal()
        return winsize(
            ws_row: UInt16(terminal.rows), 
            ws_col: UInt16(terminal.cols),
            ws_xpixel: UInt16(frame.width),
            ws_ypixel: UInt16(frame.height)
        )
    }

    // MARK: - TerminalViewDelegate

    func setTerminalTitle(source: TerminalView, title: String) {
        processDelegate?.setTerminalTitle(source: self, title: title)
    }

    func scrolled(source: TerminalView, position: Double) { }

    func clipboardCopy(source: TerminalView, content: Data) {
        guard let string = String(bytes: content, encoding: .utf8) else {
            return
        }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([string as NSString])
    }

    // MARK: - Process Management

    /// Launch a child process in a pseudo-terminal.
    /// - Parameters:
    ///   - executable: The path to the executable to run.
    ///   - args: Arguments to pass
    ///   - environment: The environment variables to use for the new process.
    ///   - execName: Used to set a different process name than the file that backs it.
    public func startProcess(
        executable: String,
        args: [String],
        environment: [String],
        execName: String? = nil
    ) {
        process.startProcess(executable: executable, args: args, environment: environment, execName: execName)
    }

    // MARK: - Keyboard Interaction

    override func interpretKeyEvents(_ eventArray: [NSEvent]) {
        super.interpretKeyEvents(eventArray)

        for event in eventArray {
            var modifiers = SettingsData.TerminalSettings.Modifiers()
            if event.modifierFlags.contains(.shift) {
                modifiers.insert(.shift)
            }
            if event.modifierFlags.contains(.control) {
                modifiers.insert(.ctrl)
            }
            if event.modifierFlags.contains(.option) {
                modifiers.insert(.option)
            }

            guard var key = SettingsData.TerminalSettings.Key(keyCode: Int(event.keyCode)) else {
                continue
            }

            if key == .delete && event.modifierFlags.contains(.function) {
                // forward delete
                key = .forwardDelete
            }

            let match = SettingsData.TerminalSettings.KeyMatch(key: key, modifiers: modifiers)

            if let string = Settings.shared.preferences.terminal.keyMap[match] {
                getTerminal().feed(byteArray: parseInsertedString(string))
            }
        }
    }

    private func parseInsertedString(_ string: String) -> [UInt8] {
        var array = [UInt8]()

        var octalCount = -1
        var octalString: String = ""
        for char in string {
            if octalCount > 2 {
                // 3 octal chars, parse it
                guard let escapeSequence = Int(octalString, radix: 0o10) else {
                    continue
                }

            } else if octalCount == 1 && char == #"\"# { // if \\ entered, exit the octal string.
                array.append(contentsOf: Array(#"\"#.utf8))
                octalCount = -1
            } else if octalCount >= 0 {
                octalString.append(char)
                octalCount += 1
            } else if char == #"\"# {
                octalCount = 0
            } else {
                array.append(contentsOf: Array(char.utf8))
            }
        }

        return array
    }
}
