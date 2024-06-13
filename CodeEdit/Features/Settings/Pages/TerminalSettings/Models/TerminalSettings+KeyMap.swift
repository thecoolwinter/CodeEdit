//
//  TerminalSettings+KeyMap.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/12/24.
//

import Foundation

extension SettingsData.TerminalSettings {
    public struct KeyMatch: Codable, Hashable, Sendable, Comparable, Identifiable {
        let key: Key
        let modifiers: Modifiers

        init(key: Key, modifiers: Modifiers) {
            self.key = key
            self.modifiers = modifiers
        }

        /// A stable ID based on the key and modifiers.
        /// Uses the key's raw value, shifted 3 places and 'or'd with the modifiers raw value which uses a maximum 3
        /// bits.
        var id: Int { key.rawValue << 4 | modifiers.rawValue }

        /// Initialize a key match using an integer id.
        init?(id: Int) {
            guard let key = Key(rawValue: id >> 4) else {
                return nil
            }
            self.key = key
            self.modifiers = Modifiers(rawValue: id & 0x7)
        }

        static func < (lhs: KeyMatch, rhs: KeyMatch) -> Bool {
            if lhs.key == rhs.key {
                return lhs.modifiers.rawValue < rhs.modifiers.rawValue
            } else {
                return lhs.key.rawValue < rhs.key.rawValue
            }
        }

        var label: String {
            if !modifiers.isEmpty {
                let modifierArray = Modifiers.all.compactMap({ modifiers.contains($0) ? $0.symbol : nil })
                return modifierArray.joined(separator: " ") + " " + key.label
            } else {
                return key.label
            }
        }
    }

    public enum Key: Int, Codable, Hashable, Sendable, CaseIterable, Identifiable {
        case f1 // swiftlint:disable:this identifier_name
        case f2 // swiftlint:disable:this identifier_name
        case f3 // swiftlint:disable:this identifier_name
        case f4 // swiftlint:disable:this identifier_name
        case f5 // swiftlint:disable:this identifier_name
        case f6 // swiftlint:disable:this identifier_name
        case f7 // swiftlint:disable:this identifier_name
        case f8 // swiftlint:disable:this identifier_name
        case f9 // swiftlint:disable:this identifier_name
        case f10
        case f11
        case f12
        case f13
        case f14
        case f15
        case f16
        case f17
        case f18
        case f19
        case f20
        case left
        case right
        case up // swiftlint:disable:this identifier_name
        case down
        case home
        case end
        case pageUp
        case pageDown
        case forwardDelete
        case delete
        case keypadClear
        case keypadDivide
        case keypadMultiply
        case keypadEquals

        var id: Int { rawValue }
    }

    public struct Modifiers: OptionSet, Codable, Hashable, Sendable, Comparable {
        let rawValue: Int

        static let ctrl = Modifiers(rawValue: 1 << 0)
        static let option = Modifiers(rawValue: 1 << 1)
        static let shift = Modifiers(rawValue: 1 << 2)

        static let all: [Modifiers] = [.ctrl, .option, .shift]

        var symbol: String {
            switch self {
            case .shift:
                return "⇧"
            case .ctrl:
                return "⌃"
            case .option:
                return "⌥"
            default:
                return ""
            }
        }

        static func < (lhs: Modifiers, rhs: Modifiers) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    /// Default key map for `Terminal.app` on macOS, ported here.
    static let defaultKeyMap: [KeyMatch: String] = [
        .init(key: .f1, modifiers: .option): #"\033[17~"#,
        .init(key: .f2, modifiers: .option): #"\033[18~"#,
        .init(key: .f3, modifiers: .option): #"\033[19~"#,
        .init(key: .f4, modifiers: .option): #"\033[20~"#,
        .init(key: .f5, modifiers: .option): #"\033[21~"#,
        .init(key: .f6, modifiers: .option): #"\033[23~"#,
        .init(key: .f7, modifiers: .option): #"\033[24~"#,
        .init(key: .f8, modifiers: .option): #"\033[25~"#,
        .init(key: .f9, modifiers: .option): #"\033[26~"#,
        .init(key: .f10, modifiers: .option): #"\033[28~"#,
        .init(key: .f11, modifiers: .option): #"\033[29~"#,
        .init(key: .f12, modifiers: .option): #"\033[31~"#,
        .init(key: .f13, modifiers: .option): #"\033[32~"#,
        .init(key: .f14, modifiers: .option): #"\033[33~"#,
        .init(key: .f15, modifiers: .option): #"\033[34~"#,

        .init(key: .f5, modifiers: .shift): #"\033[25~"#,
        .init(key: .f6, modifiers: .shift): #"\033[26~"#,
        .init(key: .f7, modifiers: .shift): #"\033[28~"#,
        .init(key: .f8, modifiers: .shift): #"\033[29~"#,
        .init(key: .f9, modifiers: .shift): #"\033[31~"#,
        .init(key: .f10, modifiers: .shift): #"\033[32~"#,
        .init(key: .f11, modifiers: .shift): #"\033[33~"#,
        .init(key: .f12, modifiers: .shift): #"\033[34~"#,

        .init(key: .f1, modifiers: []): #"\033OP"#,
        .init(key: .f2, modifiers: []): #"\033OQ"#,
        .init(key: .f3, modifiers: []): #"\033OR"#,
        .init(key: .f4, modifiers: []): #"\033OS"#,
        .init(key: .f5, modifiers: []): #"\033[15~"#,
        .init(key: .f6, modifiers: []): #"\033[17~"#,
        .init(key: .f7, modifiers: []): #"\033[18~"#,
        .init(key: .f8, modifiers: []): #"\033[19~"#,
        .init(key: .f9, modifiers: []): #"\033[20~"#,
        .init(key: .f10, modifiers: []): #"\033[20~"#,
        .init(key: .f11, modifiers: []): #"\033[23~"#,
        .init(key: .f12, modifiers: []): #"\033[24~"#,
        .init(key: .f13, modifiers: []): #"\033[25~"#,
        .init(key: .f14, modifiers: []): #"\033[26~"#,
        .init(key: .f15, modifiers: []): #"\033[28~"#,
        .init(key: .f16, modifiers: []): #"\033[29~"#,
        .init(key: .f17, modifiers: []): #"\033[31~"#,
        .init(key: .f18, modifiers: []): #"\033[32~"#,
        .init(key: .f19, modifiers: []): #"\033[33~"#,
        .init(key: .f20, modifiers: []): #"\033[34~"#,

        .init(key: .left, modifiers: .ctrl): #"\033[1;5D"#,
        .init(key: .left, modifiers: .option): #"\033b"#,
        .init(key: .left, modifiers: .shift): #"\033[1;2D"#,
        .init(key: .right, modifiers: .ctrl): #"\033[1;5C"#,
        .init(key: .right, modifiers: .option): #"\033f"#,
        .init(key: .right, modifiers: .shift): #"\033[1;2C"#,
        .init(key: .forwardDelete, modifiers: .ctrl): #"\033[3;5~"#,
        .init(key: .forwardDelete, modifiers: .shift): #"\033[3;2~"#,
        .init(key: .forwardDelete, modifiers: []): #"\033[3~"#,
        .init(key: .forwardDelete, modifiers: [.ctrl, .option]): #"\033\033[3;5~"#,
    ]
}
