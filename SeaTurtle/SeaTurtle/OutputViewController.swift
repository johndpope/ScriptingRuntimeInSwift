//
//  OutputViewController.swift
//  SeaTurtle
//
//  Created by David Kopec on 6/26/18.
//  Copyright © 2018 David Kopec. All rights reserved.
//

import Cocoa

class OutputViewController: NSViewController, NSTextStorageDelegate {
    @objc dynamic weak var docRep: DocRep?
    @IBOutlet weak var textView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        textView.textStorage?.delegate = self
    }
    
    // every time we output scroll to the bottom
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        print("textDidChange")
        self.textView.scrollRangeToVisible(NSRange(location: textView.string.count, length: 0))
    }
}
