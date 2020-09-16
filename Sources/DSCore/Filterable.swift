//
//  File.swift
//  
//
//  Created by Maher Santina on 9/16/20.
//

import Foundation
import Fluent
import Vapor

public struct EntityFilter {
    public var queryStringKey: String
    public var entityKey: String
    public var method: DatabaseQuery.Filter.Method

    public init(queryStringKey: String, entityKey: String, method: DatabaseQuery.Filter.Method) {
        self.queryStringKey = queryStringKey
        self.entityKey = entityKey
        self.method = method
    }

    public init(queryStringKey: String, method: DatabaseQuery.Filter.Method) {
        self.queryStringKey = queryStringKey
        self.entityKey = queryStringKey
        self.method = method
    }

    static func query(entityKey: String) -> Self {
        .init(queryStringKey: "query", entityKey: entityKey, method: .contains(inverse: false, .anywhere))
    }
}

public protocol Filterable {
    static var filters: [EntityFilter] { get }
}

extension GetController where Self: Filterable {
    public func getQueryBuilderTransform(req: Request, queryBuilder: QueryBuilder<GetEntity>) throws -> QueryBuilder<GetEntity> {
        var finalQueryBuilder = queryBuilder
        Self.filters.forEach { (filter) in
            if let value = try? req.query.get(String.self, at: filter.queryStringKey) {
                finalQueryBuilder = finalQueryBuilder.filter(FieldKey(stringLiteral: filter.entityKey), filter.method, value)
            }
        }
        return finalQueryBuilder
    }
}
