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

extension Int
{
    var deg2Rad : CGFloat
    {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
}

class TurtleViewController: NSViewController, TurtlePlayer {
    var scene: SKScene?
    var turtle: SKSpriteNode = SKSpriteNode(imageNamed: "turtle")
    var stepTime: TimeInterval {
        return (parent?.representedObject as! DocRep).timeInterval.doubleValue
    }
    var steps: [SKAction] = [SKAction]()
    var curAngle: CGFloat = 90.deg2Rad
    var lookupTable: [String: StatementList] = [String: StatementList]()
    
    let path = CGMutablePath()
    let line = SKShapeNode()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        /*let skview = SKView(frame: view.bounds)
        view.addSubview(skview)*/
        
        scene = SKScene(size: view.frame.size)
        scene?.scaleMode = .aspectFill
        scene?.backgroundColor = NSColor.blue
        (view as! SKView).presentScene(scene)
        scene?.addChild(turtle)
        scene?.addChild(line)
        // setup initial turtle position
        turtle.position = CGPoint(x: (scene?.size.width)!/2, y: (scene?.size.height)!/2)
        turtle.zRotation = curAngle
        // setup line 
        line.path = path
        line.lineWidth = 1.0
        line.strokeColor = .green
        line.glowWidth = 0.1
        path.move(to: turtle.position)
        // little test
        /*addTurn(angle: 45)
        addMove(distance: 100)
        addTurn(angle: -90)
        addMove(distance: 50)
        play()*/
    }
    
    func addTurn(angle: Int) {
        curAngle += angle.deg2Rad
        let action = SKAction.rotate(toAngle: curAngle, duration: stepTime)
        steps.append(action)
    }
    
    func addMove(distance: Int) {
        let dx = CGFloat(distance) * cos(curAngle)
        let dy = CGFloat(distance) * sin(curAngle)
        let action1 = SKAction.moveBy(x: dx, y: dy, duration: stepTime)
        let action2 = SKAction.customAction(withDuration: 0.0) { (node, float) in
            self.path.addLine(to: self.turtle.position)
            self.line.path = self.path
        }
        let combined = SKAction.sequence([action1, action2])
        steps.append(combined)
    }
    
    func play() {
        let action = SKAction.sequence(steps)
        turtle.run(action)
        /*for action in steps {
            turtle.run(action) {
                self.path.addLine(to: self.turtle.position)
            }
        }*/
    }
    
    func clear() {
        lookupTable.removeAll()
        steps.removeAll()
    }
    
}
