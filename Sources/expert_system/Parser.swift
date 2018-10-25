//
//  File.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/17/18.
//

import Foundation

class Parser {
    
    public var facts_graph: Set<Node>
    
    public var goals: Set<Node>
    
    init() {
        facts_graph = []
        goals = []
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
                    
                    create_one_to_one_relation(symbol_1, conclusion_op, symbol_2)
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
                
                create_inversed_one_to_one_relation(not_condition, symbol_1, conclusion_op, symbol_2)
            }
            
            if case .fact_to_find(let symbol) = lexeme {
                try add_to_goals_node(named: symbol)
            }
            
            if case .fact_true(let symbol) = lexeme {
                try turn_on_node(named: symbol)
            }
            
            i += 1
        }
    }
    
    // Add good type check
    private func create_two_to_one_relation(_ symbol_1: Character,
                                            _ op_type: Conditions,
                                            _ symbol_2: Character,
                                            _ conclusion_op: Conditions,
                                            _ symbol_3: Character) {
        let node_1 = find_node(named: symbol_1)
        let node_2 = find_node(named: symbol_2)
        let node_3 = find_node(named: symbol_3)
        
        let relation = Relation(of: node_1, and: node_2, like: op_type, to: node_3)
        node_3.relations.append(relation)
        
        print("\(#function) \(symbol_1), \(symbol_2) to \(symbol_3)")
    }
    
    private func create_one_to_one_relation(_ symbol_1: Character,
                                            _ conclusion_op: Conditions,
                                            _ symbol_2: Character) {
        let node_1 = find_node(named: symbol_1)
        let node_2 = find_node(named: symbol_2)
        
        let relation = Relation(of: node_1, like: conclusion_op, to: node_2)
        node_2.relations.append(relation)
        
        print("\(#function) \(symbol_1) to \(symbol_2)")
    }
    
    private func create_inversed_one_to_one_relation(_ not_condition: Conditions,
                                                     _ symbol_1: Character,
                                                     _ conclusion_op: Conditions,
                                                     _ symbol_2: Character) {
        let node_1 = find_node(named: symbol_1)
        let node_2 = find_node(named: symbol_2)
        
        let relation = Relation(of: node_1, like: not_condition, to: node_2)
        node_2.relations.append(relation)
    }
    
    private func turn_on_node(named name: Character) throws {
        let node = Node(named: name)
        
        if facts_graph.contains(node) {
            guard let old_node = facts_graph.remove(node) else {
                terminate_me_plz("Swift lib died :(")
            }
            
            old_node.state.toggle()
            
            facts_graph.insert(old_node)
        } else {
            throw ESError.unknownInitialFacts
        }
    }
    
    private func add_to_goals_node(named name: Character) throws {
        let node = Node(named: name)
        
        if facts_graph.contains(node) {
            guard let old_node = facts_graph.remove(node) else {
                terminate_me_plz("Swift lib died :(")
            }
            
            facts_graph.insert(old_node)
            goals.insert(old_node)
        } else {
            throw ESError.unknownGoalQuery
        }
    }
    
    private func find_node(named name: Character) -> Node {
        let new_node = Node(named: name)
        
        if facts_graph.contains(new_node) {
            // Accuire node reference
            guard let found_node = facts_graph.remove(new_node) else {
                terminate_me_plz("Swift lib died :(")
            }
            // And place it back
            facts_graph.insert(found_node)
            return found_node
        } else {
            facts_graph.insert(new_node)
            return new_node
        }
    }
}
