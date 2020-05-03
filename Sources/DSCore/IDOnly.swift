//
//  File.swift
//  
//
//  Created by Maher Santina on 3/5/20.
//

import Vapor

public final class IDOnlyData: Content {
    public var id: Int

    public init(id: Int) {
        self.id = id
    }
}

public protocol IDOnly {
    associatedtype IDValue: Codable, Hashable
    var id: IDValue { get set }
}

public protocol EntityRelated: IDOnly {

    associatedtype Entity: DSEntity

    func entity(req: Request) -> EventLoopFuture<Entity?>
}

public extension EntityRelated where Self.IDValue == Entity.IDValue {
    func entity(req: Request) -> EventLoopFuture<Entity?> {
        return Entity.find(id, on: req.db)
    }
}
