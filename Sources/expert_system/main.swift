import Foundation

let lexer = Lexer()

// Check for validity of file
// Read file content
do {
    try lexer.promt()
} catch {
    terminate_me_plz("usage: ./expert_system valid_file 😩\n\(error)")
}


// Create lexemes
// Make
do {
    try lexer.create_lexemes()
} catch {
    terminate_me_plz("\(error)")
}


// Parse lexemes
let parser = Parser()

do {
    try parser.parse(lexemes: lexer.m_lexemes)
    
} catch {
    terminate_me_plz("\(error)")
}

let graph = parser.facts_graph
let goals = parser.goals

var sub_goals_stack = NSMutableOrderedSet(capacity: 42)
var already_proved: Set<Node> = []

let quick_test: (Node) -> Bool = {
    return sub_goals_stack.contains($0) || already_proved.contains($0)
}

func check_for_final_leaf_node(_ node: Node) -> Bool {
    return node.relations.reduce(into: 0) {
        if [Conditions.then, Conditions.not].contains($1.op_type) {
            $0 += quick_test($1.fact_1) ? 1 : 0
        } else {
            $0 += quick_test($1.fact_1) && quick_test($1.fact_2) ? 1 : 0
        }
    } == node.relations.count
}

func add_new_sub_goals(from node: Node) {
    node.relations.forEach {
        if [Conditions.then, Conditions.not].contains($0.op_type) {
            if !quick_test($0.fact_1) {
                sub_goals_stack.insert($0.fact_1, at: 0)
            }
        } else {
            if !quick_test($0.fact_1) {
                sub_goals_stack.insert($0.fact_1, at: 0)
            }
            
            if !quick_test($0.fact_2) {
                sub_goals_stack.insert($0.fact_2, at: 0)
            }
        }
    }
}

var resolve: (Node) -> Bool = { main_node in

    guard main_node.relations.count > 0 else {
        return main_node.state
    }
    
    main_node.relations.forEach { relation in
        let sub_goal_1 = relation.fact_1
        
        if !sub_goals_stack.contains(sub_goal_1) && !already_proved.contains(sub_goal_1) {
            sub_goals_stack.insert(sub_goal_1, at: 0)
        }
        
        if [Conditions.then, Conditions.not].contains(relation.op_type) == false {
            let sub_goal_2 = relation.fact_2
            
            if !sub_goals_stack.contains(sub_goal_2) && !already_proved.contains(sub_goal_2) {
                sub_goals_stack.insert(sub_goal_2, at: 0)
            }
        }
    }
    
    while (sub_goals_stack.count > 0) {

        let new_goal = sub_goals_stack.firstObject as! Node
        
        let is_final_leaf = check_for_final_leaf_node(new_goal)
        
        if is_final_leaf {
            let resolved_state = new_goal.resolve
            new_goal.state = resolved_state
            already_proved.insert(new_goal)
            sub_goals_stack.remove(new_goal)
        } else {
            add_new_sub_goals(from: new_goal)
        }
    }
    
    let resolved_state = main_node.resolve
    main_node.state = resolved_state
    
    return main_node.state
}

goals.forEach { goal in
    
    print("Resolving \(goal.symbol)")
    
    print(resolve(goal))
    
}


// Main algo here

 

