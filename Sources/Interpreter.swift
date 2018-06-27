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
    var inProgress: Bool {get}
    var lookupTable: [String : StatementList] {get set} // subroutines
    var variableTable: [String: Int] {get set} // variables
    func addTurn(angle: Int, turn: Turn)
    func addMove(distance: Int, movement: Movement)
    func goHome(home: Home)
    func changePen(down: Bool, penChange: PenChange)
    func changeColor(color: Int, colorChange: ColorChange)
    func variableChanged(name: String, value: Int, varSet: VarSet)
    func log(str: String, printStatement: PrintStatement)
    func play()
    func pause()
    func clear()
}

extension TurtlePlayer {
    public mutating func interpret(statements: StatementList) {
        for statement in statements {
            switch (statement) {
            case let turn as Turn:
                var angle = evaluate(expression: turn.angle)
                if turn.negate { angle = -angle }
                addTurn(angle: angle, turn: turn)
            case let move as Movement:
                var distance = evaluate(expression: move.distance)
                if move.negate { distance = -distance }
                addMove(distance: distance, movement: move)
            case let home as Home:
                goHome(home: home)
            case let penchange as PenChange:
                changePen(down: penchange.down, penChange: penchange)
            case let colorchange as ColorChange:
                changeColor(color: evaluate(expression: colorchange.number), colorChange: colorchange)
            case let printstatement as PrintStatement:
                if let expr = printstatement.expression {
                    log(str: "\(evaluate(expression: expr))", printStatement: printstatement)
                } else if let str = printstatement.string {
                    let strRevised = handleInterpolation(str)
                    log(str: strRevised, printStatement: printstatement)
                }
            case let subcall as SubCall:
                interpret(statements: lookupTable[subcall.name]!)
            case let loop as Loop:
                for _ in 0..<evaluate(expression: loop.times) {
                    interpret(statements: loop.statementList)
                }
            case let subdec as Sub:
                lookupTable[subdec.name] = subdec.statementList
            case let varset as VarSet:
                let value = evaluate(expression: varset.value)
                variableTable[varset.name] = value
                variableChanged(name: varset.name, value: value, varSet: varset)
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
        case let name as StringLiteral:
            // should check if variable actually in variableTable
            return variableTable[name.string]!
        case let num as NumberLiteral:
            return num.number
        default:
            return 0
        }
    }
    
    func handleInterpolation(_ original: String) -> String {
        var replacement = original
        let regex = try! NSRegularExpression(pattern: "\\$[a-zA-Z][a-zA-Z0-9]*", options: [])
        var startLocation: Int = 0
        while let match = regex.firstMatch(in: replacement, options: [], range: NSRange(location: startLocation, length: replacement.count - startLocation)) {
            let identifierRange = NSRange(location: match.range.lowerBound + 1, length: match.range.length - 1) // exclude dollar sign
            let start = replacement.index(replacement.startIndex, offsetBy: identifierRange.lowerBound)
            let end = replacement.index(replacement.startIndex, offsetBy: identifierRange.upperBound)
            let identifier = String(replacement[start..<end])
            if let value = variableTable[identifier] {
                let start = replacement.index(replacement.startIndex, offsetBy: identifierRange.lowerBound - 1)
                replacement.replaceSubrange(start..<end, with: "\(value)")
                startLocation = identifierRange.lowerBound
            } else {
                startLocation = identifierRange.upperBound
            }
        }
        return replacement
    }
}
