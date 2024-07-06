//
//  CommandManager.swift
//
//  Created by Alex on 23.05.2022.
//

import Foundation

/// The object of this class intended to be a hearth of command palette. This object only exists as singleton.
/// In order to access its instance use `CommandManager.shared`
///
///
/// ```swift
/// let mgr = CommandManager.shared
/// let wrap = {
///    print("testing handler")
/// }
///
/// mgr.addCommand(name: "test", command: wrap)
/// mgr.executeCommand("test")
/// ```
///
final class CommandManager: ObservableObject {
    typealias CommandHandler = () -> Void

    @Published private var commandsList: [String: Command]

    private init() {
        commandsList = [:]
    }

    static let shared: CommandManager = .init()

    func addCommand(name: String, title: String, id: String, command: @escaping CommandHandler) {
        let command = Command(id: name, title: title, handler: command)
        commandsList[id] = command
    }

    var commands: [Command] {
        return commandsList.values.map { $0 }
    }

    func executeCommand(_ id: String) {
        commandsList[id]?.handler?()
    }
}

/// Command struct uses as a wrapper for command. Used by command palette to call selected commands.
struct Command: Identifiable, Hashable {

    static func == (lhs: Command, rhs: Command) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Command, rhs: Command) -> Bool {
        return false
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: String
    let title: String
    let handler: CommandManager.CommandHandler?
}
