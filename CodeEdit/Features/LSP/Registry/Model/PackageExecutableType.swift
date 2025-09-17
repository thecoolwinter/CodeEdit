//
//  PackageExecutableType.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/17/25.
//

import Foundation

/// Registry items can have some additional options in the `bin` string. This enum represents all the ways that
/// packages can be executed, and provides a method for creating a ``PackageExecutableProtocol`` that can resolve a
/// bin string after parsing.
///
/// Use the ``parse(binString:)`` to first resolve a ``PackageExecutableType`` from a resolved ``ExpressionString`` in
/// a ``RegistryItem``, then use the ``executableResolver(installPath:)`` to resolve the execution string using the
/// install path of the registry item.
enum PackageExecutableType {
    case cargo
    case npm
    case node
    case pip
    case gem
    case golang
    case composer

    /// Parse a `bin` string to determine if a package manager type should parse this string.
    /// - Parameter binString: The resolved expression string from a `bin` key-value.
    /// - Returns: The type that should parse this string, and the string that should be passed to the package manager.
    static func parse(binString: String) -> (PackageExecutableType, String)? {
        let split = binString.split(separator: ":")
        guard let identifier = split.first else { return nil }
        let string = split.dropFirst().joined(separator: ":") // add back in a : if we split more than one
        switch identifier {
        case "cargo":
            return (.cargo, string)
        case "npm":
            return (.npm, string)
        case "node":
            return (.node, string)
        case "pypi":
            return (.pip, string)
        case "gem":
            return (.gem, string)
        case "golang":
            return (.golang, string)
        case "composer":
            return (.composer, string)
        default:
            return nil
        }
    }

    func executableResolver(installPath: URL) -> PackageExecutableProtocol? {
        switch self {
        case .npm:
            return NPMPackageManager(installationDirectory: installPath)
        case .cargo:
            return CargoPackageManager(installationDirectory: installPath)
        case .pip:
            return PipPackageManager(installationDirectory: installPath)
        case .golang:
            return GolangPackageManager(installationDirectory: installPath)
        case .node:
            return nil // TODO: Node executable protocol (basically execute a node process)
        default:
            return nil
        }
    }
}
