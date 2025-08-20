//
//  LanguageServer+Create.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/19/25.
//

import Foundation
import JSONRPC
import LanguageClient
import LanguageServerProtocol

extension LanguageServer {
    /// Creates and initializes a language server.
    /// - Parameters:
    ///   - languageId: The id of the language to create.
    ///   - binary: The binary where the language server is stored.
    ///   - workspacePath: The path of the workspace being opened.
    /// - Returns: An initialized language server.
    static func createServer(
        for languageId: LanguageIdentifier,
        with binary: LanguageServerConfiguration,
        workspacePath: String
    ) async throws -> LanguageServer {
        let (connection, process) = try makeLocalServerConnection(
            languageId: languageId,
            executionParams: binary.processParameters(forDir: nil)
        )

        let server = InitializingServer(
            server: connection,
            initializeParamsProvider: getInitParams(workspacePath: workspacePath)
        )
        let initializationResponse = try await server.initializeIfNeeded()

        return LanguageServer(
            languageId: languageId,
            binary: binary,
            lspInstance: server,
            lspPid: process.processIdentifier,
            serverCapabilities: initializationResponse.capabilities,
            rootPath: URL(filePath: workspacePath)
        )
    }

    // MARK: - Make Local Server Connection

    /// Creates a data channel for sending and receiving data with an LSP.
    /// - Parameters:
    ///   - languageId: The ID of the language to create the channel for.
    ///   - executionParams: The parameters for executing the local process.
    /// - Returns: A new connection to the language server.
    static func makeLocalServerConnection(
        languageId: LanguageIdentifier,
        executionParams: Process.ExecutionParameters
    ) throws -> (connection: JSONRPCServerConnection, process: Process) {
        do {
            let (channel, process) = try DataChannel.localProcessChannel(
                parameters: executionParams,
                terminationHandler: {
                    logger.debug("Terminated data channel for \(languageId.rawValue)")
                }
            )
            return (JSONRPCServerConnection(dataChannel: channel), process)
        } catch {
            logger.warning("Failed to initialize data channel for \(languageId.rawValue)")
            throw error
        }
    }

    // MARK: - Get Init Params

    // swiftlint:disable function_body_length
    static func getInitParams(workspacePath: String) -> InitializingServer.InitializeParamsProvider {
        let provider: InitializingServer.InitializeParamsProvider = {
            // Text Document Capabilities
            let textDocumentCapabilities = TextDocumentClientCapabilities(
                completion: CompletionClientCapabilities(
                    dynamicRegistration: true,
                    completionItem: CompletionClientCapabilities.CompletionItem(
                        snippetSupport: true,
                        commitCharactersSupport: true,
                        documentationFormat: [MarkupKind.plaintext],
                        deprecatedSupport: true,
                        preselectSupport: true,
                        tagSupport: ValueSet(valueSet: [CompletionItemTag.deprecated]),
                        insertReplaceSupport: true,
                        resolveSupport: CompletionClientCapabilities.CompletionItem.ResolveSupport(
                            properties: ["documentation", "details"]
                        ),
                        insertTextModeSupport: ValueSet(valueSet: [InsertTextMode.adjustIndentation]),
                        labelDetailsSupport: true
                    ),
                    completionItemKind: ValueSet(valueSet: [CompletionItemKind.text, CompletionItemKind.method]),
                    contextSupport: true,
                    insertTextMode: InsertTextMode.asIs,
                    completionList: CompletionClientCapabilities.CompletionList(
                        itemDefaults: ["default1", "default2"]
                    )
                ),
                // swiftlint:disable:next line_length
                // https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#semanticTokensClientCapabilities
                semanticTokens: SemanticTokensClientCapabilities(
                    dynamicRegistration: false,
                    requests: .init(range: false, delta: true),
                    tokenTypes: SemanticTokenTypes.allStrings,
                    tokenModifiers: SemanticTokenModifiers.allStrings,
                    formats: [.relative],
                    overlappingTokenSupport: true,
                    multilineTokenSupport: true,
                    serverCancelSupport: false,
                    augmentsSyntaxTokens: true
                )
            )

            // Workspace File Operations Capabilities
            let fileOperations = ClientCapabilities.Workspace.FileOperations(
                dynamicRegistration: true,
                didCreate: true,
                willCreate: true,
                didRename: true,
                willRename: true,
                didDelete: true,
                willDelete: true
            )

            // Workspace Capabilities
            let workspaceCapabilities = ClientCapabilities.Workspace(
                applyEdit: true,
                workspaceEdit: nil,
                didChangeConfiguration: DidChangeConfigurationClientCapabilities(dynamicRegistration: true),
                didChangeWatchedFiles: DidChangeWatchedFilesClientCapabilities(dynamicRegistration: true),
                symbol: WorkspaceSymbolClientCapabilities(
                    dynamicRegistration: true,
                    symbolKind: nil,
                    tagSupport: nil,
                    resolveSupport: []
                ),
                executeCommand: nil,
                workspaceFolders: true,
                configuration: true,
                semanticTokens: nil,
                codeLens: nil,
                fileOperations: fileOperations
            )

            let windowClientCapabilities = WindowClientCapabilities(
                workDoneProgress: true,
                showMessage: ShowMessageRequestClientCapabilities(
                    messageActionItem: ShowMessageRequestClientCapabilities.MessageActionItemCapabilities(
                        additionalPropertiesSupport: true
                    )
                ),
                showDocument: ShowDocumentClientCapabilities(
                    support: true
                )
            )

            // All Client Capabilities
            let capabilities = ClientCapabilities(
                workspace: workspaceCapabilities,
                textDocument: textDocumentCapabilities,
                window: windowClientCapabilities,
                general: nil,
                experimental: nil
            )
            return InitializeParams(
                processId: nil,
                locale: nil,
                rootPath: nil,
                rootUri: "file://" + workspacePath, // Make it a URI
                initializationOptions: [],
                capabilities: capabilities,
                trace: nil,
                workspaceFolders: nil
            )
        }
        return provider
        // swiftlint:enable function_body_length
    }
}
