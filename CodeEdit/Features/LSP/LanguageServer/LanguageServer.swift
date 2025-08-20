//
//  LanguageServer.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/7/24.
//

import JSONRPC
import Foundation
import LanguageClient
import LanguageServerProtocol
import OSLog

/// A client for language servers.
class LanguageServer<DocumentType: LanguageServerDocument> {
    static var logger: Logger { // types with associated types cannot have constant static properties
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "LanguageServer")
    }
    let logger: Logger

    /// Identifies which language the server belongs to
    let languageId: LanguageIdentifier
    /// Holds information about the language server binary
    let binary: LanguageServerConfiguration
    /// A cache to hold responses from the server, to minimize duplicate server requests
    let lspCache = LSPCache()

    /// Tracks documents and their associated objects.
    /// Use this property when adding new objects that need to track file data, or have a state associated with the
    /// language server and a document. For example, the content coordinator.
    let openFiles: LanguageServerFileMap<DocumentType>

    /// Maps the language server's highlight config to one CodeEdit can read. See ``SemanticTokenMap``.
    let highlightMap: SemanticTokenMap?

    /// The configuration options this server supports.
    var serverCapabilities: ServerCapabilities

    var logContainer: LanguageServerLogContainer

    /// An instance of a language server, that may or may not be initialized
    private(set) var lspInstance: InitializingServer
    /// The path to the root of the project
    private(set) var rootPath: URL
    /// The PID of the running language server process.
    private(set) var pid: pid_t

    init(
        languageId: LanguageIdentifier,
        binary: LanguageServerConfiguration,
        lspInstance: InitializingServer,
        lspPid: pid_t,
        serverCapabilities: ServerCapabilities,
        rootPath: URL
    ) {
        self.languageId = languageId
        self.binary = binary
        self.lspInstance = lspInstance
        self.pid = lspPid
        self.serverCapabilities = serverCapabilities
        self.rootPath = rootPath
        self.openFiles = LanguageServerFileMap()
        self.logContainer = LanguageServerLogContainer(language: languageId)
        self.logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "",
            category: "LanguageServer.\(languageId.rawValue)"
        )
        if let semanticTokensProvider = serverCapabilities.semanticTokensProvider {
            self.highlightMap = SemanticTokenMap(semanticCapability: semanticTokensProvider)
        } else {
            self.highlightMap = nil // Server doesn't support semantic highlights
        }
    }

    // MARK: - Shutdown

    /// Shuts down the language server and exits it.
    public func shutdown() async throws {
        self.logger.info("Shutting down language server")
        try await withTimeout(duration: .seconds(1.0)) {
            try await self.lspInstance.shutdownAndExit()
        }
    }
}

enum LSPError: Error {
    case binaryNotFound
}
