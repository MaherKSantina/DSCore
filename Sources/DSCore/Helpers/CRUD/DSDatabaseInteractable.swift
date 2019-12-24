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
    static func all(req: DatabaseConnectable) -> Future<[Self]> {
        return Self.all(where: nil, req: req)
    }
    static func first(req: DatabaseConnectable) -> Future<Self?> {
        return Self.first(where: nil, req: req)
    }
}

extension DSDatabaseReadOnlyInteractable where Self: DSDatabaseEntityRepresentable, Self: Content {
    public static func all(where: String?, req: DatabaseConnectable) -> EventLoopFuture<[Self]> {
        return req.databaseConnection(to: .mysql).flatMap { (conn) -> EventLoopFuture<[Self]> in
            return conn.raw(Query(tableName: Self.entity, condition: `where`, limit: nil).string).all(decoding: Self.self)
        }
    }

    public static func first(where: String?, req: DatabaseConnectable) -> EventLoopFuture<Self?> {
        return req.databaseConnection(to: .mysql).flatMap { (conn) -> EventLoopFuture<Self?> in
            return conn.raw(Query(tableName: Self.entity, condition: `where`, limit: nil).string).all(decoding: Self.self).map{ $0.first }
        }
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
