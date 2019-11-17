//
//  DSModel.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL
import Vapor

protocol DSModel: MySQLModel, CRUD, Content, Migration, Parameter, RouteNameable {  }

extension DSModel {
    static var defaultDatabase: DatabaseIdentifier<MySQLDatabase>? {
        return .mysql
    }
}
