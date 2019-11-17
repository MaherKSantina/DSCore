//
//  DSModel.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import FluentMySQL
import Vapor

public protocol DSModel: MySQLModel, CRUD, Content, Migration, Parameter, RouteNameable {  }

extension DSModel {
    public static var defaultDatabase: DatabaseIdentifier<MySQLDatabase>? {
        return .mysql
    }
}
