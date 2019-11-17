//
//  TwoModelJoin.swift
//  App
//
//  Created by Maher Santina on 7/21/19.
//

import Vapor
import FluentMySQL

protocol TwoModelJoin: TwoModelView {
    static var join: JoinRelationship { get }
    static var model1selectFields: [String] { get }
    static var model2selectFields: [String] { get }
}

extension TwoModelJoin {
    static var entity1Alias: String {
        return "entity1"
    }
    
    static var entity2Alias: String {
        return "entity2"
    }
    
}

struct ViewQueryData {
    var entityAlias: String
    var entityName: String
    var fields: [String]
    var joinKey: String
}

extension ViewQueryData {
    var fieldsQueryString: String {
        return fields.map{ "\(entityAlias).\($0) as \(entityName)_\($0)" }.joined(separator: ",")
    }
}

extension TwoModelJoin where Self: ModelView, Model1.Database == MySQLDatabase, Model2.Database == MySQLDatabase {
    
    typealias Database = MySQLDatabase
    
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        
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
