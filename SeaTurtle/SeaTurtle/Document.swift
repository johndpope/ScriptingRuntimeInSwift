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
import SpriteKit
import SeaTurtleEngine

class Document: NSDocument {
    @objc var docRep: DocRep = DocRep()
    @objc weak var playBarItem: NSToolbarItem!
    weak var tvc: TurtleViewController?
    weak var scvc: SourceCodeViewController?
    
    var playPauseToolbarItem: NSToolbarItem? {
        guard let toolbarItems = self.windowControllers[0].window?.toolbar?.items else { return nil }
        if let index = toolbarItems.index(where: { (toolBarItem) -> Bool in
            return toolBarItem.label == "Play" || toolBarItem.label == "Pause"
        }) {
            return toolbarItems[index]
        }
        return nil
    }

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
        let windowController: DocumentWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")) as! DocumentWindowController
        windowController.contentViewController!.representedObject = docRep
        scvc = ((windowController.contentViewController! as! NSSplitViewController).splitViewItems[0].viewController as! SourceCodeViewController)
        tvc = ((windowController.contentViewController! as! NSSplitViewController).splitViewItems[1].viewController as! TurtleViewController)
        tvc?.stepDelegate = scvc
        
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
        //let j = String(data: data, encoding: String.Encoding.utf8)!
        //Swift.print(j)
        docRep.text = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
    }
    
    override func printDocument(_ sender: Any?) {
        guard let window = self.windowControllers[0].window else { return }
        let alert: NSAlert = NSAlert()
        alert.messageText = "What do you want to print?"
        alert.informativeText = "The code or the picture?"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Source Code")
        alert.addButton(withTitle: "Turtle Graphics")
        alert.beginSheetModal(for: window) { (response) in
            if response == NSApplication.ModalResponse.alertFirstButtonReturn { // cancel
                return
            } else if response == NSApplication.ModalResponse.alertSecondButtonReturn { // code
                guard let attrstr = self.scvc?.textView.attributedString() else { return }
                let printInfo: NSPrintInfo = self.printInfo
                let bounds: NSRect = printInfo.imageablePageBounds
                let textView: NSTextView = NSTextView(frame: bounds)
                textView.textStorage?.append(attrstr)
                //textView.printView(self)
                self.scvc?.textView.printView(self)
                return
            } else { // picture
                guard let skview = self.tvc?.view as? SKView else {
                    Swift.print("Invalid skview")
                    return
                }
                guard let texture: SKTexture = skview.texture(from: (self.tvc?.scene!)!) else {
                    Swift.print("Invalid texture")
                    return
                }
                let image = texture.cgImage()
                let printInfo: NSPrintInfo = self.printInfo
                printInfo.isVerticallyCentered = true
                let bounds: NSRect = printInfo.imageablePageBounds
                let nsimage: NSImage = NSImage(cgImage: image, size: NSSize(width: bounds.width, height: bounds.height))
                let imageView: NSImageView = NSImageView(image: nsimage)
                imageView.frame = bounds
                let printOperation: NSPrintOperation = NSPrintOperation(view: imageView, printInfo: printInfo)
                printOperation.run()
                //return
            }
        }
    }
    
    @IBAction func runSeaTurtleScript(sender: NSToolbarItem) {
        guard sender.label == "Play" else { // hit pause
            tvc?.pause()
            sender.image = NSImage(named: NSImage.Name(rawValue: "NSPlayTemplate"))
            sender.label = "Play"
            return
        }
        scvc?.clearErrors() // clear any existing displayed errors, we're re-parsing
        // hit play
        sender.image = NSImage(named: NSImage.Name(rawValue: "NSPauseTemplate"))
        sender.label = "Pause"

        do {
            if !(tvc?.inProgress ?? false) { // if in progress, continue instead of starting over
                let tokenized = try tokenize(text: docRep.text as String)
                //Swift.print(tokenized)
                let parser = Parser(tokens: tokenized)
                let parsed = try parser.parse()
                tvc?.clear()
                tvc?.interpret(statements: parsed)
            }
            tvc?.play()
        } catch let le as LocalizedError {
            Swift.print(le.localizedDescription)
            scvc?.showError(error: le)
        } catch {
            Swift.print("Other error")
        }
    }
    
    @IBAction func stepScript(sender: NSToolbarItem) {
        if tvc?.steps.count ?? 0 == 0 {
            do {
                if !(tvc?.inProgress ?? false) { // if in progress, continue instead of starting over
                    let tokenized = try tokenize(text: docRep.text as String)
                    Swift.print(tokenized)
                    let parser = Parser(tokens: tokenized)
                    let parsed = try parser.parse()
                    tvc?.clear()
                    tvc?.interpret(statements: parsed)
                }
                tvc?.step()
            } catch let le as LocalizedError {
                Swift.print(le.localizedDescription)
                scvc?.showError(error: le)
            } catch {
                Swift.print("Other error")
            }
        } else {
            tvc?.step()
        }
    }
    
    @IBAction func clearScript(sender: NSToolbarItem) {
        tvc?.clear()
        playPauseToolbarItem?.image = NSImage(named: NSImage.Name(rawValue: "NSPlayTemplate"))
        playPauseToolbarItem?.label = "Play"
    }
    
    @IBAction func showVariablesWindow(sender: NSToolbarItem) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let variablesWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Variables Window Controller")) as! NSWindowController
        
        if let variablesWindow = variablesWindowController.window, let variablesViewController = variablesWindowController.contentViewController as? VariablesViewController  {
            // for kvo, we don't copy the reference to the dictionary, but rather
            // to the whole view controller
            variablesViewController.tvc = tvc
            variablesWindow.makeKeyAndOrderFront(self)
        }
    }

}

