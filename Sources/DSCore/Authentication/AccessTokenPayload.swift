//
//  File.swift
//  
//
//  Created by Maher Santina on 4/6/20.
//

import JWT
import Foundation
import JWTKit
import Vapor

enum JWTConfig {
    static let signer = JWTSigner.hs256(key: Data("secret".utf8)) // Signer for JWT
    static let expirationTime: TimeInterval = 1000000 // In seconds
}

struct AccessTokenPayload: JWTPayload {

    var issuer: IssuerClaim
    var issuedAt: IssuedAtClaim
    var expirationAt: ExpirationClaim
    var id: UserRow.IDValue

    init(issuer: String = "TokensTutorial",
         issuedAt: Date = Date(),
         expirationAt: Date = Date().addingTimeInterval(JWTConfig.expirationTime),
         id: UserRow.IDValue) {
        self.issuer = IssuerClaim(value: issuer)
        self.issuedAt = IssuedAtClaim(value: issuedAt)
        self.expirationAt = ExpirationClaim(value: expirationAt)
        self.id = id
    }

    func verify(using signer: JWTSigner) throws {
        try self.expirationAt.verifyNotExpired()
    }
}

extension User {
    func accessTokenPayload() throws -> AccessTokenPayload {
        guard let id = id else { throw Abort(.notFound) }
        return AccessTokenPayload(id: id)
    }
}

extension AccessTokenPayload {
    func jwt() throws -> String {
        return try JWTConfig.signer.sign(self)
    }
}

extension User {
    func jwt() throws -> String {
        return try accessTokenPayload().jwt()
    }
}
