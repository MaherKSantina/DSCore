//
//  Join.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

public struct DSJoinRelationship {
    public var type: DSJoinType
    public var key1: String
    public var key2: String

    public init(type: DSJoinType, key1: String, key2: String) {
        self.type = type
        self.key1 = key1
        self.key2 = key2
    }
}

public enum DSJoinType: String {
    case inner = " inner join "
    case left = " left join "
    case right = " right join "
    case outer = " outer join "
}