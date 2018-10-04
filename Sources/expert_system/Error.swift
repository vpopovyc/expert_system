//
//  Error.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/4/18.
//

import Foundation

enum ESError: Error {
    case invalidNumberOfCLIArguments
    case fileDoesNotExist
    case fileCantBeRead
}

extension ESError: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidNumberOfCLIArguments:
            return "Invalid command line argument."
        case .fileDoesNotExist:
            return "File does not exist"
        case .fileCantBeRead:
            return "File is not readable"
        }
    }
}
