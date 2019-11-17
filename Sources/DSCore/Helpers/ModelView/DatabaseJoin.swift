//
//  Join.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

struct JoinRelationship {
    var type: JoinType
    var key1: String
    var key2: String
}

enum JoinType: String {
    case inner = " inner join "
    case left = " left join "
    case right = " right join "
    case outer = " outer join "
}
