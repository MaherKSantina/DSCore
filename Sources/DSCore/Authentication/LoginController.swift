//
//  File.swift
//  
//
//  Created by Maher Santina on 4/6/20.
//

import Vapor

struct AccessDto: Content {
    var token: String
}

struct Login: Content {
    var email: String
    var password: String

    func user(req: Request) throws -> EventLoopFuture<UserRow> {
        return UserRow.withEmail(email: email, req: req).unwrap(or: Abort(.unauthorized)).flatMap{
            user in
            do {
                let digest = user.password
                let isValid = try req.password.verify(self.password, created: digest)
                guard isValid else { throw Abort(.unauthorized) }
                return req.eventLoop.makeSucceededFuture(user)
            }
            catch {
                return req.eventLoop.makeFailedFuture(Abort(.unauthorized))
            }
        }
    }
}

final class LoginController {

    func post(req: Request) throws -> EventLoopFuture<AccessDto> {
        let login = try req.content.decode(Login.self)
        return try login.user(req: req)
            .flatMap{ $0.user2Row(req: req) }
            .map{ $0?.user }
            .flatMapThrowing{ try $0?.jwt() }
            .unwrap(or: Abort(.unauthorized))
            .map{ AccessDto(token: $0) }
    }

    func setupRoutes(app: Application) {
        let pc = PathComponent.constant("login")
        app.post(pc, use: post)
    }
}
