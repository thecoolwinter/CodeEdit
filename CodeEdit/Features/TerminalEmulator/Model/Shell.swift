//
//  ShellIntegration.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/1/24.
//

import Foundation

/// Shells supported by CodeEdit
enum Shell: String, CaseIterable {
    case bash
    case zsh
    case fish

    var defaultPath: String? {
        switch self {
        case .bash:
            "/bin/bash"
        case .zsh:
            "/bin/zsh"
        case .fish:
            nil
        }
    }

    /// Gets the default shell from the current user and returns the string of the shell path.
    ///
    /// If getting the user's shell does not work, defaults to `zsh`,
    static func autoDetectDefaultShellPath() -> String {
        guard let currentUser = CurrentUser.getCurrentUser() else {
            return Self.zsh.defaultPath ?? "/bin/zsh" // macOS defaults to zsh
        }
        return currentUser.shell
    }
}
