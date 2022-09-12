//
//  NavigationPreferences.swift
//  
//
//  Created by Khan Winter on 9/10/22.
//

import Foundation

public extension AppPreferences {

    struct NavigationPreferences: Codable {

        /// Whether or not to show hidden files, set to `true` to show files.
        public var showHiddenFiles: Bool = false

        /// An array of glob filename patterns to hide
        public var hiddenFilePatterns: [String] = Self.defaultHiddenFilePatterns

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.showHiddenFiles = try container.decodeIfPresent(
                Bool.self,
                forKey: .showHiddenFiles
            ) ?? false
            self.hiddenFilePatterns = try container.decodeIfPresent(
                [String].self,
                forKey: .hiddenFilePatterns
            ) ?? Self.defaultHiddenFilePatterns
        }

        /// Default hidden file patterns. By default hides:
        /// - `.git`
        /// - `.DS_Store`
        private static let defaultHiddenFilePatterns = [
            "**/.git",
            "**/.DS_Store"
        ]
    }

}
