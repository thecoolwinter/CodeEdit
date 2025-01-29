//
//  ConcreteSemanticTokenStorage.swift
//  CodeEdit
//
//  Created by Khan Winter on 12/26/24.
//

import Foundation
import LanguageServerProtocol
import CodeEditSourceEditor

/// This class provides an efficient storage mechanism for semantic token data.
///
/// The LSP spec requires that clients keep the original compressed data to apply delta edits to. The delta updates may
/// come as a delta to a single number in the compressed array. This class maintains a current state of compressed
/// tokens and their decoded counterparts. It supports applying delta updates from the language server.
///
/// See ``SemanticTokenHighlightProvider`` for it's connection to the editor view.
final class LSPSemanticTokenStorage: SemanticTokenStorage {
    /// Represents compressed semantic token data received from a language server.
    struct CurrentState {
        let resultId: String?
        let tokenData: [UInt32]
        let tokens: [SemanticToken]
    }

    var lastResultId: String? {
        state?.resultId
    }

    var hasTokens: Bool {
        state != nil
    }

    var state: CurrentState?

    init() {
        state = nil
    }

    // MARK: - Storage Conformance

    func getTokensFor(range: LSPRange) -> [SemanticToken] {
        guard let state = state, !state.tokens.isEmpty else {
            return []
        }
        var tokens: [SemanticToken] = []

//        var idx = findLowerBound(of: range.start, data: state.tokens[...])
//        while idx < state.tokens.count && state.tokens[idx].startPosition < range.end {
//            tokens.append(state.tokens[idx])
//            idx += 1
//        }

        return tokens
    }

    func setData(_ data: borrowing SemanticTokens) {
        print(data.decode())
        state = CurrentState(resultId: data.resultId, tokenData: data.data, tokens: data.decode())
    }

    /// Apply a delta object from a language server and returns all token ranges that may need re-drawing.
    ///
    /// To calculate invalidated ranges:
    /// - Grabs all semantic tokens that *will* be updated and invalidates their ranges
    /// - Loops over all inserted tokens and invalidates their ranges
    /// This may result in duplicated ranges. It's up to the caller to de-duplicate if necessary.
    ///
    /// - Parameter deltas: The deltas to apply.
    /// - Returns: All ranges invalidated by the applied deltas.
    func applyDelta(_ deltas: SemanticTokensDelta) -> [SemanticTokenRange] {
        assert(state != nil, "State should be set before applying any deltas.")
        guard var tokenData = state?.tokenData else { return [] }
        var invalidatedSet: [SemanticTokenRange] = []

        // Apply in reverse order (end to start)
        for edit in deltas.edits.sorted(by: { $0.start > $1.start }) {
            invalidatedSet.append(
                contentsOf: invalidatedRanges(startIdx: edit.start, length: edit.deleteCount, data: tokenData[...])
            )

            // Apply to our copy of the tokens array
            if edit.deleteCount > 0 {
                tokenData.replaceSubrange(Int(edit.start)..<Int(edit.start + edit.deleteCount), with: edit.data ?? [])
            } else {
                tokenData.insert(contentsOf: edit.data ?? [], at: Int(edit.start))
            }

            if edit.data != nil {
                invalidatedSet.append(
                    contentsOf: invalidatedRanges(
                        startIdx: edit.start,
                        length: UInt(edit.data?.count ?? 0),
                        data: tokenData[...]
                    )
                )
            }
        }

        // Set the current state and decode the new token data
        var decodedTokens: [SemanticToken] = []
        for idx in stride(from: 0, to: tokenData.count, by: 5) {
            decodedTokens.append(SemanticToken(
                line: tokenData[idx],
                char: tokenData[idx + 1],
                length: tokenData[idx + 2],
                type: tokenData[idx + 3],
                modifiers: tokenData[idx + 4]
            ))
        }
        state = CurrentState(resultId: deltas.resultId, tokenData: tokenData, tokens: decodedTokens)

        return invalidatedSet
    }

    // MARK: - Invalidated Indices

    func invalidatedRanges(startIdx: UInt, length: UInt, data: ArraySlice<UInt32>) -> [SemanticTokenRange] {
        var ranges: [SemanticTokenRange] = []
        var idx = startIdx - (startIdx % 5)
        while idx < startIdx + length {
            ranges.append(
                SemanticTokenRange(
                    line: data[Int(idx)],
                    char: data[Int(idx + 1)],
                    length: data[Int(idx + 2)]
                )
            )
            idx += 5
        }
        return ranges
    }

    // MARK: - Binary Search

    /// Perform a binary search to find the given position
    /// - Complexity: O(log n)
    func findLowerBound(in range: LSPRange, data: ArraySlice<SemanticToken>) -> Int? {
        // TODO: This needs to find the closest value in a range, there's a good chance there's no result for a
        // specific indice
//        var lower = 0
//        var upper = data.count
//        var idx = 0
//        while lower < upper {
//            idx = lower + upper / 2
//            if data[idx].startPosition < position {
//                lower = idx + 1
//            } else if data[idx].startPosition > position {
//                upper = idx
//            } else {
//                return idx
//            }
//        }
//
//        return (data[idx].startPosition..<data[idx].endPosition).contains(position) ? idx : nil
        return nil
    }
}
