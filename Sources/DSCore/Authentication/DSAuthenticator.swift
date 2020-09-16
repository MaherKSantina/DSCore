//
//  File.swift
//  
//
//  Created by Maher Santina on 3/29/20.
//

import Vapor
import JWT

extension User2Row: Authenticatable { }

final class DSAuthenticator {

}

extension DSAuthenticator: JWTAuthenticator {
    func authenticate(jwt: UserPayload, for request: Request) -> EventLoopFuture<Void> {
        return User2Row.find(jwt.id, on: request.db).map { (userRow) -> (Void) in
            guard let userRow = userRow else { return }
            request.auth.login(userRow)
        }
    }

    typealias Payload = UserPayload
}
