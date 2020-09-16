//
//  File.swift
//  
//
//  Created by Maher Santina on 5/25/20.
//

import Vapor
import Fluent
import FluentMySQLDriver

public struct AuthenticationModule {
    public static func initApp(app: Application) {
        app.migrations.add(UserRow.tableMigration)
        app.migrations.add(RoleRow.tableMigration)
        app.migrations.add(User2Row.viewMigration)

        let loginController = LoginController()
        loginController.setupRoutes(app: app)
    }
}
