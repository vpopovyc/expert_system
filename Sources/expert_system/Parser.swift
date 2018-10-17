//
//  File.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/17/18.
//

import Foundation

class Parser {
    
    private var facts_graph: Set<Node>
    
    init() {
        facts_graph = []
    }
    
    func parse(lexemes: [Lexeme]) throws {
        var i: Int = 0
        let i_max: Int = lexemes.count
        
        let get_next_lexeme = { () throws -> Lexeme in
            guard i + 1 < i_max else {
                throw ESError.expressionIsNotValid
            }
            i += 1
            return lexemes[i]
        }
        
        while (i < i_max) {
            let lexeme = lexemes[i]
            
            if case .fact(let symbol_1) = lexeme {
                let next_lexeme = try get_next_lexeme()
                
                // Expression of type: fact_1 -> fact_2 -> op_type -> conclusion_op -> fact_3
                // EX: 'G + H => F'
                if case .fact(let symbol_2) = next_lexeme {
                    
                    let op_lexeme = try get_next_lexeme()
                    guard case .condition(let op_type) = op_lexeme else {
                        throw ESError.expressionIsNotValid
                    }
                    
                    let conclusion_op_lexeme = try get_next_lexeme()
                    guard case .condition(let conclusion_op) = conclusion_op_lexeme else {
                        throw ESError.expressionIsNotValid
                    }
                    
                    let conclusion_symbol_lexeme = try get_next_lexeme()
                    guard case .fact(let symbol_3) = conclusion_symbol_lexeme else {
                        throw ESError.expressionIsNotValid
                    }
                    
                    create_two_to_one_relation(symbol_1, op_type, symbol_2, conclusion_op, symbol_3)
                }
                
                // Expression of type: fact_1 -> conclusion_op -> fact_2
                // EX: 'G => F'
                if case .condition(let conclusion_op) = next_lexeme {
                    
                    let symbol_2_lexeme = try get_next_lexeme()
                    guard case .fact(let symbol_2) = symbol_2_lexeme else {
                        throw ESError.expressionIsNotValid
                    }
                    
                    print(symbol_1, conclusion_op, symbol_2)
                }
            }
            
            // Expression of type: not_condition -> fact_1 -> conclusion_op -> fact_2
            // EX: "!C => T"
            if case .condition(let not_condition) = lexeme {
                
                let symbol_1_lexeme = try get_next_lexeme()
                guard case .fact(let symbol_1) = symbol_1_lexeme else {
                    throw ESError.expressionIsNotValid
                }
                
                let conclusion_op_lexeme = try get_next_lexeme()
                guard case .condition(let conclusion_op) = conclusion_op_lexeme else {
                    throw ESError.expressionIsNotValid
                }
                
                let symbol_2_lexeme = try get_next_lexeme()
                guard case .fact(let symbol_2) = symbol_2_lexeme else {
                    throw ESError.expressionIsNotValid
                }
                
                print(not_condition, symbol_1, conclusion_op, symbol_2)
            }
            
            if case .fact_to_find(let symbol) = lexeme {
                ()
//                print(symbol)
            }
            
            if case .fact_true(let symbol) = lexeme {
                ()
//                print(symbol)
            }
            
            i += 1
        }
    }
    
    private func create_two_to_one_relation(_ symbol_1: Character,
                                            _ op_type: Conditions,
                                            _ symbol_2: Character,
                                            _ conclusion_op: Conditions,
                                            _ symbol_3: Character) {
        let node_1 = Node(named: symbol_1)
        let node_2 = Node(named: symbol_2)
        let node_3 = Node(named: symbol_3)
        
        let relation = Relation(of: node_1, and: node_2, like: op_type, to: node_3)
        
        node_3.relations.append(relation)
        print(relation, node_3)
    }
}
