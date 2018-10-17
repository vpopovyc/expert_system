//
//  Lexer+create_lexemes.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/5/18.
//

import Foundation

typealias OpPriority = Int

fileprivate let separate_query_reg_exp = try! NSRegularExpression(pattern: "\\s*([()!A-Z +|^]+)\\s*(=>){1}\\s*([()!A-Z +|^]+)\\s*(?:#.*)?",
                                                                  options: [.dotMatchesLineSeparators])

extension Lexer {
    public func create_lexemes(from line: String) {
        
        do {
            var mutable_line = line
            
            emptyTrash(in: &mutable_line)
            
            check_for_initial_facts(in: &mutable_line)
            
            check_for_facts_to_find(in: &mutable_line)
            
            let components = try separate_query(in: mutable_line)
            
            try resolve_query(components.facts, components.op, components.conclusion)
            
        } catch {
            switch error {
            case ESError.silentEmptyLine:
                () // Be silent, plz
            case ESError.internalInconsistency:
                print("\(#function): Enviroment failure: can't revive")
            default:
                print("\(#function): \(error)")
            }
        }
    }
    
    private func check_for_initial_facts(in line: inout String) {
        guard let first_char = line.first else {
            return
        }
        
        let facts_symbols_tab = Array("ABCDEFGHIJKLMNOPQRSTUVWXY")

        if first_char == "=" {
            line.remove(at: line.startIndex)
            line.removeAll {
                if facts_symbols_tab.contains($0) {
                    m_lexemes.append(Lexeme.fact_true($0))
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    private func check_for_facts_to_find(in line: inout String) {
        guard let first_char = line.first else {
            return
        }
        
        let facts_symbols_tab = Array("ABCDEFGHIJKLMNOPQRSTUVWXY")
        
        if first_char == "?" {
            line.remove(at: line.startIndex)
            line.removeAll {
                if facts_symbols_tab.contains($0) {
                    m_lexemes.append(Lexeme.fact_to_find($0))
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    private func separate_query(in line: String) throws -> (facts: String, op: String, conclusion: String) {
        
        guard !line.isEmpty else {
            throw ESError.silentEmptyLine
        }
        
        let matches = separate_query_reg_exp.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))

        guard let match = matches.first else {
            throw ESError.syntaxError
        }
        
        guard match.range.length == line.count else {
            throw ESError.syntaxError
        }
        
        let facts = separate_query_reg_exp.replacementString(for: match, in: line, offset: 0, template: "$1")
        let op = separate_query_reg_exp.replacementString(for: match, in: line, offset: 0, template: "$2")
        let conclusion = separate_query_reg_exp.replacementString(for: match, in: line, offset: 0, template: "$3")
        
        guard facts.isEmpty == false, op.isEmpty == false, conclusion.isEmpty == false else {
            throw ESError.expressionIsNotValid
        }
        
        return (facts, op, conclusion)
    }
    
    private func resolve_query(_ facts_string: String, _ op_string: String, _ conclusion_string: String) throws {

        var polish_notated_facts = ""
        try convert_to_polish_notation(facts_string, &polish_notated_facts)
        try generate_lexemes(&polish_notated_facts)
        
        var polish_notated_imply_facts = ""
        try convert_to_polish_notation(conclusion_string, &polish_notated_imply_facts)
        try generate_lexemes(&polish_notated_imply_facts)
        
        guard polish_notated_facts.count == 1 && polish_notated_imply_facts.count == 1 else {
            throw ESError.internalInconsistency
        }
        
        guard let f1 = polish_notated_facts.first, let f2 = polish_notated_imply_facts.first else {
            throw ESError.internalInconsistency
        }
        
        try store_two_direct_facts(f1, implyOn: f2)
    }
    
    private func convert_to_polish_notation(_ statement: String, _ storage: inout String) throws {
        var ops = Deque<Character>()
        
        let operators: [Character] = ["+", "|", "^"]
        
        let super_special_operators: [Character] = ["(", ")", "!"]
        
        let op_priority: [Character : OpPriority] = ["!" : 4, "+" : 3, "|" : 2, "^" : 1, "(" : 0]
        let facts_symbols_tab = Array("ABCDEFGHIJKLMNOPQRSTUVWXY")
        
        var fact_semaphore: Int = 0
        var op_semaphore: Int = 0
        var not_semaphore: Int = 0
        var brackets_semaphore: Int = 0
        
        try statement.forEach { token in
            
            if operators.contains(token) {
                guard op_semaphore == 0 && not_semaphore == 0 && fact_semaphore == 1 else {
                    throw ESError.opSyntaxError
                }
                op_semaphore += 1
                fact_semaphore -= 1
                
                if let prev_op = ops.peekBack() {
                    guard let op1_priority = op_priority[token], let op2_priority = op_priority[prev_op] else {
                        throw ESError.internalInconsistency
                    }
                    
                    if op1_priority < op2_priority {
                        storage.append(prev_op)
                        ops.dropLast()
                    }
                }

                ops.enqueue(token)
            }
            
            if super_special_operators.contains(token) {
                if token == "(" {
                    guard not_semaphore == 0 else {
                        throw ESError.opSyntaxError
                    }
                    
                    brackets_semaphore += 1
                    ops.enqueue(token)
                }
                
                if token == ")" {
                    guard brackets_semaphore != 0 && op_semaphore == 0 else {
                        throw ESError.bracketsError
                    }
                    
                    brackets_semaphore -= 1
                    while let op = ops.dequeueBack() {
                        if op == "(" {
                            break
                        } else {
                            storage.append(op)
                        }
                    }
                }
                
                if token == "!" {
                    guard not_semaphore == 0 else {
                        throw ESError.opSyntaxError
                    }
                    
                    storage.append(token)
                    not_semaphore += 1
                }
            }
            
            if facts_symbols_tab.contains(token) {
                guard fact_semaphore == 0 else {
                    throw ESError.factsSyntaxError
                }
                fact_semaphore += 1
                op_semaphore = 0
                not_semaphore = 0
                
                storage.append(token)
            }
        }
        
        guard brackets_semaphore == 0 else {
            throw ESError.bracketsError
        }
        
        guard op_semaphore == 0 else {
            throw ESError.opSyntaxError
        }
        
        while let op = ops.dequeueBack() {
            storage.append(op)
        }
    }
    
    private func generate_lexemes(_ facts: inout String, shrinkAsMuchAsPosible: Bool = true) throws {
        
        var startCount = facts.count
        repeat {
            startCount = facts.count
            try find_and_replace_not_ops(&facts)
        } while (startCount != facts.count)
        
        
        let lowBound = shrinkAsMuchAsPosible ? 1 : 3
        while (facts.count > lowBound) {
            try find_and_replace_two_facts(&facts)
        }
    }
    
    private func find_and_replace_not_ops(_ facts: inout String) throws {
        if let res = facts.firstIndex(where: { $0 == "!" }) {
            let next_index = facts.index(after: res)
            let sub_expression = facts[res...next_index]
            
            let hidden_identifier = new_identifier()
            try store_not_fact(sub_expression, implyOn: hidden_identifier)
            
            facts.replaceSubrange(res...next_index, with: "\(hidden_identifier)")
        }
    }
    
    private func find_and_replace_two_facts(_ facts: inout String) throws {
        let operators: [Character] = ["+", "|", "^"]
        
        if let res = facts.firstIndex(where: { operators.contains($0) }) {
            let prev_index = facts.index(before: res)
            let prev_index_twice = facts.index(before: prev_index)
            let sub_expression = facts[prev_index_twice...res]
            
            let hidden_identifier = new_identifier()
            
            try store_two_facts(sub_expression, implyOn: hidden_identifier)
            
            facts.replaceSubrange(prev_index_twice...res, with: "\(hidden_identifier)")
        }
    }
    
    private func store_not_fact(_ facts: Substring, implyOn fact: Character) throws {
        guard facts.count == 2 else {
            throw ESError.syntaxError
        }
        
        guard let op = facts.first else {
            throw ESError.internalInconsistency
        }
        
        let f1 = facts[facts.index(after: facts.startIndex)]
        
        guard let not_condition = Conditions(rawValue: op) else {
            throw ESError.internalInconsistency
        }
        
        guard let imply_condition = Conditions(rawValue: ">") else {
            throw ESError.internalInconsistency
        }
        
        m_lexemes.append(contentsOf: [Lexeme.condition(not_condition),
                                      Lexeme.fact(f1),
                                      Lexeme.condition(imply_condition),
                                      Lexeme.fact(fact)])
    }
    
    private func store_two_direct_facts(_ f1: Character, implyOn f2: Character) throws {
        guard let imply_condition = Conditions(rawValue: ">") else {
            throw ESError.internalInconsistency
        }
        
        m_lexemes.append(contentsOf: [Lexeme.fact(f1),
                                      Lexeme.condition(imply_condition),
                                      Lexeme.fact(f2)])
    }

    private func store_two_facts(_ facts: Substring, implyOn fact: Character) throws {
        guard facts.count == 3 else {
            throw ESError.syntaxError
        }
        
        guard let f1 = facts.first else {
            throw ESError.internalInconsistency
        }
        
        let f2 = facts[facts.index(after: facts.startIndex)]
        
        guard let op = facts.last else {
            throw ESError.internalInconsistency
        }
        
        guard let op_condition = Conditions(rawValue: op) else {
            throw ESError.internalInconsistency
        }
        
        guard let imply_condition = Conditions(rawValue: ">") else {
            throw ESError.internalInconsistency
        }
        
        m_lexemes.append(contentsOf: [Lexeme.fact(f1),
                                      Lexeme.condition(op_condition),
                                      Lexeme.fact(f2),
                                      Lexeme.condition(imply_condition),
                                      Lexeme.fact(fact)])
    }
    
    private func emptyTrash(in line: inout String) {
        var foundComment: Bool = false
        
        line.removeAll {
            if $0 == "#" {
                foundComment = true
            }
            return $0 == " " || foundComment
        }
    }
    
    private func new_identifier() -> Character {
        struct Generator {
            // Around 50k unique ids
//            private static var seed = 0xe01
            // Around 80 unique ids ))
            private static var seed = 0x1F600
            public static func produce_id() -> Character {
                guard let unicodeScalar = UnicodeScalar(seed) else {
                    terminate_me_plz("Failing gracefully \n\(#function)")
                }
                
                seed += 1
                
                let producedID = Character(unicodeScalar)
                return producedID
            }
        }
        
        return Generator.produce_id()
    }
}
