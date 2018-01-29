//
//  LineNumberRulerView.swift
//
//  SeaTurtle - A turtle graphics scripting language and runtime.
//  Copyright (C) 2018 David Kopec
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

class LineNumberRulerView: NSRulerView {
    weak var textView: NSTextView!
    let LN_WIDTH: CGFloat = 40.0
    
    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)
        self.textView = textView
        self.ruleThickness = LN_WIDTH
        NotificationCenter.default.addObserver(self, selector: #selector(didScroll(notification:)), name: NSScrollView.didLiveScrollNotification, object: textView.enclosingScrollView)
        NotificationCenter.default.addObserver(self, selector: #selector(didChange(notification:)), name: NSText.didChangeNotification, object: textView)
        self.needsDisplay = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let layoutManager = textView.layoutManager, let textContainer = textView.textContainer else { return }
        // get the line number of the character in the top left corner
        let characterIndex = layoutManager.characterIndex(for: NSPoint(x: 0, y: 0), in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let firstLineNumber = textView.lineNumber(at:  characterIndex)
        
        // all viewable glyphs
        let glyphRange = layoutManager.glyphRange(forBoundingRect: layoutManager.usedRect(for: textContainer), in: textContainer)
        //
        var lineNumber = firstLineNumber
        let width = self.frame.width
        let LN_CURTOSY_SPACE: CGFloat = 4.0
        // actual drawing of each line number by each line number fragment
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { [unowned self](rect, usedRect, textContainer, glyphRange, stop) in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.right
            let fontAttributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: self.textView.font!, NSAttributedStringKey.paragraphStyle: paragraphStyle]
            let toDraw = NSAttributedString(string: "\(lineNumber)", attributes: fontAttributes)
            let topLeft = self.convert(NSPoint(x: rect.minX, y: rect.minY), from: self.textView)
            toDraw.draw(in: NSRect(x: 0, y: topLeft.y, width: width - LN_CURTOSY_SPACE, height: usedRect.height))
            lineNumber += 1
        }
    }
    
    @objc func didScroll(notification: Notification) {
        needsDisplay = true // redraw
    }
    
    @objc func didChange(notification: Notification) {
        needsDisplay = true // redraw
    }
}
