//
//  RunTaskRunner.swift
//  CodeEdit
//
//  Created by Khan Winter on 2/2/24.
//

import Foundation
import AppKit

class RunTaskRunner {
    private let shellClient: ShellClient
    private weak var workspace: WorkspaceDocument?

    private var runningTasks: [RunTask: Process] = [:]

    init(shellClient: ShellClient, workspace: WorkspaceDocument) {
        self.shellClient = shellClient
        self.workspace = workspace
    }

    func runTask(_ task: RunTask) throws -> AsyncThrowingStream<String, Swift.Error> {
        guard let workspace else {
            throw Error.missingWorkspace
        }

        guard runningTasks[task] == nil else {
            throw Error.taskRunning
        }

        let taskString = task.buildExecutionString(workspace: workspace)

        let (process, pipe) = shellClient.generateProcessAndPipe([taskString])
        process.terminationHandler = { [weak self] _ in
            self?.runningTasks[task] = nil
        }

        return shellClient.buildAsyncStream(task: process, pipe: pipe)
    }

    func cancelTask(_ task: RunTask) {
        runningTasks[task]?.terminate()
    }

    enum Error: Swift.Error {
        case missingWorkspace
        case taskRunning
    }
}
