//
//  File.swift
//  
//
//  Created by Maher Santina on 12/31/19.
//

import Fluent
import Vapor

public protocol DSEntityPost {

}

public protocol DSEntityPut {

}

public protocol DSEntityDelete {

}

public protocol DSPublicable {
    associatedtype Public: Content

    var `public`: Public { get }
}

public protocol DSEntityControllable: DSModel, DSPublicable {
    static var primaryKeyString: String { get }
    init(id: Int)
}

extension DSEntityControllable {
    public static var primaryKeyString: String {
        return "id"
    }
}

public protocol DSEntityQueryable {
    static func whereString(queryString: String) -> String
}

extension DSEntityControllable {
    public static func getAll(on: DatabaseConnectable) -> EventLoopFuture<[Public]> {
        return all(where: nil, req: on).map{ $0.map{ $0.public } }
    }

    public static func get(id: Int, on: DatabaseConnectable) throws -> EventLoopFuture<Public> {
        return first(where: "\(primaryKeyString) = \(id)", req: on).unwrap(or: Abort(.notFound)).map{ $0.public }
    }

    public static func delete(id: Int, on: DatabaseConnectable) throws -> EventLoopFuture<Void> {
        return delete(value: Self.init(id: id), req: on)
    }
}

extension DSEntityControllable where Self: DSEntityQueryable {
    public static func getAll(queryString: String, on: DatabaseConnectable) -> EventLoopFuture<[Public]> {
        return all(where: whereString(queryString: queryString), req: on).map{ $0.map{ $0.public } }
    }
}

public protocol DSEntityRelated {
    associatedtype EntityType: DSEntityControllable
    var entity: EntityType { get }
}

extension DSEntityRelated {
    public static func getAll(on: DatabaseConnectable) -> EventLoopFuture<[EntityType.Public]> {
        return EntityType.getAll(on: on)
    }
    
    public static func get(id: Int, on: DatabaseConnectable) throws -> EventLoopFuture<EntityType.Public> {
        return try EntityType.get(id: id, on: on)
    }
}

extension DSEntityRelated where EntityType: DSEntityQueryable {
    public static func getAll(queryString: String, on: DatabaseConnectable) -> EventLoopFuture<[EntityType.Public]> {
        return EntityType.getAll(queryString: queryString, on: on)
    }
}

extension DSEntityRelated where Self: DSEntityPost {
    public func create(on: DatabaseConnectable) throws -> EventLoopFuture<EntityType.Public> {
        return EntityType.create(value: self.entity, req: on).map{ $0.public }
    }
}

extension DSEntityRelated where Self: DSEntityPut {
    public func update(on: DatabaseConnectable) throws -> EventLoopFuture<EntityType.Public> {
        return EntityType.update(value: self.entity, req: on).map{ $0.public }
    }
}

extension DSEntityRelated where Self: DSEntityDelete {
    public func delete(on: DatabaseConnectable) throws -> EventLoopFuture<Void> {
        return EntityType.delete(value: self.entity, req: on)
    }
}
