//
//  ThreeModelJoin.swift
//  App
//
//  Created by Maher Santina on 7/23/19.
//

import Vapor
import FluentMySQL

public protocol ThreeModelJoin: ThreeModelView {
    static var join12: JoinRelationship { get }
    static var join23: JoinRelationship { get }
    static var model1selectFields: [String] { get }
    static var model2selectFields: [String] { get }
    static var model3selectFields: [String] { get }
}

extension ThreeModelJoin where Self: ModelView, Model1.Database == MySQLDatabase, Model2.Database == MySQLDatabase, Model3.Database == MySQLDatabase {
    
    typealias Database = MySQLDatabase
    
    public static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        let entity1Alias = "entity1"
        let entity2Alias = "entity2"
        let entity3Alias = "entity3"
        
        let joinString = " \(join12.type.rawValue) \(Model2.entity) entity2 on \(entity1Alias).\(join12.key1) = \(entity2Alias).\(join12.key2) \(join23.type.rawValue) \(Model3.entity) entity3 on \(entity2Alias).\(join23.key1) = \(entity3Alias).\(join23.key2) "
        
        let fields1 =  model1selectFields.map{ "\(entity1Alias).\($0) as \(Model1.entity)_\($0)" }.joined(separator: ",")
        let fields2 = model2selectFields.map{ "\(entity2Alias).\($0) as \(Model2.entity)_\($0)" }.joined(separator: ",")
        let fields3 = model3selectFields.map{ "\(entity3Alias).\($0) as \(Model3.entity)_\($0)" }.joined(separator: ",")
        let fields = [fields1, fields2, fields3].joined(separator: ",")
        let queryString = "Create or Replace View \(Self.tableName) as Select \(fields) from \(Model1.entity) entity1 \(joinString)"
        return conn.raw(queryString).run()
    }
}

