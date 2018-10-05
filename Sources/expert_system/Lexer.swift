//
//  Lexer.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/4/18.
//

import Foundation

class Lexer: NSObject {
    
    private var m_fileContent: String = ""
    
    public func promt() throws {
        let filePath = try parseInput()
        
        m_fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
    }
    
    public func create_lexemes() throws {
        
        guard m_fileContent.isEmpty == false else {
            throw ESError.fileIsEmpty
        }
        
        let lines = m_fileContent.split(separator: "\n").map { String($0) }
        
        lines.forEach { (line) in
            create_lexemes(from: line)
        }
    }
}

// CLI stuff
extension Lexer {
    private func parseInput() throws -> String {
        
        guard CommandLine.argc == 2 else {
            throw ESError.invalidNumberOfCLIArguments
        }
    
        var isDir: ObjCBool = true
        let expandedPath = NSString(string: CommandLine.arguments[1]).expandingTildeInPath
        guard FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDir) && !isDir.boolValue else {
            throw ESError.fileDoesNotExist
        }
        
        guard FileManager.default.isReadableFile(atPath: expandedPath) else {
            throw ESError.fileCantBeRead
        }
        
        return expandedPath
    }
}


