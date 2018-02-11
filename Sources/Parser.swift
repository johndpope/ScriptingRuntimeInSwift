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

public enum ParserError: Error, LocalizedError {
    case ParseError(explanation: String, token: Token)
    
    public var errorDescription: String? {
        switch self {
        case .ParseError(let explanation, let token):
            return "\(explanation) at token:\(token)"
        }
    }
}

// Recursive Descent Parser of Grammar in cfg.txt

public class Parser {
    let tokens: [Token]
    var index: Int = 0
    var current: Token { return tokens[index] }
    var lookahead: Token { return tokens[(index + 1)] }
    
    
    public init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parsePoint() throws -> Expression? {
        //print("parsing point of \(current)")
        switch current {
        case let .name(_, varname):
            index += 1
            return varname
        case let .num(_, value):
            index += 1
            return value
        case .openparen:
            index += 1
            let expr = try parseExpression()
            if case .closeparen = current {
                index += 1 // acounts for closeparen
                return expr
            }
            print("expected close paren, got \(current)")
            throw ParserError.ParseError(explanation: "Closing parenthesis ) missing", token: current)
        case .minus:
            let oldM = current
            index += 1
            if let expr = try parsePoint() {
                return UnaryOperation(operation: oldM, value: expr)
            }
            throw ParserError.ParseError(explanation: "Invalid token following minus sign", token: current)
        default:
            print("invalid point \(current) for parsing")
            throw ParserError.ParseError(explanation: "Invalid point for parsing", token: current) // unary or single value
        }
    }
    
    func parseFactor() throws -> Expression? {
        //print("parsing factor of \(current)")
        if let left = try parsePoint() {
            if index >= tokens.count { return left } // incase expression is end
            switch current {
            case .power:
                let oldP = current
                index += 1
                if let right = try parseFactor() {
                    return BinaryOperation(operation: oldP, left: left, right: right)
                }
                throw ParserError.ParseError(explanation: "Couldn't parse factor on right side of ^ sign", token: current)
            default:
                return left // unary or single value
            }
        }
        print("couldn't parse point from expression")
        throw ParserError.ParseError(explanation: "Couldn't parse point from factor", token: current)
    }
    
    func parseTerm() throws -> Expression? {
        //print("parsing term of \(current)")
        if let down = try parseFactor() {
            var left = down
            outter: while true {
                if index >= tokens.count { return left } // incase expression is end
                switch current {
                case .times:
                    let oldT = current
                    index += 1
                    if let right = try parseFactor() {
                        left = BinaryOperation(operation: oldT, left: left, right: right)
                    } else {
                        throw ParserError.ParseError(explanation: "Couldn't parse factor on right side of * sign", token: current)
                    }
                case .divide:
                    let oldD = current
                    index += 1
                    if let right = try parseFactor() {
                        left = BinaryOperation(operation: oldD, left: left, right: right)
                    } else {
                        throw ParserError.ParseError(explanation: "Couldn't parse factor on right side of / sign", token: current)
                    }
                default:
                    break outter
                }
            }
            return left
        }
        print("couldn't parse factor from term")
        throw ParserError.ParseError(explanation: "Couldn't parse factor from term", token: current)
    }
    
    func parseExpression() throws -> Expression? {
        //print("parsing expression of \(current)")
        if let down = try parseTerm() {
            var left = down
            outter: while true {
                if index >= tokens.count { return left } // incase expression is end
                //print("current is \(current)")
                switch current {
                case .plus:
                    let oldP = current
                    index += 1
                    if let right = try parseTerm() {
                        left = BinaryOperation(operation: oldP, left: left, right: right)
                    } else {
                        throw ParserError.ParseError(explanation: "Couldn't parse term on right side of + sign", token: current)
                    }
                case .minus:
                    let oldM = current
                    index += 1
                    if let right = try parseTerm() {
                        left = BinaryOperation(operation: oldM, left: left, right: right)
                    } else {
                        throw ParserError.ParseError(explanation: "Couldn't parse term on right side of - sign", token: current)
                    }
                default:
                    break outter
                }
            }
            return left
        }
        print("Couldn't parse term from expression.")
        throw ParserError.ParseError(explanation: "Couldn't parse term from expression", token: current)
    }
    
