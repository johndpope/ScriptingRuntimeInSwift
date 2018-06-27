//
//  TurtleViewController.swift
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

import Cocoa
import SpriteKit
import SeaTurtleEngine

extension Int
{
    var deg2Rad : CGFloat
    {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}
extension CGFloat
{
    var rad2Deg: CGFloat
    {
        return self * 180 / CGFloat.pi
    }
}

// mainly for highlighting code currently running
protocol StepDelegate: class {
    func willStep(range: Range<String.Index>)
    func doneStepping()
}

class TurtleViewController: NSViewController, TurtlePlayer {
    var scene: SKScene?
    var turtle: SKSpriteNode = SKSpriteNode(imageNamed: "turtle")
    var stepTime: TimeInterval {
        return (parent?.representedObject as! DocRep).timeInterval.doubleValue
    }
    var steps: [(SKAction, Range<String.Index>)] = [(SKAction, Range<String.Index>)]()
    var curAngle: CGFloat = 90.deg2Rad
    var penDown: Bool = true
    var penColor: NSColor = .green
    var lookupTable: [String: StatementList] = [String: StatementList]()
    var variableTable: [String: Int] = [String: Int]()
    
    @objc dynamic var displayX: Int = 0
    @objc dynamic var displayY: Int = 0
    @objc dynamic var displayAngle: Int = 90
    @objc dynamic var displayColor: NSColor = .green
    @objc dynamic var displayPenDown: NSImage = #imageLiteral(resourceName: "pendown")
    @objc dynamic var displayVariableTable: NSMutableDictionary = NSMutableDictionary()
    var inProgress: Bool { return steps.count > 0 }
    
    var path = CGMutablePath()
    var line = SKShapeNode()
    
    var stopPlay = false
    
    weak var stepDelegate: StepDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        // setup scene
        scene = SKScene(size: view.frame.size)
        scene?.scaleMode = .aspectFill
        scene?.backgroundColor = NSColor.blue
        (view as! SKView).presentScene(scene)
        
        // reset turtle, lines
        clear()
    }
    
    private func resetTurtle() {
        turtle = SKSpriteNode(imageNamed: "turtle")
        curAngle = 90.deg2Rad
        turtle.position = CGPoint(x: (scene?.size.width)!/2, y: (scene?.size.height)!/2)
        turtle.zRotation = curAngle
        scene?.addChild(turtle)
    }
    
    private func resetLine() {
        path = CGMutablePath()
        line = SKShapeNode()
        path.move(to: self.turtle.position)
        line.path = path
        line.lineWidth = 1.0
        line.glowWidth = 0.1
        scene?.addChild(line)
    }
    
    func addTurn(angle: Int, turn: Turn) {
        curAngle += angle.deg2Rad
        let action1 = SKAction.rotate(toAngle: curAngle, duration: stepTime)
        let action2 = SKAction.customAction(withDuration: 0.0) { [tangle = curAngle] (node, float) in
            let tempAngle: Int = Int(tangle.rad2Deg) % 360
            self.displayAngle = tempAngle < 0 ? tempAngle + 360 : tempAngle
        }
        let combined = SKAction.sequence([action1, action2])
        steps.append((combined, turn.range))
    }
    
    func addMove(distance: Int, movement: Movement) {
        let dx = CGFloat(distance) * cos(curAngle)
        let dy = CGFloat(distance) * sin(curAngle)
        let action1 = SKAction.moveBy(x: dx, y: dy, duration: stepTime)
        let action2 = SKAction.customAction(withDuration: 0.0) { [unowned self, down = penDown, color = penColor, line = line, path = path](node, float) in
            if down {
                line.strokeColor = color
                path.addLine(to: self.turtle.position)
            } else {
                path.move(to: self.turtle.position)
            }
            self.displayX = Int(self.turtle.position.x)
            self.displayY = Int(self.turtle.position.y)
            line.path = path
        }
        let combined = SKAction.sequence([action1, action2])
        steps.append((combined, movement.range))
    }
    
    func goHome(home: Home) {
        curAngle = 90.deg2Rad
        let action1 = SKAction.move(to: CGPoint(x: (scene?.size.width)!/2, y: (scene?.size.height)!/2), duration: stepTime)
        let action2 = SKAction.rotate(toAngle: curAngle, duration: stepTime, shortestUnitArc: true)
        let action3 = SKAction.customAction(withDuration: 0.0) { [unowned self](node, float) in
            self.path.move(to: self.turtle.position)
            self.displayX = Int(self.turtle.position.x)
            self.displayY = Int(self.turtle.position.y)
            self.displayAngle = 90
        }
        let combined = SKAction.sequence([action1, action2, action3])
        steps.append((combined, home.range))
    }
    
    func changePen(down: Bool, penChange: PenChange) {
        penDown = down
        let action = SKAction.customAction(withDuration: 0.0) { [unowned self, tdown = penDown](node, float) in
            self.displayPenDown = tdown ? #imageLiteral(resourceName: "pendown") : #imageLiteral(resourceName: "penup")
        }
        steps.append((action, penChange.range))
    }
    
    func changeColor(color: Int, colorChange: ColorChange) {
        resetLine()
        
        switch color {
        case 0:
            penColor = .yellow
        case 1:
            penColor = .orange
        case 2:
            penColor = .red
        case 3:
            penColor = .magenta
        default:
            penColor = .green
        }
        
        let action = SKAction.customAction(withDuration: 0.0) { [unowned self, tcolor = penColor](node, float) in
            self.displayColor = tcolor
        }
        steps.append((action, colorChange.range))
    }
    
    func variableChanged(name: String, value: Int, varSet: VarSet) {
        let action = SKAction.customAction(withDuration: 0.0) { [unowned self, tname = name, tvalue = value](node, float) in
            //self.displayVariableTable[tname] = tvalue
            self.willChangeValue(forKey: "displayVariableTable")
            self.displayVariableTable.setValue(tvalue, forKey: tname)
            self.didChangeValue(forKey: "displayVariableTable")
        }
        steps.append((action, varSet.range))
    }
    
    func play() {
        stepDelegate?.doneStepping()
        guard !turtle.isPaused else {
            turtle.isPaused = false
            return
        }
        guard !stopPlay else {
            stopPlay = false
            return
        }
        if !steps.isEmpty {
            let (step, _) = steps.removeFirst()
            step.duration = stepTime
            
            turtle.run(step) { [weak self] in
                self?.play()
            }
        }
//        turtle.run(SKAction.sequence(steps))
    }
    
    func pause() {
        turtle.isPaused = true
    }
    
    func step() {
        if !steps.isEmpty {
            turtle.isPaused = false
            stopPlay = true
            let (step, range) = steps.removeFirst()
            stepDelegate?.willStep(range: range)
            step.duration = stepTime
            turtle.run(step)
        } else {
            stepDelegate?.doneStepping()
        }
    }
    
    func clear() {
        turtle.removeAllActions()
        lookupTable.removeAll()
        variableTable.removeAll()
        steps.removeAll()
        scene?.removeAllChildren()
        
        curAngle = 90.deg2Rad
        penDown = true
        penColor = .green
        
        displayX = 0
        displayY = 0
        displayAngle = 90
        displayColor = .green
        displayPenDown = #imageLiteral(resourceName: "pendown")
        displayVariableTable.removeAllObjects()
        
        resetTurtle()
        resetLine()
    }
    
}
