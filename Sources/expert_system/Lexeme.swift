//
//  Lexeme.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/5/18.
//

import Foundation

public enum Conditions: Character {
    case and = "+"
    case or = "|"
    case xor = "^"
    case then = ">"
    case not = "!"
}

public enum Lexeme {
    case fact(Character, Bool)
    case condition(Conditions)
}