    func parseBooleanExpression() throws -> BooleanExpression? {
        if let left = try parseExpression() {
            switch current {
            case .equal, .notequal, .lessthan, .lessthanequal, .greaterthan, .greaterthanequal:
                    let operation = current
                    index += 1
                    if let right = try parseExpression() {
                        return BooleanExpression(operation: operation, left: left, right: right)
                    } else {
                        throw ParserError.ParseError(explanation: "Couldn't parse right side of boolean expression", token: current)
                    }
            default:
                print("Unexpected operator in middle of boolean expression.")
                throw ParserError.ParseError(explanation: "Unexpected operator in middle of boolean expression.", token: current)
            }
        }
        print("Couldn't parse boolean expression.")
        throw ParserError.ParseError(explanation: "Couldn't parse left side of boolean expression", token: current)
    }
    
    func parseSubDec() throws -> Sub? {
        if case .sub = current, case let .name(_,tocall) = lookahead {
            index += 2
            let sub = Sub(name: tocall, statementList: try parseStatementList())
            if case .end = current {
                index += 1
                return sub
            } else {
                throw ParserError.ParseError(explanation: "Subroutine must be ended by end", token: current)
            }
        }
        throw ParserError.ParseError(explanation: "Expected name after subroutine declaration", token: lookahead)
    }
    
    func parseSet() throws -> VarSet? {
        if case .set = current, case let .name(_,tocall) = lookahead {
            index += 2
            if let expr = try parseExpression() {
                return VarSet(name: tocall, value: expr)
            } else {
                throw ParserError.ParseError(explanation: "Expected expression after variable name", token: current)
            }
        } else {
            throw ParserError.ParseError(explanation: "Expected name after set", token: lookahead)
        }
    }
    
    func parseLoop() throws -> Loop? {
        if case .loop = current {
            index += 1
            if let expr = try parseExpression() {
                let loop = Loop(times: expr, statementList: try parseStatementList())
                if case .end = current {
                    index += 1
                    return loop
                }
            }
        }
        throw ParserError.ParseError(explanation: "Expected expression after loop", token: lookahead)
    }
    
    func parseSubCall() throws -> SubCall? {
        if case .call = current, case let .name(_, tocall) = lookahead {
            index += 2
            return SubCall(name: tocall)
        }
        throw ParserError.ParseError(explanation: "Expected call followed by the name of a subroutine", token: lookahead)
    }
    
    func parseMovement() throws -> Movement? {
        if case .forward = current {
            index += 1
            if let expr = try parseExpression() {
                return Movement(distance: expr, negate: false)
            }
        } else if case .backward = current {
            index += 1
            if let expr = try parseExpression() {
                return Movement(distance: expr, negate: true)
            }
        }
        throw ParserError.ParseError(explanation: "Expected movement to be forward or backward", token: current)
    }
    
    func parseTurn() throws -> Turn? {
        if case .left = current {
            index += 1
            if let expr = try parseExpression() {
                return Turn(angle: expr, negate: false)
            }
        } else if case .right = current {
            index += 1
            if let expr = try parseExpression() {
                return Turn(angle: expr, negate: true)
            }
        }
        throw ParserError.ParseError(explanation: "Expected turn to be right or left", token: current)
    }
    
    func parseControl() throws -> Control? {
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
            if let expr = try parseExpression() {
                return ColorChange(number: expr)
            }
        }
        throw ParserError.ParseError(explanation: "Could not identify control for parsing", token: current)
    }
    
    func parseIfStatement() throws -> IfStatement? {
        if case .ifstart = current {
            index += 1
            if let boolExpr = try parseBooleanExpression() {
                let statements = try parseStatementList()
                if case .end = current {
                    index += 1 // for end
                    return IfStatement(booleanExpression: boolExpr, statementList: statements)
                }
            } else {
                throw ParserError.ParseError(explanation: "Expected boolean expression after if statement", token: current)
            }
        }
        
        return nil
    }
    
    func parseStatement() throws -> Statement? {
        switch current {
        case .sub:
            return try parseSubDec()
        case .loop:
            return try parseLoop()
        case .set:
            return try parseSet()
        case .right:
            return try parseTurn()
        case .forward:
            return try parseMovement()
        case .backward:
            return try parseMovement()
        case .left:
            return try parseTurn()
        case .call:
            return try parseSubCall()
        case .home:
            return try parseControl()
        case .penup:
            return try parseControl()
        case .pendown:
            return try parseControl()
        case .color:
            return try parseControl()
        case .ifstart:
            return try parseIfStatement()
        default:
            return nil
        }
    }
    
    func parseStatementList() throws -> StatementList {
        var statements: StatementList = [Statement]()
        while index < tokens.count {
            if let statement = try parseStatement() {
                statements.append(statement)
            } else {
                break
            }
        }
        return statements
    }
    
    public func parse() throws -> StatementList {
        return try parseStatementList()
    }
    
}
