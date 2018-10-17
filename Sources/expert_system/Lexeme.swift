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
    case fact(Character)
    case fact_true(Character)
    case fact_to_find(Character)
    case condition(Conditions)
}
