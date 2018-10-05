//
//  Lexer+create_lexemes.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/5/18.
//

import Foundation

fileprivate let separate_query_reg_exp = try! NSRegularExpression(pattern: "\\s*([!A-Z +]+)\\s*(=>){1}\\s*([!A-Z +]+)\\s*(?:#.*)?",
                                                                  options: [.dotMatchesLineSeparators])

fileprivate let default_query = try! NSRegularExpression(pattern: "\\s*([A-Z]{1})\\s*([+]{1})\\s*", options: .allowCommentsAndWhitespace)

extension Lexer {
    public func create_lexemes(from line: String) {
        
        do {
            let components = try separate_query(in: line)
            
            print(components)
            
            resolve_facts(components.facts)
            
        } catch {}
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
    
    private func resolve_facts(_ facts: String) {
        // Stop here
    }
}
