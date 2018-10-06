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
            let components = try separate_query(in: line)
            
            print(components)
            
            try resolve_facts(components.facts)
            
        } catch {
            print("\(#function): \(error)")
        }
    }
    
    private func separate_query(in line: String) throws -> (facts: String, op: String, conclusion: String) {

        let matches = separate_query_reg_exp.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))

        guard matches.count > 0 else {
            throw ESError.syntaxError
        }
        
        let match = matches.first!
        guard match.range.length == line.count else {
            throw ESError.syntaxError
        }
        
        var facts = separate_query_reg_exp.replacementString(for: match, in: line, offset: 0, template: "$1")
        var op = separate_query_reg_exp.replacementString(for: match, in: line, offset: 0, template: "$2")
        var conclusion = separate_query_reg_exp.replacementString(for: match, in: line, offset: 0, template: "$3")
        
        facts.removeAll { $0 == " " }
        op.removeAll { $0 == " " }
        conclusion.removeAll { $0 == " " }
        
        guard facts.isEmpty == false, op.isEmpty == false, conclusion.isEmpty == false else {
            throw ESError.expressionIsNotValid
        }
        
        return (facts, op, conclusion)
    }
    
    private func resolve_facts(_ facts_string: String) throws {
        // Stop here
        // OK let's try polish notation
        // Seems to work
        // Lexeme generator ahead
        
        var ops = Deque<Character>()
        var polish_notated_facts = Deque<Character>()
        
        let operators: [Character] = ["!", "+", "|", "^"]
        
        let super_special_operators: [Character] = ["(", ")"]
        
        let op_priority: [Character : OpPriority] = ["!" : 4, "+" : 3, "|" : 2, "^" : 1, "(" : 0]
        let facts_symbols_tab = Array("ABCDEFGHIJKLMNOPQRSTUVWXY")
        
        var fact_semaphore: Int = 0
        var op_semaphore: Int = 0
        var brackets_semaphore: Int = 0
        
        try facts_string.forEach { token in
            
            if operators.contains(token) {
                guard op_semaphore == 0 && fact_semaphore == 1 else {
                    throw ESError.opSyntaxError
                }
                op_semaphore += 1
                fact_semaphore -= 1
                
                if let prev_op = ops.peekBack(), op_priority[token]! < op_priority[prev_op]! {
                    polish_notated_facts.enqueue(prev_op)
                    ops.dropLast()
                }
                ops.enqueue(token)
            }
            
            if super_special_operators.contains(token) {
                if token == "(" {
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
                            polish_notated_facts.enqueue(op)
                        }
                    }
                }
            }
            
            if facts_symbols_tab.contains(token) {
                guard fact_semaphore == 0 else {
                    throw ESError.factsSyntaxError
                }
                fact_semaphore += 1
                op_semaphore = 0
                
                polish_notated_facts.enqueue(token)
            }
        }
        
        guard brackets_semaphore == 0 else {
            throw ESError.bracketsError
        }
        
        while let op = ops.dequeueBack() {
            polish_notated_facts.enqueue(op)
        }
        
        print(polish_notated_facts)
        // generate_lexemes(polish_notated_facts)
    }
}
