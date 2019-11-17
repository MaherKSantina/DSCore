//
//  DSQuery.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL

class DSQuery<T: Decodable> {
    var table: String
    var parameters: [QueryParameter]
    var onlyOne: Bool
    
    init(table: String, onlyOne: Bool, parameters: [QueryParameter] = []) {
        self.table = table
        self.onlyOne = onlyOne
        self.parameters = parameters
    }
    
    func withParameters(parameters newParameters: [QueryParameter]) -> DSQuery {
        parameters = parameters + newParameters
        return self
    }
    
    func withParameter(parameter: QueryParameter) -> DSQuery {
        parameters.append(parameter)
        return self
    }
    
    var whereClause: String {
        guard parameters.count > 0 else {
            return ""
        }
        
        let parametersClause = parameters.map{ $0.queryString }.joined(separator: " and ")
        
        return " where \(parametersClause)\(onlyOne ? " Limit 1" : "")"
    }
    
    var queryString: String {
        return "Select * from \(table) \(whereClause)"
    }
    
    var bindings: [Encodable] {
        return parameters.map{ $0.queryValue }.compactMap{ $0 }
    }
    
    func all(on conn: Container) -> Future<[T]> {
        return conn.withPooledConnection(to: .mysql, closure: { (connection) -> EventLoopFuture<[T]> in
            return self.all(on: connection)
        })
    }
    
    func all(on conn: MySQLConnection) -> Future<[T]> {
        return builder(on: conn).all(decoding: T.self)
    }
    
    func one(on conn: MySQLConnection) -> Future<T?> {
        return builder(on: conn).first(decoding: T.self)
    }
    
    func one(on conn: Container) -> Future<T?> {
        return conn.withPooledConnection(to: .mysql, closure: { (connection) -> EventLoopFuture<T?> in
            return self.one(on: connection)
        })
    }
}

extension DSQuery {
    func builder(on conn: MySQLConnection) -> SQLRawBuilder<MySQLConnection> {
        var query = conn.raw(queryString)
        query = query.binds(bindings)
        return query
    }
}
