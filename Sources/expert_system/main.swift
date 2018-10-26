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
var visited_stack = NSMutableOrderedSet(capacity: 42)

func is_already_checked(_ node: Node) -> Bool {
    return visited_stack.contains(node)
}

func increase_priority_of(_ node: Node) {
    if sub_goals_stack.contains(node) {
        sub_goals_stack.remove(node)
    }
    
    sub_goals_stack.insert(node, at: 0)
}

func check_for_not_visited_ancestors(_ node: Node) -> Bool {
    
    var flag: Bool = false
    
    node.relations.forEach { relation in
        if is_already_checked(relation.fact_1) == false {
            flag = true
        }
        
        if !(relation.is_direct || is_already_checked(relation.fact_2)) {
            flag = true
        }
    }
    
    return flag
}

func add_new_sub_goals(from node: Node) {
    node.relations.forEach { relation in
        if is_already_checked(relation.fact_1) == false {
            increase_priority_of(relation.fact_1)
        }
        
        if !(relation.is_direct || is_already_checked(relation.fact_2)) {
            increase_priority_of(relation.fact_2)
        }
    }
}

func resolve(_ main_node: Node) -> Bool {

    guard main_node.relations.count > 0 else {
        return main_node.state
    }
    
    sub_goals_stack.insert(main_node, at: 0)
    
    while (sub_goals_stack.count > 0) {
        
        let new_goal = sub_goals_stack.firstObject as! Node
        
        visited_stack.insert(new_goal, at: 0)
        
        let has_not_visited_ancestors = check_for_not_visited_ancestors(new_goal)
        
        if has_not_visited_ancestors {
            add_new_sub_goals(from: new_goal)
        } else {
            let resolved_state = new_goal.resolve
            new_goal.state = resolved_state
            sub_goals_stack.remove(new_goal)
        }
    }
    
    return main_node.state
}

goals.forEach { goal in
    
    print("Resolving \(goal.symbol)")
    
    print(resolve(goal))
    
}


// Main algo here

 

