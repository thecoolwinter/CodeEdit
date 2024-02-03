//
//  RunTask.swift
//  CodeEdit
//
//  Created by Khan Winter on 2/2/24.
//

import Foundation
import AppKit

struct RunTask: Codable, Hashable {
    /// The variable to insert depending on the environment.
    struct Variable: Codable, Hashable {
        let insertPosition: Int
        let type: VariableType
        let value: [VariableValueKey: Data]
    }

    /// The type of variable.
    enum VariableType: String, Codable {
        case workspacePath
        case userPath
        case codeEditPath
        case settingsPath
    }

    /// Any additional data attached to a variable. Eg a path extending the ``VariableType/workspacePath`` variable.
    enum VariableValueKey: String, Codable {
        case pathExtension
    }

    let rawTask: String
    let inserts: Set<Variable>
    let environment: [String: String]

    public func buildExecutionString(workspace: WorkspaceDocument) -> String {
        var finalString = rawTask

        // Get all inserts ordered from the end of the string backwards
        let allInserts = inserts.sorted(by: { $0.insertPosition > $1.insertPosition })
        for insert in allInserts {
            let stringIdx = finalString.index(finalString.startIndex, offsetBy: insert.insertPosition)
            finalString.insert(contentsOf: "", at: stringIdx)
        }

        return finalString
    }

    private func resolveInsertedVariable(variable: Variable, workspace: WorkspaceDocument) -> String? {
        switch variable.type {
        case .workspacePath:
            guard var path = workspace.workspaceFileManager?.folderUrl.path() else { return nil }
            resolvePathExtension(variable, path: &path)
            return path
        case .userPath:
            var path = FileManager.default.homeDirectoryForCurrentUser.path()
            resolvePathExtension(variable, path: &path)
            return path
        case .codeEditPath:
            guard var path = NSRunningApplication.current.bundleURL?.path() else { return nil }
            resolvePathExtension(variable, path: &path)
            return path
        case .settingsPath:
            var path = Settings.shared.baseURL.path()
            resolvePathExtension(variable, path: &path)
            return path
        }
    }

    private func resolvePathExtension(_ variable: RunTask.Variable, path: inout String) {
        if let pathExtensionData = variable.value[.pathExtension],
           let pathExtension = String(data: pathExtensionData, encoding: .utf8) {
            if pathExtension.starts(with: "/") {
                path.append(pathExtension)
            } else {
                path.append("/" + pathExtension)
            }
        }
    }
}
