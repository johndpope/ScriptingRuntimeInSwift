//
//  Interpreter.swift
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

public protocol TurtlePlayer {
    var lookupTable: [String : StatementList] {get set} // subroutines
    var variableTable: [String: Int] {get set} // variables
    func addTurn(angle: Int)
    func addMove(distance: Int)
    func goHome()
    func changePen(down: Bool)
    func changeColor(color: Int)
    func play()
    func clear()
}

extension TurtlePlayer {
    public mutating func interpret(statements: StatementList) {
        for statement in statements {
            switch (statement) {
            case let turn as Turn:
                var angle = evaluate(expression: turn.angle)
                if turn.negate { angle = -angle }
                addTurn(angle: angle)
            case let move as Movement:
                var distance = evaluate(expression: move.distance)
                if move.negate { distance = -distance }
                addMove(distance: distance)
            case _ as Home:
                goHome()
            case let penchange as PenChange:
                changePen(down: penchange.down)
            case let colorchange as ColorChange:
                changeColor(color: evaluate(expression: colorchange.number))
            case let subcall as SubCall:
                interpret(statements: lookupTable[subcall.name]!)
            case let loop as Loop:
                for _ in 0..<evaluate(expression: loop.times) {
                    interpret(statements: loop.statementList)
                }
            case let subdec as Sub:
                lookupTable[subdec.name] = subdec.statementList
            case let varset as VarSet:
                variableTable[varset.name] = evaluate(expression: varset.value)
            case let ifstatement as IfStatement:
                if evaluate(booleanExpression: ifstatement.booleanExpression) {
                    interpret(statements: ifstatement.statementList)
                }
            default:
                break
            }
        }
    }
    
    public func evaluate(booleanExpression: BooleanExpression) -> Bool {
        let leftValue = evaluate(expression: booleanExpression.left)
        let rightValue = evaluate(expression: booleanExpression.right)
        switch booleanExpression.operation {
        case .equal:
            return leftValue == rightValue
        case .notequal:
            return leftValue != rightValue
        case .lessthan:
            return leftValue < rightValue
        case .lessthanequal:
            return leftValue <= rightValue
        case .greaterthan:
            return leftValue > rightValue
        case .greaterthanequal:
            return leftValue >= rightValue
        default:
            print("Unexpected boolean expression operator \(booleanExpression.operation) interpretted.")
            return false
        }
    }
    
    public func evaluate(expression: Expression) -> Int {
        switch expression {
        case let binop as BinaryOperation:
            switch binop.operation {
            case .plus:
                return evaluate(expression: binop.left) + evaluate(expression: binop.right)
            case .minus:
                return evaluate(expression: binop.left) - evaluate(expression: binop.right)
            case .times:
                return evaluate(expression: binop.left) * evaluate(expression: binop.right)
            case .divide:
                return evaluate(expression: binop.left) / evaluate(expression: binop.right)
            case .power:
                return Int(pow(Double(evaluate(expression: binop.left)), Double(evaluate(expression: binop.right))))
            default:
                return 0
            }
            
        case let unop as UnaryOperation:
            switch unop.operation {
            case .minus:
                return -evaluate(expression: unop.value)
            default:
                return 0
            }
        case let name as String:
            // should check if variable actually in variableTable
            return variableTable[name]!
        case let num as Int:
            return num
        default:
            return 0
        }
    }
}
