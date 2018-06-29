//
//  ExportAnimationTurtleViewController.swift
//  SeaTurtle
//
//  Created by David Kopec on 6/29/18.
//  Copyright © 2018 David Kopec. All rights reserved.
//

import Cocoa
import SeaTurtleEngine

class ExportAnimationTurtleViewController: TurtleViewController {
    
    override var stepTime: TimeInterval {
        return 0.0 // don't want to delay animations at all
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("ExportAnimatedTurtleViewController viewDidLoad")
    }
    
    override func changePen(down: Bool, penChange: PenChange) {
        super.changePen(down: down, penChange: penChange)
        steps.removeLast() // don't want unnecessary delay in exported animation
    }
    
    override func changeColor(color: Int, colorChange: ColorChange) {
        super.changeColor(color: color, colorChange: colorChange)
        steps.removeLast() // don't want unnecessary delay in exported animation
    }
    
    override func variableChanged(name: String, value: Int, varSet: VarSet) {
        super.variableChanged(name: name, value: value, varSet: varSet)
        steps.removeLast() // don't want unnecessary delay in exported animation
    }
    
    override func log(str: String, printStatement: PrintStatement) {
        super.log(str: str, printStatement: printStatement)
        steps.removeLast() // don't want unnecessary delay in exported animation
    }
    
}
