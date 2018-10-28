//
//  Node+Relation.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/17/18.
//

import Foundation

class Node {
    
    public let symbol: Character
    
    public var state: Bool = false
    
    var relations: [Relation] = []
    
    var resolve: Bool {
        return relations.reduce(into: state) { if $0 == false { $0 = $1.resolve } }
    }
    
    init(named aName: Character) {
        symbol = aName
    }
    
    convenience init() {
        self.init(named: "0")
    }
}

class Relation {
    private static let op_tab: [Conditions : (Node, Node) -> Bool] = [
        .and : { $0.state && $1.state },
        .then : { node_1, _ in node_1.state },
        .not : { node_1, _ in !node_1.state },
        .or : { $0.state || $1.state },
        .xor : { $0.state != $1.state }
    ]
    
    // Relation defined by this nodes
    var fact_1: Node
    var fact_2: Node
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
    
    convenience init(of node_1: Node, like op_type: Conditions, to target_node: Node) {
        let fooNode = Node()
        self.init(of: node_1, and: fooNode, like: op_type, to: target_node)
    }
}

extension Node: Hashable, Equatable {
#if swift(>=4.2)
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
#else
    var hashValue: Int {
        return symbol.hashValue
    }
#endif
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}

extension Relation {
    var is_direct: Bool {
        return [Conditions.then, Conditions.not].contains(self.op_type)
    }
}
