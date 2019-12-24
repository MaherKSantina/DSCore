//
//  File.swift
//  
//
//  Created by Maher Santina on 12/24/19.
//

@testable import DSCore
import FluentMySQL
import Vapor

struct InnerJoinViewAB: MySQLTwoModelView {
    static var entity: String {
        return Self.tableName
    }

    static var tableName: String = "Test1"
    static var join: JoinRelationship {
        return JoinRelationship(type: .inner, key1: "attributea2", key2: "attributeba2")
    }

    static var model1selectFields: [String] {
        return ["id", "attributea1", "attributea2"]
    }

    static var model2selectFields: [String] {
        return ["id", "attributeb1", "attributeb2", "attributeba2"]
    }

    typealias Model1 = ModelA

    typealias Model2 = ModelB
}

struct ModelAB: Content {

    var ModelA_id: Int
    var ModelA_attributea1: String
    var ModelA_attributea2: String
    var ModelB_id: Int
    var ModelB_attributeb1: String
    var ModelB_attributeb2: String
    var ModelB_attributeba2: String
}

extension ModelAB: DSView {
    static var entity: String {
        return InnerJoinViewAB.entity
    }

    static var modelNames: [String] {
        return InnerJoinViewAB.modelNames
    }

    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return InnerJoinViewAB.prepare(on: conn)
    }
}
