//
//  TextViewLineNumberExtension.swift
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

import Foundation
import Cocoa

extension NSTextView {
    /// Find a line number for a character at a particular index
    func lineNumber(at index: Int) -> Int {
        guard let textStorage = self.textStorage else { return 0 }
        let upTo = textStorage.string.prefix(index)
        return upTo.components(separatedBy: "\n").count
    }
    
    /// check if the glyph range contains a backslash n in textStorage
    func glyphRangeContainsNewline(_ glyphRange: NSRange) -> Bool {
        guard let textStorage = self.textStorage, let layoutManager = self.layoutManager else { return false }
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        if let sRange = Range(characterRange, in: textStorage.string) {
            let characters = textStorage.string[sRange]
            if characters.contains("\n") {
                return true
            }
        }
        return false
    }
}
