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

protocol TurtlePlayer {
    var lookupTable: [String : StatementList] {get set}
    func addTurn(angle: Int)
    func addMove(distance: Int)
    func play()
    func clear()
}

extension TurtlePlayer {
    mutating func interpret(statements: StatementList) {
        for statement in statements {
            switch (statement) {
            case let turn as Turn:
                addTurn(angle: turn.angle)
            case let move as Movement:
                addMove(distance: move.distance)
            case let subcall as SubCall:
                interpret(statements: lookupTable[subcall.name]!)
            case let loop as Loop:
                for _ in 0..<loop.times {
                    interpret(statements: loop.statementList)
                }
            case let subdec as Sub:
                lookupTable[subdec.name] = subdec.statementList
            default:
                break
            }
        }
    }
}
