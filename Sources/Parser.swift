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
    
    func parsePoint() -> Expression? {
        //print("parsing point of \(current)")
        switch current {
        case let .name(varname):
            index += 1
            return varname
        case let .num(value):
            index += 1
            return value
        case .openparen:
            index += 1
            let expr = parseExpression()
            if case .closeparen = current {
                index += 1 // acounts for closeparen
                return expr
            }
            print("expected close paren, got \(current)")
            return nil
        case .minus:
            index += 1
            if let expr = parsePoint() {
                return UnaryOperation(operation: .minus, value: expr)
            }
            return nil
        default:
            print("invalid point \(current) for parsing")
            return nil // unary or single value
        }
    }
    
    func parseFactor() -> Expression? {
        //print("parsing factor of \(current)")
        if let left = parsePoint() {
            if index >= tokens.count { return left } // incase expression is end
            switch current {
            case .power:
                index += 1
                if let right = parseFactor() {
                    return BinaryOperation(operation: .power, left: left, right: right)
                }
                return nil
            default:
                return left // unary or single value
            }
        }
        print("couldn't parse point from expression")
        return nil
    }
    
    func parseTerm() -> Expression? {
        //print("parsing term of \(current)")
        if let down = parseFactor() {
            var left = down
            outter: while true {
                if index >= tokens.count { return left } // incase expression is end
                switch current {
                case .times:
                    index += 1
                    if let right = parseFactor() {
                        left = BinaryOperation(operation: .times, left: left, right: right)
                    } else {
                        return nil
                    }
                case .divide:
                    index += 1
                    if let right = parseFactor() {
                        left = BinaryOperation(operation: .divide, left: left, right: right)
                    } else {
                        return nil
                    }
                default:
                    break outter
                }
            }
            return left
        }
        print("couldn't parse factor from term")
        return nil
    }
    
    func parseExpression() -> Expression? {
        //print("parsing expression of \(current)")
        if let down = parseTerm() {
            var left = down
            outter: while true {
                if index >= tokens.count { return left } // incase expression is end
                //print("current is \(current)")
                switch current {
                case .plus:
                    index += 1
                    if let right = parseTerm() {
                        left = BinaryOperation(operation: .plus, left: left, right: right)
                    } else {
                        return nil
                    }
                case .minus:
                    index += 1
                    if let right = parseTerm() {
                        left = BinaryOperation(operation: .minus, left: left, right: right)
                    } else {
                        return nil
                    }
                default:
                    break outter
                }
            }
            return left
        }
        print("Couldn't parse term from expression.")
        return nil
        
    }
    
    func parseBooleanExpression() -> BooleanExpression? {
        if let left = parseExpression() {
            switch current {
            case .equal, .notequal, .lessthan, .lessthanequal, .greaterthan, .greaterthanequal:
                    let operation = current
                    index += 1
                    if let right = parseExpression() {
                        return BooleanExpression(operation: operation, left: left, right: right)
                    }
            default:
                print("Unexpected operator in middle of boolean expression.")
            }
        }
        print("Couldn't parse boolean expression.")
        return nil
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
    
    func parseSet() -> VarSet? {
        if case .set = current, case let .name(tocall) = lookahead {
            index += 2
            if let expr = parseExpression() {
                return VarSet(name: tocall, value: expr)
            }
        }
        return nil
    }
    
    func parseLoop() -> Loop? {
        if case .loop = current {
            index += 1
            if let expr = parseExpression() {
                let loop = Loop(times: expr, statementList: parseStatementList())
                if case .end = current {
                    index += 1
                    return loop
                }
            }
        }
        return nil
    }
    
    func parseSubCall() -> SubCall? {
        if case .call = current, case let .name(tocall) = lookahead {
            index += 2
            return SubCall(name: tocall)
        }
        return nil
    }
    
    func parseMovement() -> Movement? {
        if case .forward = current {
            index += 1
            if let expr = parseExpression() {
                return Movement(distance: expr, negate: false)
            }
        } else if case .backward = current {
            index += 1
            if let expr = parseExpression() {
                return Movement(distance: expr, negate: true)
            }
        }
        return nil
    }
    
    func parseTurn() -> Turn? {
        if case .left = current {
            index += 1
            if let expr = parseExpression() {
                return Turn(angle: expr, negate: false)
            }
        } else if case .right = current {
            index += 1
            if let expr = parseExpression() {
                return Turn(angle: expr, negate: true)
            }
        }
        return nil
    }
    
    func parseControl() -> Control? {
        if case .penup = current {
            index += 1
            return PenChange(down: false)
        } else if case .pendown = current {
            index += 1
            return PenChange(down: true)
        } else if case .home = current {
            index += 1
            return Home()
        } else if case .color = current {
            index += 1
            if let expr = parseExpression() {
                return ColorChange(number: expr)
            }
        }
        return nil
    }
    
    func parseIfStatement() -> IfStatement? {
        if case .ifstart = current {
            index += 1
            if let boolExpr = parseBooleanExpression() {
                let statements = parseStatementList()
                if case .end = current {
                    index += 1 // for end
                    return IfStatement(booleanExpression: boolExpr, statementList: statements)
                }
            }
        }
        
        return nil
    }
    
    func parseStatement() -> Statement? {
        switch current {
        case .sub:
            return parseSubDec()
        case .loop:
            return parseLoop()
        case .set:
            return parseSet()
        case .right:
            return parseTurn()
        case .forward:
            return parseMovement()
        case .backward:
            return parseMovement()
        case .left:
            return parseTurn()
        case .call:
            return parseSubCall()
        case .home:
            return parseControl()
        case .penup:
            return parseControl()
        case .pendown:
            return parseControl()
        case .color:
            return parseControl()
        case .ifstart:
            return parseIfStatement()
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
