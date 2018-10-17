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

let parser = Parser()

do {
    try parser.parse(lexemes: lexer.m_lexemes)
} catch {
    terminate_me_plz("\(error)")
}
