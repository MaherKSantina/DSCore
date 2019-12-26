//
//  File.swift
//  
//
//  Created by Maher Santina on 12/24/19.
//

@testable import DSCore
import FluentMySQL
import Vapor

struct ModelA: DSModel {
    static var entity: String = "ModelA"

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case attributea1
        case attributea2
    }

    var id: Int?
    var attributea1: String
    var attributea2: String
}

struct ModelB: DSModel {
    static var entity: String = "ModelB"

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case attributeb1
        case attributeb2
        case attributeba2
    }

    var id: Int?
    var attributeb1: String
    var attributeb2: String
    var attributeba2: String
}

struct ModelC: DSModel {
    static var entity: String = "ModelC"

    enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case attributec1
        case attributec2
        case attributeca2
    }

    var id: Int?
    var attributec1: String
    var attributec2: String
    var attributeca2: String
}

struct InnerJoinModelAB: DSTwoModelView {
    static var entity: String {
        return Self.tableName
    }

    static var tableName: String = "InnerJoin"

    static var join: DSJoinRelationship = DSJoinRelationship(type: .inner, key1: "attributea2", key2: "attributeba2")

    static var model1selectFields: [String] {
        return ["id", "attributea1", "attributea2"]
    }

    static var model2selectFields: [String] {
        return ["id", "attributeb1", "attributeb2", "attributeba2"]
    }

    typealias Model1 = ModelA

    typealias Model2 = ModelB

    var ModelA_id: Int
    var ModelA_attributea1: String
    var ModelA_attributea2: String
    var ModelB_id: Int
    var ModelB_attributeb1: String
    var ModelB_attributeb2: String
    var ModelB_attributeba2: String
}

struct LeftJoinModelAB: DSTwoModelView {
    static var entity: String {
        return Self.tableName
    }

    static var tableName: String = "LeftJoin"

    static var join: DSJoinRelationship = DSJoinRelationship(type: .left, key1: "attributea2", key2: "attributeba2")

    static var model1selectFields: [String] {
        return ["id", "attributea1", "attributea2"]
    }

    static var model2selectFields: [String] {
        return ["id", "attributeb1", "attributeb2", "attributeba2"]
    }

    typealias Model1 = ModelA

    typealias Model2 = ModelB

    var ModelA_id: Int
    var ModelA_attributea1: String
    var ModelA_attributea2: String
    var ModelB_id: Int?
    var ModelB_attributeb1: String?
    var ModelB_attributeb2: String?
    var ModelB_attributeba2: String?
}

struct RightJoinModelAB: DSTwoModelView {
    static var entity: String {
        return Self.tableName
    }

    static var tableName: String = "RightJoin"

    static var join: DSJoinRelationship = DSJoinRelationship(type: .right, key1: "attributea2", key2: "attributeba2")

    static var model1selectFields: [String] {
        return ["id", "attributea1", "attributea2"]
    }

    static var model2selectFields: [String] {
        return ["id", "attributeb1", "attributeb2", "attributeba2"]
    }

    typealias Model1 = ModelA

    typealias Model2 = ModelB

    var ModelA_id: Int?
    var ModelA_attributea1: String?
    var ModelA_attributea2: String?
    var ModelB_id: Int
    var ModelB_attributeb1: String
    var ModelB_attributeb2: String
    var ModelB_attributeba2: String
}

struct NModelView3 {
    var ModelA_id: Int
    var ModelA_attributea1: String
    var ModelA_attributea2: String
    var ModelB_id: Int
    var ModelB_attributeb1: String
    var ModelB_attributeb2: String
    var ModelB_attributeba2: String
    var ModelC_id: Int
    var ModelC_attributec1: String
    var ModelC_attributec2: String
    var ModelC_attributeca2: String
}

extension NModelView3: DSNModelView {
    static var tables: [DSViewTable] {
        return [
            DSViewTable(name: ModelA.entity, fields: ModelA.CodingKeys.allCases.map{ $0.rawValue }),
            DSViewTable(name: ModelB.entity, fields: ModelB.CodingKeys.allCases.map{ $0.rawValue }),
            DSViewTable(name: ModelC.entity, fields: ModelC.CodingKeys.allCases.map{ $0.rawValue }),
        ]
    }

    static var mainTableName: String {
        return ModelA.entity
    }

    static var joins: [DSViewJoin] {
        return [
            DSViewJoin(type: .inner, foreignTable: ModelB.entity, foreignKey: ModelB.CodingKeys.attributeba2.rawValue, mainTable: ModelA.entity, mainTableKey: ModelA.CodingKeys.attributea2.rawValue),
            DSViewJoin(type: .inner, foreignTable: ModelC.entity, foreignKey: ModelC.CodingKeys.attributeca2.rawValue, mainTable: ModelA.entity, mainTableKey: ModelA.CodingKeys.attributea2.rawValue)
        ]
    }
}
