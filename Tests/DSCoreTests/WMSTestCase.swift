//
//  WMSTestCase.swift
//  AppTests
//
//  Created by Maher Santina on 11/23/19.
//

@testable import DSCore
import XCTest
import Vapor
import MySQL

class WMSTestCase: XCTestCase, ApplicationDatabaseAware {

    var app: Application!
    var conn: MySQLConnection!

    override func setUp() {
        super.setUp()
        setupMockApplicationAndConnection()
    }

    override func tearDown() {
        tearDownMockApplicationAndConnection()
        super.tearDown()
    }

}

extension WMSTestCase: MockApplicationInitializable {  }

protocol ApplicationDatabaseAware: AnyObject {
    var app: Application! { set get }
    var conn: MySQLConnection! { set get }
}

protocol MockApplicationInitializable {
    func setupMockApplicationAndConnection()
    func tearDownMockApplicationAndConnection()
}

extension MockApplicationInitializable where Self: XCTestCase, Self: ApplicationDatabaseAware {
    func setupMockApplicationAndConnection() {
        resetDatabase()
        do {
            app = try Application.mock()
            conn = try app.newConnection(to: .mysql).wait()
        }
        catch {
            XCTFail(error.localizedDescription)
        }
    }

    func tearDownMockApplicationAndConnection() {
        conn.close()
    }
}


protocol DatabaseResetting {
    func resetDatabase()
}

extension DatabaseResetting where Self: XCTestCase {
    func resetDatabase() {
        guard let revertApp = try? Application.mock(environmentArgs: .revert) else {
            XCTFail("Problem with Revert App")
            return
        }
        try? revertApp.asyncRun().wait()
        guard let migrateApp = try? Application.mock(environmentArgs: .migrate) else {
            XCTFail("Problem with Migrate App")
            return
        }
        try? migrateApp.asyncRun().wait()
    }
}

extension XCTestCase: DatabaseResetting {  }


extension Application {
    static func mock(environmentArgs: EnvironmentArguments? = nil) throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        if let args = environmentArgs {
            env.arguments = args.argArray
        }
        try configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        return app
    }
}

enum EnvironmentArguments {
    case migrate
    case revert

    var argArray: [String] {
        switch self {
        case .migrate:
            return ["vapor", "migrate", "-y"]
        case .revert:
            return ["vapor", "revert", "--all", "-y"]
        }
    }
}
