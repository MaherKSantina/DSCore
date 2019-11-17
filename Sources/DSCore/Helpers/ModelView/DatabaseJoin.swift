//
//  Join.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

public struct JoinRelationship {
    public var type: JoinType
    public var key1: String
    public var key2: String
}

public enum JoinType: String {
    case inner = " inner join "
    case left = " left join "
    case right = " right join "
    case outer = " outer join "
}
