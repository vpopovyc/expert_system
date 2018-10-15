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


