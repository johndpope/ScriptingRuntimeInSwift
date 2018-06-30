//
//  ExportAnimatedViewController.swift
//  SeaTurtle
//
//  Created by David Kopec on 6/29/18.
//  Copyright © 2018 David Kopec. All rights reserved.
//

import Cocoa
import SeaTurtleEngine
import SpriteKit

class ExportAnimatedViewController: NSViewController {
    @IBOutlet weak var delayPopup: NSPopUpButton!
    @IBOutlet weak var exportProgressBar: NSProgressIndicator!
    
    var delay: Double {
        if let selectedTitle = delayPopup.selectedItem?.title, let d = Double(selectedTitle) {
            return d
        }
        return 0.1
    }
    
    @objc dynamic var loops: Int = 0
    
    weak var docRep: DocRep?
    
    var captures: [CGImage] = []
    var eatvc: ExportAnimationTurtleViewController?
    var weatvc: NSWindowController?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func createAnimatedGIF(_ url: URL, _ title: String) {
        guard let docRep = self.docRep else {
            print("No valid docRep for Animated GIF creation.")
            return
        }
        var parsed: StatementList = []
        do {
            let tokenized = try tokenize(text: docRep.text as String)
            //Swift.print(tokenized)
            let parser = Parser(tokens: tokenized)
            parsed = try parser.parse()
//            tvc?.clear()
//            tvc?.interpret(statements: parsed)
//            tvc?.step()
        } catch let le as LocalizedError {
            // show popup about error
            print(le.localizedDescription)
            return
        } catch {
            print("Other error")
            return
        }
        // try running it and capturing the images
        //eatvc = ExportAnimationTurtleViewController(nibName: nil, bundle: nil)
        //let skview = SKView(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
        //eatvc?.view = skview
        weatvc = storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WEATVC")) as? NSWindowController
        weatvc?.window?.title = "Exporting \(title)"
        weatvc?.window?.makeKeyAndOrderFront(self)
        eatvc = weatvc?.contentViewController! as? ExportAnimationTurtleViewController
        eatvc?.interpret(statements: parsed)
        captures.removeAll()
        print("starting step assemble")
        DispatchQueue.global().async {
            self.stepAssemble(url)
        }
        
    }
    
    func stepAssemble(_ url: URL) {
        eatvc?.stepWithCompletion {
            //print("stepped")
            guard let skview = self.eatvc?.view as? SKView else {
                print("Invalid skview")
                return
            }
            DispatchQueue.main.async {
                if let texture: SKTexture = skview.texture(from: (self.eatvc?.scene!)!) {
                    self.captures.append(texture.cgImage())
                    
                }
            }
            if self.eatvc?.inProgress ?? false {
                self.stepAssemble(url)
            } else {
                // done we have animated gif
                DispatchQueue.main.async {
                    let ag: AnimatedGIF = AnimatedGIF(images: self.captures, delay: self.delay, loop: self.loops)
                    ag.write(destinationURL: url)
                    print("wrote animated gif")
                    self.weatvc?.close()
                }
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewController(self) // close export sheet
    }
    
    @IBAction func export(sender: AnyObject) {
        let savePanel: NSSavePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["gif"]
        savePanel.allowsOtherFileTypes = false
        if let window = self.view.window {
            savePanel.beginSheetModal(for: window) { (response: NSApplication.ModalResponse) in
                if response == NSApplication.ModalResponse.OK { // user clicked okay
                    if let url = savePanel.url { // user selected an output file
                        self.createAnimatedGIF(url, savePanel.nameFieldStringValue)
                    } else {
                        print("invalid URL")
                    }
                }
            }
        }
        
    }
    
}
