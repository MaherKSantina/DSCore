//
//  File.swift
//  
//
//  Created by Maher Santina on 4/4/20.
//

import Vapor
import Fluent

public protocol EntityChangeController {
    func entityDidChange(req: Request)
}

public protocol GetController {
    associatedtype GetEntity: Model
    associatedtype GetEntityOut: Content

    func getQueryBuilderTransform(req: Request, queryBuilder: QueryBuilder<GetEntity>) throws -> QueryBuilder<GetEntity>
    func getTransformOut(result: [GetEntity]) -> [GetEntityOut]
    func get(req: Request) throws -> EventLoopFuture<[GetEntityOut]>
}

public extension GetController {

//    func getQueryBuilder(req: Request) throws -> QueryBuilder<GetEntity> {
//        switch try getAuthorizationMode(req: req) {
//        case .unauthorized:
//            throw Abort(.unauthorized)
//        case .userRelated(let id):
//            guard let path = GetEntity.selfKey else { throw Abort(.badRequest) }
//            var queryBuilder = GetEntity.query(on: req.db)
//            queryBuilder = queryBuilder.filter(FieldKey.string(path), .equal, id)
//            if let field = GetEntity.queryField, let query = try? req.query.get(String.self, at: field) {
//                queryBuilder = queryBuilder.filter(FieldKey(stringLiteral: field), .contains(inverse: false, .anywhere), query)
//            }
//            return queryBuilder
//        case .all:
//            var queryBuilder = GetEntity.query(on: req.db)
//            if let field = GetEntity.queryField, let query = try? req.query.get(String.self, at: field) {
//                queryBuilder = queryBuilder.filter(FieldKey(stringLiteral: field), .contains(inverse: false, .anywhere), query)
//            }
//            return queryBuilder
//        }
//    }
}

public extension GetController where GetEntity == GetEntityOut {
    func getTransformOut(result: [GetEntity]) -> [GetEntityOut] {
        return result
    }
}

public extension GetController {
    func get(req: Request) throws -> EventLoopFuture<[GetEntityOut]> {
        let gets = try getQueryBuilderTransform(req: req, queryBuilder: GetEntity.query(on: req.db))
        return gets.all().map{ self.getTransformOut(result: $0) }
    }
}

public protocol DeleteController: EntityChangeController {
    associatedtype DeleteEntity: DSEntityWrite
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus>
}

public extension DeleteController {
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try DeleteEntity.delete(req: req)
            .always{ _ in
                self.entityDidChange(req: req)
        }
    }
}

public protocol PostController: EntityChangeController {
    associatedtype PostEntityIn: Content
    associatedtype PostEntity: DSEntityWrite
    associatedtype PostEntityOut: Content
    func postTransformIn(content: PostEntityIn, req: Request) throws -> EventLoopFuture<PostEntity>
    func post(req: Request) throws -> EventLoopFuture<PostEntityOut>
    func postTransformOut(content: PostEntity, req: Request) -> EventLoopFuture<PostEntityOut>
}

public extension PostController where PostEntity == PostEntityIn {
    func postTransformIn(content: PostEntityIn, req: Request) throws -> EventLoopFuture<PostEntity> {
        return req.eventLoop.makeSucceededFuture(content)
    }
}

public extension PostController where PostEntity == PostEntityOut {
    func postTransformOut(content: PostEntity, req: Request) -> EventLoopFuture<PostEntityOut> {
        return req.eventLoop.makeSucceededFuture(content)
    }
}

public extension PostController {
    func post(req: Request) throws -> EventLoopFuture<PostEntityOut> {
        let content = try req.content.decode(PostEntityIn.self)
        let item = try postTransformIn(content: content, req: req)
        return item.map { (item) -> (PostEntity) in
            item._$id.exists = item.id != nil
            return item
        }
        .flatMap{ $0.save(on: req.db) }.always { (_) in
            self.entityDidChange(req: req)
        }
        .flatMap{ item }
        .flatMap{ self.postTransformOut(content: $0, req: req) }
    }
}
