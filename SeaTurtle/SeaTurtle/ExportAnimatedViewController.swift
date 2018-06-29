//
//  ExportAnimatedViewController.swift
//  SeaTurtle
//
//  Created by David Kopec on 6/29/18.
//  Copyright © 2018 David Kopec. All rights reserved.
//

import Cocoa

class ExportAnimatedViewController: NSViewController {
    @IBOutlet weak var delayPopup: NSPopUpButton!
    @IBOutlet weak var exportProgressBar: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewController(self) // close export sheet
    }
    
    @IBAction func export(sender: AnyObject) {
        let savePanel: NSSavePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["gif"]
        savePanel.allowsOtherFileTypes = false
        if let window = self.view.window {
            //savePanel.runModal()
            savePanel.beginSheetModal(for: window) { (response: NSApplication.ModalResponse) in
                if response == NSApplication.ModalResponse.OK {
                    self.dismissViewController(self) // close export sheet
                }
            }
        }
        
    }
    
}
