import Vapor
import DSCore
import FluentMySQL
import Fluent

struct ModelA: MySQLModel, Migration, DSDatabaseEntityRepresentable {
    static var entity: String = "ModelA"

    var id: Int?
    var attributea1: String
    var attributea2: String
}

struct ModelB: MySQLModel, Migration, DSDatabaseEntityRepresentable {
    static var entity: String = "ModelB"

    var id: Int?
    var attributeb1: String
    var attributeb2: String
    var attributeba2: String
}

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
    migrations.add(migration: InnerJoinModelAB.self, database: .mysql)
    migrations.add(migration: LeftJoinModelAB.self, database: .mysql)
    migrations.add(migration: RightJoinModelAB.self, database: .mysql)
    services.register(migrations)
}
