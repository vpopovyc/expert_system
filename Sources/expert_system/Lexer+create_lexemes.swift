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
        var polish_notated_facts = ""
        
        let operators: [Character] = ["+", "|", "^"]
        
        let super_special_operators: [Character] = ["(", ")", "!"]
        
        let op_priority: [Character : OpPriority] = ["!" : 4, "+" : 3, "|" : 2, "^" : 1, "(" : 0]
        let facts_symbols_tab = Array("ABCDEFGHIJKLMNOPQRSTUVWXY")
        
        var fact_semaphore: Int = 0
        var op_semaphore: Int = 0
        var not_semaphore: Int = 0
        var brackets_semaphore: Int = 0
        
        try facts_string.forEach { token in
            
            if operators.contains(token) {
                guard op_semaphore == 0 && not_semaphore == 0 && fact_semaphore == 1 else {
                    throw ESError.opSyntaxError
                }
                op_semaphore += 1
                fact_semaphore -= 1
                
                if let prev_op = ops.peekBack(), op_priority[token]! < op_priority[prev_op]! {
                    polish_notated_facts.append(prev_op)
                    ops.dropLast()
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
                            polish_notated_facts.append(op)
                        }
                    }
                }
                
                if token == "!" {
                    guard not_semaphore == 0 else {
                        throw ESError.opSyntaxError
                    }
                    
                    polish_notated_facts.append(token)
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
                
                polish_notated_facts.append(token)
            }
        }
        
        guard brackets_semaphore == 0 else {
            throw ESError.bracketsError
        }
        
        while let op = ops.dequeueBack() {
            polish_notated_facts.append(op)
        }
        
        print(polish_notated_facts)
        generate_lexemes(&polish_notated_facts)
    }
    
    private func generate_lexemes(_ facts: inout String) {
        
        // Generate hidden fact lexemes
        var startCount = facts.count
        
        repeat {
            startCount = facts.count
            find_and_replace_not_ops(&facts)
        } while (startCount != facts.count)
        
        while (facts.count > 4) {
            find_and_replace_two_facts(&facts)
            print(facts)
        }
        
        // Provide conclusion and other stuff here
        // Left HERE
        print(facts)
    }
    
    private func find_and_replace_not_ops(_ facts: inout String) {
        if let res = facts.firstIndex(where: { $0 == "!" }) {
            let next_index = facts.index(after: res)
            let sub_expression = facts[res...next_index]
            
            let hidden_identifier = new_identifier()
            store_not_fact(sub_expression, implyOn: hidden_identifier)
            
            facts.replaceSubrange(res...next_index, with: "\(hidden_identifier)")
        }
    }
    
    private func find_and_replace_two_facts(_ facts: inout String) {
        let operators: [Character] = ["+", "|", "^"]
        
        if let res = facts.firstIndex(where: { operators.contains($0) }) {
            let prev_index = facts.index(before: res)
            let prev_index_twice = facts.index(before: prev_index)
            let sub_expression = facts[prev_index_twice...res]
            
            let hidden_identifier = new_identifier()
            
            store_two_facts(sub_expression, implyOn: hidden_identifier)
            
            facts.replaceSubrange(prev_index_twice...res, with: "\(hidden_identifier)")
        }
    }
    
    private func store_not_fact(_ facts: Substring, implyOn fact: Character) {
        let op = facts.first
        let f1 = facts[facts.index(after: facts.startIndex)]
        
        m_lexemes.append(contentsOf: [Lexeme.condition(Conditions(rawValue: op!)!),
                                      Lexeme.fact(f1, true),
                                      Lexeme.condition(Conditions(rawValue: ">")!),
                                      Lexeme.fact(fact, true)])
    }

    private func store_two_facts(_ facts: Substring, implyOn fact: Character) {
        
        let f1 = facts.first
        let f2 = facts[facts.index(after: facts.startIndex)]
        let op = facts.last
        
        m_lexemes.append(contentsOf: [Lexeme.fact(f1!, true),
                                      Lexeme.condition(Conditions(rawValue: op!)!),
                                      Lexeme.fact(f2, true),
                                      Lexeme.condition(Conditions(rawValue: ">")!),
                                      Lexeme.fact(fact, true)])
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
