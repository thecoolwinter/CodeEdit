//
//  PackageManagerType.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/12/25.
//

import Foundation

/// Package manager types supported by the system
enum PackageManagerType: String, Codable {
    /// JavaScript
    case npm
    /// Rust
    case cargo
    /// Go
    case golang
    /// Python
    case pip
    /// Ruby
    case gem
    /// C#
    case nuget
    /// OCaml
    case opam
    /// PHP
    case composer
    /// Building from source
    case sourceBuild
    /// Binary download
    case github

    var userDescription: String {
        switch self {
        case .npm:
            "NPM"
        case .cargo:
            "Cargo"
        case .golang:
            "Go"
        case .pip:
            "Pip"
        case .gem:
            "Gem"
        case .nuget:
            "Nuget"
        case .opam:
            "Opam"
        case .composer:
            "Composer"
        case .sourceBuild:
            "Build From Source"
        case .github:
            "Download From GitHub"
        }
    }

    func packageManager(installPath: URL) -> PackageManagerProtocol? {
        switch self {
        case .npm:
            return NPMPackageManager(installationDirectory: installPath)
        case .cargo:
            return CargoPackageManager(installationDirectory: installPath)
        case .pip:
            return PipPackageManager(installationDirectory: installPath)
        case .golang:
            return GolangPackageManager(installationDirectory: installPath)
        case .github, .sourceBuild:
            return GithubPackageManager(installationDirectory: installPath)
        case .nuget, .opam, .gem, .composer:
            // TODO: IMPLEMENT OTHER PACKAGE MANAGERS
            return nil
        }
    }
}
