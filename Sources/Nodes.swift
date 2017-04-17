//
//  Nodes.swift
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

import Foundation

public protocol Statement {
    
}

public typealias StatementList = [Statement]

public struct Sub: Statement {
    public let name: String
    public let statementList: StatementList
}

public struct SubCall: Statement {
    public let name: String
}

public struct Loop: Statement {
    public let times: Int
    public let statementList: StatementList
}

public struct Turn: Statement {
    let angle: Int
}

public struct Movement: Statement {
    let distance: Int
}
