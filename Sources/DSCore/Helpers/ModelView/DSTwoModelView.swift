//
//  DSTwoModelView.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Vapor
import FluentMySQL

public protocol DSTwoModelView: DSView {
    associatedtype Model1: DSDatabaseEntityRepresentable
    associatedtype Model2: DSDatabaseEntityRepresentable

    static var join: DSJoinRelationship { get }
    static var model1selectFields: [String] { get }
    static var model2selectFields: [String] { get }
}

extension DSTwoModelView {
    public static var modelNames: [String] {
        return [Model1.entity, Model2.entity]
    }
}

extension DSTwoModelView {
    public static var entity1Alias: String {
        return "entity1"
    }

    public static var entity2Alias: String {
        return "entity2"
    }
}

public struct ViewQueryData {
    public var entityAlias: String
    public var entityName: String
    public var fields: [String]
    public var joinKey: String
}

extension ViewQueryData {
    public var fieldsQueryString: String {
        return fields.map{ "\(entityAlias).\($0) as \(entityName)_\($0)" }.joined(separator: ",")
    }
}

extension DSTwoModelView {

    public static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {

        let joinString = "\(Model1.entity) entity1 \(join.type.rawValue) \(Model2.entity) entity2 on \(entity1Alias).\(join.key1) = \(entity2Alias).\(join.key2)"
        let data = [
            ViewQueryData(entityAlias: entity1Alias, entityName: Model1.entity, fields: model1selectFields, joinKey: join.key1),
            ViewQueryData(entityAlias: entity2Alias, entityName: Model2.entity, fields: model2selectFields, joinKey: join.key2)
        ]

        let fields = data.map{ $0.fieldsQueryString }.joined(separator: ",")

        let queryString = "Create or Replace View \(Self.tableName) as Select \(fields) from  \(joinString)"
        return conn.raw(queryString).run()
    }
}
