//
//  OutputSourceModel.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/18/24.
//

import Foundation
import Combine
import LogStream
import OSLog
import DequeModule

struct LogMessage: Sendable {
    /// The log message string.
    let message: String

    /// The date and time when the log message was captured.
    let date: Date

    /// The subsystem associated with the log message, if available.
    let subsystem: String?

    /// The category associated with the log message, if available.
    let category: String?

    /// The type of the log message, indicating its severity level.
    let level: OSLogEntryLog.Level

    /// The name of the process that generated the log message.
    let process: String

    /// The process identifier (PID) of the process that generated the log message.
    let processID: pid_t
}

extension OSLogEntry {
    func logMessage() -> LogMessage {
        if let fullEntry = self as? OSLogEntryLog {
            return LogMessage(
                message: fullEntry.composedMessage,
                date: fullEntry.date,
                subsystem: fullEntry.subsystem,
                category: fullEntry.category,
                level: fullEntry.level,
                process: fullEntry.process,
                processID: fullEntry.processIdentifier
            )
        } else {
            return LogMessage(
                message: self.composedMessage,
                date: self.date,
                subsystem: nil,
                category: nil,
                level: .undefined,
                process: "",
                processID: getpid()
            )
        }
    }
}

class OutputSource: ObservableObject, Identifiable, Hashable {
    @Published var logs: [LogMessage] = []

    open func beginStreaming() async throws { }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: OutputSource, rhs: OutputSource) -> Bool {
        lhs.id == rhs.id
    }
}

class ExtensionOutputSource: OutputSource {
    var id: String { extensionInfo.id }

    private var extensionInfo: ExtensionInfo

    init(extensionInfo: ExtensionInfo) {
        self.extensionInfo = extensionInfo
        super.init()
    }

    override func beginStreaming() async throws {
        for await entry in LogStream.logs(for: extensionInfo.pid, flags: [.info, .historical, .processOnly]) {
            guard !Task.isCancelled else { return }
            let level: OSLogEntryLog.Level
            switch entry.type {
            case .debug:
                level = .debug
            case .info:
                level = .info
            case .default:
                level = .notice
            case .error:
                level = .error
            case .fault:
                level = .fault
            default:
                level = .undefined
            }
            logs.append(
                LogMessage(
                    message: entry.message,
                    date: entry.date,
                    subsystem: entry.subsystem,
                    category: entry.category,
                    level: level,
                    process: entry.process,
                    processID: entry.processID
                )
            )
        }
    }
}

class SubsystemOutputSource: OutputSource {
    private let lock = NSLock()
    private let store: OSLogStore
    private let subsystem: String

    init(subsystem: String) throws {
        self.store = try OSLogStore(scope: .currentProcessIdentifier)
        self.subsystem = subsystem
        super.init()
    }

    override func beginStreaming() async throws {
        for try await entry in asyncStream {
            guard !Task.isCancelled else { return }
            logs.append(entry)
        }
    }

    private var predicate: NSPredicate {
        NSPredicate(format: "", subsystem)
    }

    private var asyncStream: AsyncThrowingStream<LogMessage, Error> {
        AsyncThrowingStream { continuation -> Void in
            let predicate = self.predicate
            let task = Task {
                do {
                    var lastPosition = store.position(timeIntervalSinceLatestBoot: 0.0)
                    while true {
                        let entries = try store.getEntries(at: lastPosition, matching: predicate)
                        for entry in entries {
                            continuation.yield(entry.logMessage())
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

//    struct AsyncOSLogStoreSequence:  {
//        typealias Element = LogMessage
//
//        let store: OSLogStore
//        private var lastPosition: OSLogPosition
//        private var queue: Deque<LogMessage> = []
//
//        init(store: OSLogStore, lastPosition: OSLogPosition) {
//            self.store = store
//            self.lastPosition = lastPosition
//        }
//
//        mutating func next() async throws -> Element? {
//            if queue.isEmpty {
//                // Attempt to queue more items.
//                let entries =
//            } else {
//                return queue.popFirst()
//            }
//        }
//
//        func makeAsyncIterator() -> AsyncOSLogStoreSequence {
//            self
//        }
//    }
}

class OutputSourceModel: ObservableObject {
    @Published var sources: [OutputSource]

    init() {
        sources = []
    }
}
