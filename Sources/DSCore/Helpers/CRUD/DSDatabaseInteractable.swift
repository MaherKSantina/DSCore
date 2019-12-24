//
//  File.swift
//  
//
//  Created by Maher Santina on 12/24/19.
//

import Foundation
import Fluent
import FluentMySQL
import Vapor

public protocol DSDatabaseReadOnlyInteractable {
    static func all(where: String?, req: DatabaseConnectable) -> Future<[Self]>
    static func first(where: String?, req: DatabaseConnectable) -> Future<Self?>
}

public protocol DSDatabaseReadWriteInteractable: DSDatabaseReadOnlyInteractable {
    static func create(value: Self, req: DatabaseConnectable) -> Future<Self>
    static func update(value: Self, req: DatabaseConnectable) -> Future<Self>
    static func delete(value: Self, req: DatabaseConnectable) -> Future<Void>
}

extension DSDatabaseReadOnlyInteractable {
    static func all(where: String? = nil, req: DatabaseConnectable) -> Future<[Self]> {
        return Self.all(where: `where`, req: req)
    }
    static func first(where: String? = nil, req: DatabaseConnectable) -> Future<Self?> {
        return Self.first(where: `where`, req: req)
    }
}

extension DSDatabaseReadWriteInteractable where Self: MySQLModel {
    public static func delete(value: Self, req: DatabaseConnectable) -> EventLoopFuture<Void> {
        return value.delete(on: req)
    }

    public static func update(value: Self, req: DatabaseConnectable) -> EventLoopFuture<Self> {
        return value.save(on: req)
    }

    public static func create(value: Self, req: DatabaseConnectable) -> EventLoopFuture<Self> {
        return value.save(on: req)
    }

    public static func all(where: String?, req: DatabaseConnectable) -> EventLoopFuture<[Self]> {
        return req.databaseConnection(to: .mysql).flatMap { (conn) -> EventLoopFuture<[Self]> in
            return conn.simpleQuery(Query(tableName: Self.entity, condition: `where`, limit: nil).string).flatMap { (dict) -> (Future<[Self]>) in
                return dict.map{ Database.queryDecode($0, entity: Self.entity, as: Self.self, on: conn) }.flatten(on: conn)
            }
        }
    }

    public static func first(where: String?, req: DatabaseConnectable) -> EventLoopFuture<Self?> {
        return req.databaseConnection(to: .mysql).flatMap { (conn) -> EventLoopFuture<[Self]> in
            return conn.simpleQuery(Query(tableName: Self.entity, condition: `where`, limit: 1).string).flatMap { (dict) -> (Future<[Self]>) in
                return dict.map{ Database.queryDecode($0, entity: Self.entity, as: Self.self, on: conn) }.flatten(on: conn)
            }
        }.map{ $0.first }
    }
}

public struct Query {
    public var tableName: String
    public var condition: String?
    public var limit: Int?

    public var string: String {
        var s = "Select * from \(tableName) "
        if let condition = condition {
            s += " where \(condition)"
        }
        if let limit = limit {
            s += " limit \(limit) "
        }
        return s
    }
}
