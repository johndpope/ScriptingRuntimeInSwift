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

public enum TokenizerError: Error, LocalizedError {
    case UnexpectedSymbol(lineNumber: Int, closeTo: String, range: Range<String.Index>)
    
    public var errorDescription: String? {
        switch self {
        case .UnexpectedSymbol(let lineNumber, let closeTo, _):
            return "Unexpected symbol at line \(lineNumber) close to:\(closeTo)"
        }
    }
}

// All possible token types
// Each token has an associated type that indicates the range where the token was found
// in the original program's text
// This is useful for debugging
public enum Token {
    case sub(Range<String.Index>)
    case end(Range<String.Index>)
    case call(Range<String.Index>)
    case set(Range<String.Index>)
    case loop(Range<String.Index>)
    case left(Range<String.Index>)
    case right(Range<String.Index>)
    case forward(Range<String.Index>)
    case backward(Range<String.Index>)
    case penup(Range<String.Index>)
    case pendown(Range<String.Index>)
    case home(Range<String.Index>)
    case color(Range<String.Index>)
    case ifstart(Range<String.Index>)
    case equal(Range<String.Index>)
    case notequal(Range<String.Index>)
    case lessthan(Range<String.Index>)
    case lessthanequal(Range<String.Index>)
    case greaterthan(Range<String.Index>)
    case greaterthanequal(Range<String.Index>)
    case plus(Range<String.Index>)
    case minus(Range<String.Index>)
    case times(Range<String.Index>)
    case divide(Range<String.Index>)
    case power(Range<String.Index>)
    case openparen(Range<String.Index>)
    case closeparen(Range<String.Index>)
    case name(Range<String.Index>, String)
    case num(Range<String.Index>, Int)
}

// regular expression : how to tokenize
var conversions: [(String, (Range<String.Index>, String) -> Token?)] =
    [(";.*", { _,_ in nil }),  // comments
     ("[ \t\n\r]", { _,_ in nil }),
     ("sub", { r,_ in .sub(r) }),
     ("repeat", { r,_ in .loop(r) }),
     ("end", { r,_ in .end(r) }),
     ("call", { r,_ in .call(r) }),
     ("set", { r,_ in .set(r) }),
     ("left", { r,_ in .left(r) }),
     ("right", { r,_ in .right(r) }),
     ("forward", { r,_ in .forward(r) }),
     ("backward", { r,_ in .backward(r) }),
     ("penup", { r,_ in .penup(r) }),
     ("pendown", { r,_ in .pendown(r) }),
     ("home", { r,_ in .home(r) }),
     ("color", { r,_ in .color(r) }),
     ("if", { r,_ in .ifstart(r) }),
     ("=", { r,_ in .equal(r) }),
     ("!=", { r,_ in .notequal(r) }),
     ("<=", { r,_ in .lessthanequal(r) }),
     (">=", { r,_ in .greaterthanequal(r) }),
     ("<", { r,_ in .lessthan(r) }),
     (">", { r,_ in .greaterthan(r) }),
     ("\\+", { r,_ in .plus(r) }),
     ("-", { r,_ in .minus(r) }),
     ("\\*", { r,_ in .times(r) }),
     ("/", { r,_ in .divide(r) }),
     ("\\^", { r,_ in .power(r) }),
     ("\\(", { r,_ in .openparen(r) }),
     ("\\)", { r,_ in .closeparen(r) }),
     ("[a-zA-Z][a-zA-Z0-9]*", { r,str in .name(r, str) }),
     ("-?[0-9]+", { r,str in .num(r, Int(str)!) })]

public func tokenize(text: String) throws -> [Token] {
    var tokens: [Token] = [Token]()
    var remaining = text
    var tokenRange: Range<String.Index> = text.startIndex..<text.startIndex
    while remaining.count > 0 {
        var found = false
        for (regExpStr, creator) in conversions {
            // ^ is for matching at the start of the string
            if let foundRange = remaining.range(of: "^\(regExpStr)", options: [.regularExpression, .caseInsensitive]) {
                found = true
                let distance = remaining.distance(from: foundRange.lowerBound, to: foundRange.upperBound)
                let sie: String.Index = text.index(tokenRange.upperBound, offsetBy: distance)
                tokenRange = tokenRange.upperBound..<sie
                let foundString = remaining[foundRange]
                if let token = creator(tokenRange, String(foundString)) {
                    tokens.append(token)
                }
                
                remaining.removeSubrange(foundRange)
            }
        }
        if !found {
            // get line of error
            let rangeBefore = text.startIndex...tokenRange.upperBound
            let textUpTo = String(text[rangeBefore])
            let lineNumber = textUpTo.split(separator: "\n", omittingEmptySubsequences: false).count
            let closeTo = String(remaining.split(separator: "\n").first!)
            let errorRange = tokenRange.upperBound..<text.index(tokenRange.upperBound, offsetBy: closeTo.count)
            throw TokenizerError.UnexpectedSymbol(lineNumber: lineNumber, closeTo: closeTo, range: errorRange)
        }
    }
    return tokens
}
