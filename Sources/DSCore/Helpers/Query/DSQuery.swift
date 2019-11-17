//
//  DSQuery.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL

public class DSQuery<T: Decodable> {
    public var table: String
    public var parameters: [QueryParameter]
    public var onlyOne: Bool
    
    public init(table: String, onlyOne: Bool, parameters: [QueryParameter] = []) {
        self.table = table
        self.onlyOne = onlyOne
        self.parameters = parameters
    }
    
    public func withParameters(parameters newParameters: [QueryParameter]) -> DSQuery {
        parameters = parameters + newParameters
        return self
    }
    
    public func withParameter(parameter: QueryParameter) -> DSQuery {
        parameters.append(parameter)
        return self
    }
    
    public var whereClause: String {
        guard parameters.count > 0 else {
            return ""
        }
        
        let parametersClause = parameters.map{ $0.queryString }.joined(separator: " and ")
        
        return " where \(parametersClause)\(onlyOne ? " Limit 1" : "")"
    }
    
    public var queryString: String {
        return "Select * from \(table) \(whereClause)"
    }
    
    public var bindings: [Encodable] {
        return parameters.map{ $0.queryValue }.compactMap{ $0 }
    }
    
    public func all(on conn: Container) -> Future<[T]> {
        return conn.withPooledConnection(to: .mysql, closure: { (connection) -> EventLoopFuture<[T]> in
            return self.all(on: connection)
        })
    }
    
    public func all(on conn: MySQLConnection) -> Future<[T]> {
        return builder(on: conn).all(decoding: T.self)
    }
    
    public func one(on conn: MySQLConnection) -> Future<T?> {
        return builder(on: conn).first(decoding: T.self)
    }
    
    public func one(on conn: Container) -> Future<T?> {
        return conn.withPooledConnection(to: .mysql, closure: { (connection) -> EventLoopFuture<T?> in
            return self.one(on: connection)
        })
    }
}

extension DSQuery {
    public func builder(on conn: MySQLConnection) -> SQLRawBuilder<MySQLConnection> {
        var query = conn.raw(queryString)
        query = query.binds(bindings)
        return query
    }
}
