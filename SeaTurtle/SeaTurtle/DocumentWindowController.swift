//
//  DocumentWindowController.swift
//  SeaTurtle
//
//  Created by David Kopec on 6/26/18.
//  Copyright © 2018 David Kopec. All rights reserved.
//

import Cocoa

class DocumentWindowController: NSWindowController, NSWindowDelegate {
    weak var variablesWindowController: NSWindowController?
    weak var outputWindowController: NSWindowController?

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    // MARK: Segue Stuff
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        guard let document = self.document as? Document else { return }
        if segue.identifier!.rawValue == "Variables Segue" {
            guard let variablesWindowController = segue.destinationController as? NSWindowController else {
                print("Destination is not Window Controller")
                return
                
            }
            
            //variablesWindowController.document = document
            //variablesWindowController.synchronizeWindowTitleWithDocumentName()
            if let variablesWindow = variablesWindowController.window, let variablesViewController = variablesWindowController.contentViewController as? VariablesViewController  {
                // for kvo, we don't copy the reference to the dictionary, but rather
                // to the whole view controller
                self.variablesWindowController = variablesWindowController
                variablesViewController.tvc = document.tvc
                // variablesWindow.makeKeyAndOrderFront(self)
                variablesWindow.bind(NSBindingName.title, to: self.window as Any, withKeyPath: "title", options: nil)
                //print("I'm prepared")
                
            }
        } else if segue.identifier!.rawValue == "Output Segue" {
            guard let outputWindowController = segue.destinationController as? NSWindowController else {
                print("Destination is not Window Controller")
                return
                
            }
            
            //variablesWindowController.document = document
            //variablesWindowController.synchronizeWindowTitleWithDocumentName()
            if let outputWindow = outputWindowController.window, let outputViewController = outputWindowController.contentViewController as? OutputViewController  {
                // for kvo, we don't copy the reference to the dictionary, but rather
                // to the whole view controller
                self.outputWindowController = outputWindowController
                outputViewController.docRep = document.docRep
                // variablesWindow.makeKeyAndOrderFront(self)
                outputWindow.bind(NSBindingName.title, to: self.window as Any, withKeyPath: "title", options: nil)
                //print("I'm prepared")
                
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: NSStoryboardSegue.Identifier, sender: Any?) -> Bool {
        if identifier.rawValue == "Variables Segue" {
            if self.variablesWindowController?.isWindowLoaded ?? false {
                return false
            }
        } else if identifier.rawValue == "Output Segue" {
            if self.outputWindowController?.isWindowLoaded ?? false {
                return false
            }
        }
        return true
    }
    
    // MARK: NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        self.variablesWindowController?.close()
        self.outputWindowController?.close()
    }

}
