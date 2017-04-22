//
//  Tokenizer.swift
//
//  SeaTurtle - A turtle graphics scripting language and runtime.
//  Copyright (C) 2017 David Kopec
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

enum TokenizerError: Error {
    case UnexpectedSymbol
}

// all possible token types
public enum Token {
    case sub
    case end
    case call
    case set
    case loop
    case left
    case right
    case forward
    case backward
    case plus
    case minus
    case times
    case divide
    case power
    case openparen
    case closeparen
    case name(String)
    case num(Int)
}

// regular expression : how to tokenize
var conversions: [(String, (String) -> Token?)] =
    [("[ \t\n]", { _ in nil }),
     ("sub", { _ in .sub }),
     ("repeat", { _ in .loop }),
     ("end", { _ in .end }),
     ("call", { _ in .call }),
     ("set", { _ in .set }),
     ("left", { _ in .left }),
     ("right", { _ in .right }),
     ("forward", { _ in .forward }),
     ("backward", { _ in .backward }),
     ("\\+", { _ in .plus }),
     ("-", { _ in .minus }),
     ("\\*", { _ in .times }),
     ("/", { _ in .divide }),
     ("\\^", { _ in .power }),
     ("\\(", { _ in .openparen }),
     ("\\)", { _ in .closeparen }),
     ("[a-zA-Z][a-zA-Z0-9]*", { str in .name(str) }),
     ("-?[0-9]+", { str in .num(Int(str)!) })]

public func tokenize(text: String) throws -> [Token] {
    var tokens: [Token] = [Token]()
    var remaining = text
    while remaining.characters.count > 0 {
        var found = false
        for (regExpStr, creator) in conversions {
            // ^ is for matching at the start of the string
            if let foundRange = remaining.range(of: "^\(regExpStr)", options: [.regularExpression, .caseInsensitive]) {
                found = true
                let foundString = remaining.substring(with: foundRange)
                if let token = creator(foundString) {
                    tokens.append(token)
                }
                remaining.removeSubrange(foundRange)
            }
        }
        if !found {
            throw TokenizerError.UnexpectedSymbol
        }
    }
    return tokens
}

let tokens = try! tokenize(text: " dog sub lkjsdf 54")
