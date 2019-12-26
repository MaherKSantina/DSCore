import Vapor
import DSCore
import FluentMySQL
import Fluent

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first

    try services.register(FluentProvider())
    try services.register(MySQLProvider())

    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

    var databases = DatabasesConfig()

    let mysql = MySQLDatabase(config: MySQLDatabaseConfig(
        hostname: "localhost",
        port: 3306,
        username: "root",
        password: "root",
        database: "dscore-test"
        )
    )
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    var migrations = MigrationConfig()
    migrations.add(model: ModelA.self, database: .mysql)
    migrations.add(model: ModelB.self, database: .mysql)
    migrations.add(model: ModelC.self, database: .mysql)
    migrations.add(migration: InnerJoinModelAB.self, database: .mysql)
    migrations.add(migration: LeftJoinModelAB.self, database: .mysql)
    migrations.add(migration: RightJoinModelAB.self, database: .mysql)
    migrations.add(migration: NModelView3.self, database: .mysql)
    services.register(migrations)
}
