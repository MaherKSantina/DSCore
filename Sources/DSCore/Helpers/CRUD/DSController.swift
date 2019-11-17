//
//  DSController.swift
//  App
//
//  Created by Maher Santina on 7/15/19.
//

import Vapor
import Fluent

protocol DSController {
    associatedtype Model
    
    func getAll(_ req: Request) throws -> Future<[Model]>
    
    func get(_ req: Request) throws -> Future<Model>
    
    func create(_ req: Request) throws -> Future<Model>
    
    func delete(_ req: Request) throws -> Future<Model>
}

extension DSController where Model: DSModel, Model.ResolvedParameter == Future<Model> {
    
    static func routePath() throws -> String {
        return try Model.routePath()
    }
    
    func get(_ req: Request) throws -> Future<Model> {
        return try req.parameters.next(Model.self)
    }
    
    func create(_ req: Request) throws -> Future<Model> {
        return try req.content.decode(Model.self).save(on: req)
    }
    
    func delete(_ req: Request) throws -> Future<Model> {
        return try req.parameters.next(Model.self).delete(on: req)
    }
}
