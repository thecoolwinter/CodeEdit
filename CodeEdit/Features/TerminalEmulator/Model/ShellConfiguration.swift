//
//  ShellConfiguration.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/29/24.
//

import Foundation

/// Represents all data necessary to start a shell.
struct ShellConfiguration {
    let profile: Shell
    let path: String?

    var isSh: Bool {
        switch profile {
        case .bash, .zsh:
            return true
        case .fish:
            return false
        }
    }

    /// Executes a shell command using a specified shell, with optional environment variables.
    ///
    /// - Parameters:
    ///   - process: The `Process` instance to be configured and run.
    ///   - command: The shell command to execute.
    ///   - environmentVariables: A dictionary of environment variables to set for the process. Default is `nil`.
    ///   - shell: The shell to use for executing the command. Default is `.bash`.
    ///   - outputPipe: The `Pipe` instance to capture standard output and standard error.
    /// - Throws: An error if the process fails to run.
    ///
    /// ### Example
    /// ```swift
    /// let process = Process()
    /// let outputPipe = Pipe()
    /// try executeCommandWithShell(
    ///     process: process,
    ///     command: "echo 'Hello, World!'",
    ///     environmentVariables: ["PATH": "/usr/bin"],
    ///     shell: ShellConfiguration(profile: .zsh, path: nil, useLogin: true),
    ///     outputPipe: outputPipe
    /// )
    /// let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    /// let outputString = String(data: outputData, encoding: .utf8)
    /// print(outputString) // Output: "Hello, World!"
    /// ```
    public static func executeCommandWithShell(
        process: Process,
        command: String,
        environmentVariables: [String: String]? = nil,
        shell: ShellConfiguration,
        outputPipe: Pipe
    ) throws {
        // Setup envs'
        process.environment = environmentVariables
        // Set the executable to bash
        guard let path = shell.path ?? shell.profile.defaultPath else {
            throw ShellExecError.noPath
        }
        process.executableURL = URL(fileURLWithPath: path)

        // Pass the command as an argument
        // `--login` argument is needed when using a shell with a process in Swift to ensure
        // that the shell loads the user's profile settings (like .bash_profile or .profile),
        // which configure the environment variables and other shell settings.
        process.arguments = ["--login", "-c", command]

        process.standardOutput = outputPipe
        process.standardError = outputPipe

        // Run the process
        try process.run()
    }

    enum ShellExecError: Swift.Error {
        case noPath
    }
}
