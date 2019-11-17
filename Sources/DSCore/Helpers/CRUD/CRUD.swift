//
//  CRUD.swift
//  App
//
//  Created by Maher Santina on 7/15/19.
//

import Vapor
import FluentMySQL

protocol CRUD: CRUDGetAll, CRUDCreate, CRUDDelete { }


protocol CRUDGetAll {
    static func crudGetAll(on conn: DatabaseConnectable) -> Future<[Self]>
}

protocol CRUDCreate {
    func crudCreate(on conn: DatabaseConnectable) -> Future<Self>
}

protocol CRUDDelete {
    func crudDelete(on conn: DatabaseConnectable) -> Future<Self>
}

extension CRUDGetAll where Self: Model {
    static func crudGetAll(on conn: DatabaseConnectable) -> Future<[Self]> {
        return Self.query(on: conn).all()
    }
}

extension CRUDCreate where Self: Model {
    
    func crudCreate(on conn: DatabaseConnectable) -> Future<Self> {
        return self.save(on: conn)
    }
    
}

extension CRUDDelete where Self: Model {
    func crudDelete(on conn: DatabaseConnectable) -> Future<Self> {
        return self.delete(on: conn).transform(to: self)
    }
}

extension Array where Element: Model {
    func save(on conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return self.map{ $0.save(on: conn) }.flatten(on: conn).transform(to: .ok)
    }
}

//var query = FluentMySQLQuery.query(.select, .init(stringLiteral: Self.viewName))
//let identifier = MySQLColumnIdentifier.column("User_LoginView", "Login_userID")
//let expression = MySQLExpression.column(identifier)
//let op = MySQLBinaryOperator.equal
//let literal = MySQLLiteral(integerLiteral: 1)
//let rhs = MySQLExpression.literal(literal)
//query.predicate = MySQLExpression.binary(expression, op, rhs)


//extension MySQLExpression {
//    static func column(_ column: String, fromTable table: String, op: MySQLBinaryOperator, value: String) -> MySQLExpression {
//        let identifier = MySQLTableIdentifier.init(stringLiteral: table)
//        let columnIdentifier = MySQLColumnIdentifier.column(identifier, MySQLIdentifier(column))
//        let expression = MySQLExpression.column(columnIdentifier)
//        let literal = MySQLLiteral(stringLiteral: value)
//        let rhs = MySQLExpression.literal(literal)
//        return MySQLExpression.binary(expression, op, rhs)
//    }
//}
