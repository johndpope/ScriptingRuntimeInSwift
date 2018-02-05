//
//  Document.swift
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
import SeaTurtleEngine

class Document: NSDocument {
    @objc var docRep: DocRep = DocRep()
    weak var tvc: TurtleViewController?
    weak var scvc: SourceCodeViewController?

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")) as! NSWindowController
        windowController.contentViewController!.representedObject = docRep
        scvc = ((windowController.contentViewController! as! NSSplitViewController).splitViewItems[0].viewController as! SourceCodeViewController)
        tvc = ((windowController.contentViewController! as! NSSplitViewController).splitViewItems[1].viewController as! TurtleViewController)
        
        self.addWindowController(windowController)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        //Swift.print(self.text)
        //Swift.print(self.windowControllers[0].contentViewController?.representedObject)
        return (docRep.text.data(using: String.Encoding.utf8.rawValue))!
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        let j = String(data: data, encoding: String.Encoding.utf8)!
        Swift.print(j)
        docRep.text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
    }
    
    @IBAction func runSeaTurtleScript(sender: NSToolbarItem) {
        guard sender.label == "Play" else { // hit pause
            tvc?.pause()
            sender.image = #imageLiteral(resourceName: "play")
            sender.label = "Play"
            return
        }
        scvc?.clearErrors() // clear any existing displayed errors, we're re-parsing
        // hit play
        sender.image = #imageLiteral(resourceName: "pause")
        sender.label = "Pause"
        
        if docRep.running { // already running
            tvc?.play()
            return
        }
        
        // first run
        Swift.print("runScript()")
        docRep.running = true
        do {
            let tokenized = try tokenize(text: docRep.text as String)
            Swift.print(tokenized)
            let parser = Parser(tokens: tokenized)
            let parsed = try parser.parse()
            tvc?.clear()
            tvc?.interpret(statements: parsed)
            tvc?.play()
        } catch let te as TokenizerError {
            Swift.print(te.localizedDescription)
            scvc?.showError(error: te)
        } catch {
            Swift.print("Other error")
        }
    }

}

