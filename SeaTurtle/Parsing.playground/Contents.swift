//: Playground - noun: a place where people can play

import Cocoa
@testable import SeaTurtleEngine

func evaluate(expression: Expression) -> Int {
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
        return 1
    case let num as Int:
        return num
    default:
        return 0
    }
}

let program = "FORWARD (5 - (1 ^ 4 - 3 * -(4 + 5) - 4 / (2 + 2) + 3) ^ 2 + 5) / 7 LEFT 40"
let tokens = try! tokenize(text: program)
let parser = Parser(tokens: tokens)
let sl = parser.parse()
let s = sl[0] as! Movement
print(s)
print(evaluate(expression: s.distance))

let prog2 = "LEFT 80 RIGHT 70 FORWARD 10 SUB SQUARE FORWARD 10 RIGHT 90 FORWARD 10 RIGHT 90 FORWARD 10 RIGHT 90 FORWARD 10 END LEFT 5 FORWARD 10 SQUARE FORWARD 20"

let tokens2 = try! tokenize(text: prog2)
let parser2 = Parser(tokens: tokens2)
let parsed2 = parser2.parse()

