//
//  StringDoubleValueTransformer.swift
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

@objc(StringDoubleValueTransformer)
class StringDoubleValueTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSNumber.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        Swift.print("called transformedValue")
        Swift.print(type(of: value))
        if let val = value as? NSString {
            Swift.print("trying to transform nsstring")
            return NSNumber(value: val.doubleValue)
        }
        if let _ = value as? String {
            Swift.print("trying to transform string")
            return 0.2
        }
        if let val = value as? NSNumber {
            Swift.print("trying to transform nsnumber")
            return val
        }
        return NSNumber(value: value as! Double)
    }
    
}
