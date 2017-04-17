//
//  Parser.swift
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

// Recursive Descent Parser of Grammar in cfg.txt

public class Parser {
    let tokens: [Token]
    var index: Int = 0
    var current: Token { return tokens[index] }
    var lookahead: Token { return tokens[(index + 1)] }
    
    
    public init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parseSubDec() -> Sub? {
        if case .sub = current, case let .name(tocall) = lookahead {
            index += 2
            let sub = Sub(name: tocall, statementList: parseStatementList())
            if case .end = current {
                index += 1
                return sub
            }
        }
        return nil
    }
    
    func parseLoop() -> Loop? {
        if case .loop = current, case let .num(times) = lookahead {
            index += 2
            let loop = Loop(times: times, statementList: parseStatementList())
            if case .end = current {
                index += 1
                return loop
            }
        }
        return nil
    }
    
    func parseSubCall() -> SubCall? {
        if case let .name(tocall) = current {
            index += 1
            return SubCall(name: tocall)
        }
        return nil
    }
    
    func parseMovement() -> Movement? {
        if case .forward = current, case let .num(value) = lookahead {
            index += 2
            return Movement(distance: value)
        } else if case .backward = current, case let .num(value) = lookahead {
            index += 2
            return Movement(distance: -value)
        }
        return nil
    }
    
    func parseTurn() -> Turn? {
        if case .left = current, case let .num(value) = lookahead {
            index += 2
            return Turn(angle: value)
        } else if case .right = current, case let .num(value) = lookahead {
            index += 2
            return Turn(angle: -value)
        }
        return nil
    }
    
    func parseStatement() -> Statement? {
        switch current {
        case .sub:
            return parseSubDec()
        case .loop:
            return parseLoop()
        case .right:
            return parseTurn()
        case .forward:
            return parseMovement()
        case .backward:
            return parseMovement()
        case .left:
            return parseTurn()
        case .name:
            return parseSubCall()
        default:
            return nil
        }
    }
    
    func parseStatementList() -> StatementList {
        var statements: StatementList = [Statement]()
        while index < tokens.count {
            if let statement = parseStatement() {
                statements.append(statement)
            } else {
                break
            }
        }
        return statements
    }
    
    public func parse() -> StatementList {
        return parseStatementList()
    }
    
}
