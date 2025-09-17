//
//  PackageExecutableProtocol.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/17/25.
//

protocol PackageExecutableProtocol {
    /// Gets the location of the binary that was installed
    func getRunCommand(for package: String) -> String
}
