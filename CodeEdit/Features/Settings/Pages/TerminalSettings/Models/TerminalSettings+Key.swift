//
//  TerminalSettings+Key.swift
//  CodeEdit
//
//  Created by Khan Winter on 6/13/24.
//

import Foundation
import Carbon.HIToolbox

extension SettingsData.TerminalSettings.Key {
    /// The label for the key, suitable for display.
    public var label: String {
        switch self {
        case .f1:
            return "F1"
        case .f2:
            return "F2"
        case .f3:
            return "F3"
        case .f4:
            return "F4"
        case .f5:
            return "F5"
        case .f6:
            return "F6"
        case .f7:
            return "F7"
        case .f8:
            return "F8"
        case .f9:
            return "F9"
        case .f10:
            return "F10"
        case .f11:
            return "F11"
        case .f12:
            return "F12"
        case .f13:
            return "F13"
        case .f14:
            return "F14"
        case .f15:
            return "F15"
        case .f16:
            return "F16"
        case .f17:
            return "F17"
        case .f18:
            return "F18"
        case .f19:
            return "F19"
        case .f20:
            return "F20"
        case .left:
            return "← Left"
        case .right:
            return "→ Right"
        case .up:
            return "↑ Up"
        case .down:
            return "↓ Down"
        case .home:
            return "↖︎ Home"
        case .end:
            return "↘︎ End"
        case .pageUp:
            return "⇞ Page Up"
        case .pageDown:
            return "⇟ Page Down"
        case .forwardDelete:
            return "⌦ Forward Delete"
        case .delete:
            return "⌫ Delete"
        case .keypadClear:
            return "Numeric Keypad Clear"
        case .keypadDivide:
            return "Numeric Keypad /"
        case .keypadMultiply:
            return "Numeric Keypad *"
        case .keypadEquals:
            return "Numeric Keypad ="
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    init?(keyCode: Int) {
        switch keyCode {
        case kVK_F1:
            self = .f1
        case kVK_F2:
            self = .f2
        case kVK_F3:
            self = .f3
        case kVK_F4:
            self = .f4
        case kVK_F5:
            self = .f5
        case kVK_F6:
            self = .f6
        case kVK_F7:
            self = .f7
        case kVK_F8:
            self = .f8
        case kVK_F9:
            self = .f9
        case kVK_F10:
            self = .f10
        case kVK_F11:
            self = .f11
        case kVK_F12:
            self = .f12
        case kVK_F13:
            self = .f13
        case kVK_F14:
            self = .f14
        case kVK_F15:
            self = .f15
        case kVK_F16:
            self = .f16
        case kVK_F17:
            self = .f17
        case kVK_F18:
            self = .f18
        case kVK_F19:
            self = .f19
        case kVK_F20:
            self = .f20
        case kVK_LeftArrow:
            self = .left
        case kVK_RightArrow:
            self = .right
        case kVK_DownArrow:
            self = .down
        case kVK_UpArrow:
            self = .up
        case kVK_Home:
            self = .home
        case kVK_End:
            self = .end
        case kVK_PageUp:
            self = .pageUp
        case kVK_PageDown:
            self = .pageDown
        case kVK_ForwardDelete:
            self = .forwardDelete
        case kVK_Delete:
            self = .delete
        case kVK_ANSI_KeypadClear:
            self = .keypadClear
        case kVK_ANSI_KeypadDivide:
            self = .keypadDivide
        case kVK_ANSI_KeypadMultiply:
            self = .keypadMultiply
        case kVK_ANSI_KeypadEquals:
            self = .keypadEquals
        default:
            return nil
        }
    }
}
