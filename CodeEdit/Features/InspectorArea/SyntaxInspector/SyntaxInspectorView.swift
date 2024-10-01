//
//  SyntaxInspectorView.swift
//  CodeEdit
//
//  Created by Khan Winter on 9/30/24.
//

import SwiftUI
import CodeEditSourceEditor
import CodeEditTextView

struct SyntaxInspectorView: View {
    @EnvironmentObject private var editorManager: EditorManager

    struct SyntaxInformation: Identifiable {
        var id: String { String(describing: range) }
        let range: NSRange
        let data: SyntaxTokenAttributeData
    }

    @State private var tab: EditorInstance?
    @State private var cursorPositions: [CursorPosition] = []
    @State private var syntaxInformation: [SyntaxInformation] = []

    /// Updates the source of cursor position notifications.
    func updateSource() {
        tab = editorManager.activeEditor.selectedTab
    }

    func updateSyntaxInformation(file: CodeFileDocument) {
        var foundRanges: Set<NSRange> = []
        syntaxInformation = cursorPositions.compactMap { position in
            var range = NSRange.zero
            return withUnsafeMutablePointer(to: &range) { rangePtr in
                guard let data = file.content?.attribute(
                    .syntaxToken,
                    at: position.range.location,
                    effectiveRange: rangePtr
                ) as? SyntaxTokenAttributeData else {
                    guard !foundRanges.contains(rangePtr.pointee) else {
                        return nil
                    }
                    foundRanges.insert(rangePtr.pointee)
                    return SyntaxInformation(
                        range: rangePtr.pointee,
                        data: SyntaxTokenAttributeData(capture: nil, modifiers: [])
                    )
                }
                guard !foundRanges.contains(rangePtr.pointee) else {
                    return nil
                }
                foundRanges.insert(rangePtr.pointee)
                return SyntaxInformation(range: rangePtr.pointee, data: data)
            }
        }
    }

    var body: some View {
        Group {
            if let tab, let file = tab.file.fileDocument {
                syntaxInfoView
                    .onReceive(tab.cursorPositions) { newValue in
                        if self.cursorPositions != newValue {
                            self.cursorPositions = newValue
                            updateSyntaxInformation(file: file)
                        }
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: NSTextStorage.didProcessEditingNotification)
                    ) { _ in
                        updateSyntaxInformation(file: file)
                    }
            } else {
                NoSelectionInspectorView()
            }
        }
        .accessibilityIdentifier("SyntaxInspector")
        .onAppear {
            updateSource()
        }
        .onReceive(editorManager.tabBarTabIdSubject) { _ in
            updateSource()
        }
    }

    @ViewBuilder var syntaxInfoView: some View {
        if syntaxInformation.isEmpty {
            CEContentUnavailableView("No Cursors")
        }
        Form {
            ForEach(syntaxInformation) { detailedData in
                Section {
                    LabeledContent {
                        Text("\(detailedData.range.location), \(detailedData.range.length)")
                    } label: {
                        Text("Range")
                        Text("(Offset, Length)")
                    }
                    LabeledContent("Capture Type", value: detailedData.data.capture?.rawValue ?? "No Token")
                    LabeledContent("Modifiers") {
                        if detailedData.data.modifiers.isEmpty {
                            Text("No Modifiers")
                        } else {
                            VStack {
                                ForEach(
                                    detailedData.data.modifiers.map { $0.rawValue }.sorted(),
                                    id: \.self
                                ) { modifier in
                                    Text(modifier)
                                }
                            }
                        }
                    }
                    LabeledContent("Content") {
                        Text(
                            AttributedString(
                                tab?.file.fileDocument?.content?.attributedSubstring(from: detailedData.range)
                                ?? .init(string: "Failed To Retrieve Text")
                            )
                        )
                        .lineLimit(nil)
                    }
                }
            }
        }
    }
}

#Preview {
    SyntaxInspectorView()
}
