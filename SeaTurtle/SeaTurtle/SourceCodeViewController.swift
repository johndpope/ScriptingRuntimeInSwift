//
//  SourceCodeViewController.swift
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

class SourceCodeViewController: NSViewController {
    
    @IBOutlet weak var textView: NSTextView!
    var lineNumberRulerView: LineNumberRulerView?
    var errorsByLineNumber: [Int: LocalizedError] = [Int: LocalizedError]()
    let errorRed = NSColor(calibratedRed: 0.8, green: 0.0, blue: 0.0, alpha: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Setup Line Numbers
        lineNumberRulerView = LineNumberRulerView(textView: textView)
        textView.enclosingScrollView?.verticalRulerView = lineNumberRulerView
        textView.enclosingScrollView?.hasVerticalRuler = true
        textView.enclosingScrollView?.rulersVisible = true
    }
    
    deinit {
        lineNumberRulerView = nil
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func showError(error: LocalizedError) {
        if case let TokenizerError.UnexpectedSymbol(lineNumber, _, range) = error {
            errorsByLineNumber[lineNumber] = error
            // highlight error
            highlight(range: range, color: errorRed)
        } else if case let ParserError.ParseError(_, token) = error {
            guard let textStorage = textView.textStorage else { return }
            let nRange = NSRange(token.range, in: textStorage.string)
            // get line number for range
            let lineNumber = textView.lineNumber(at: nRange.location)
            errorsByLineNumber[lineNumber] = error
            highlight(range: token.range, color: errorRed)
        }
        lineNumberRulerView?.errorsByLineNumber = errorsByLineNumber
        textView.needsDisplay = true
        lineNumberRulerView?.needsDisplay = true
    }
    
    // highlight a Swift Range<String.Index>
    func highlight(range: Range<String.Index>, color: NSColor) {
        guard let textStorage = textView.textStorage else { return }
        let nRange = NSRange(range, in: textStorage.string)
        textStorage.addAttribute(NSAttributedStringKey.backgroundColor, value: color, range: nRange)
    }

    // remove all highlights
    func clearHighlights() {
        if let textStorage = textView.textStorage {
            let allRange = NSRange(location: 0, length: textStorage.length)
            textStorage.removeAttribute(NSAttributedStringKey.backgroundColor, range: allRange)
        }
        textView.needsDisplay = true
    }
    
    func clearErrors() {
        errorsByLineNumber.removeAll()
        lineNumberRulerView?.errorsByLineNumber.removeAll()
        lineNumberRulerView?.errorToolTips.removeAll()
        clearHighlights()
        textView.needsDisplay = true
        lineNumberRulerView?.needsDisplay = true
    }
    
}

