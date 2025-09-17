//
//  LanguageServerConfiguration.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/16/25.
//

import Foundation

enum LanguageServerConfiguration: Codable, Hashable {
    case exec(path: String, args: [String], env: [String: String]?)
    case registry(command: String)

    var execPath: String? {
        switch self {
        case .exec(let path, _, _):
            path
        case let .registry(command):
            command
        }
    }

    var args: [String] {
        switch self {
        case .exec(_, let args, _):
            args
        case .registry:
            []
        }
    }

    var env: [String: String] {
        switch self {
        case .exec(_, _, let env):
            env ?? [:]
        case .registry:
            [:]
        }
    }
}
