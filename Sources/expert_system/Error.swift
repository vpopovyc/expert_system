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
    case fileIsEmpty
    case syntaxError
    case expressionIsNotValid
    case bracketsError
    case factsSyntaxError
    case opSyntaxError
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
        case .fileIsEmpty:
            return "File is empty"
        case .syntaxError:
            return "Syntax error" // Add location of it
        case .expressionIsNotValid:
            return "Not valid expression: (facts: \"A+B+P\", op: \"=>\", conclusion: \"C+D\")"
        case .bracketsError:
            return "Invalid brackets input"
        case .factsSyntaxError:
            return "Invalid facts input"
        case .opSyntaxError:
            return "Invalid operators input"
        }
    }
}
