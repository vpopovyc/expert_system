//
//  Lexeme.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/5/18.
//

import Foundation

public enum Conditions {
    case and
    case then
}

public enum Lexeme {
    case fact(String, Bool)
    case condition(Conditions)
}
