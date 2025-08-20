//
//  LanguageServerConfiguration.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/19/25.
//

import Foundation
import JSONRPC
import ProcessEnv

/// Represents a language server binary.
struct LanguageServerConfiguration: Equatable, Hashable, Codable {
    enum ExecType: Equatable, Hashable, Codable {
        case executable(path: String)
        case shellCommand(command: String)

        /// The path to execute
        var path: String {
            switch self {
            case .executable(let path):
                path
            case .shellCommand(let command):
                "/bin/zsh"
            }
        }

        var args: [String] {
            switch self {
            case .executable:
                []
            case .shellCommand(let command):
                [command]
            }
        }
    }

    /// The execution type of this language server.
    let exec: ExecType

    /// Basically an "Any" type, user configuration
    let initializationOptions: JSONValue?

    /// The arguments to pass to the language server binary.
    let args: [String]

    /// Any environment variables to pass to the language server binary.
    let env: [String: String]?

    func processParameters(forDir url: URL?) -> Process.ExecutionParameters {
        Process.ExecutionParameters(
            path: exec.path,
            arguments: exec.args + args,
            environment: env,
            currentDirectoryURL: url
        )
    }
}
