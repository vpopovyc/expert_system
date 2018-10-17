//
//  Node+Relation.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/17/18.
//

import Foundation

class Node {
    
    private let symbol: Character
    
    public var state: Bool = false
    
    var relations: [Relation] = []
    
    init(named aName: Character) {
        symbol = aName
    }
    
    convenience init() {
        self.init(named: "0")
    }
}

class Relation {
    private static let op_tab: [Conditions : (Node, Node) -> Bool] = [
        .and : { $0.state && $1.state }
    ]
    
    // Relation defined by this nodes
    let fact_1: Node
    let fact_2: Node
    // Relation apply this op to nodes
    let op_type: Conditions
    var resolve: Bool {
        let concrete_op = Relation.op_tab[op_type]! // Will fail every time or never
        return concrete_op(fact_1, fact_2)
    }
    // Relation define that node
    let fact_defined: Node

    init(of node_1: Node, and node_2: Node, like op_type: Conditions, to target_node: Node) {
        fact_1 = node_1
        fact_2 = node_2
        fact_defined = target_node
        self.op_type = op_type
    }
}

extension Node: Hashable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.symbol == rhs.symbol
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}