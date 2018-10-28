//
//  utilities.swift
//  expert_system
//
//  Created by Vladyslav Popovych on 10/4/18.
//

import Darwin

public func terminate_me_plz(_ error: String = "") -> Never  {
    fputs(error+"\n", stderr)
    exit(EXIT_FAILURE)
}

#if swift(>=4.2)
#else
    // In Swift 4.0 missing
extension String {
    mutating func removeAll(where predicate: (Character) -> Bool) {
        let new_self = self.filter { !predicate($0) }
        self = new_self
    }
    
    func firstIndex(where predicate: (Character) throws -> Bool) rethrows -> String.Index? {
        return try self.index(where: predicate)
    }
}

extension Bool {
    mutating func toggle() {
        self = !self
    }
}
#endif
