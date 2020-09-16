//
//  File.swift
//  
//
//  Created by Maher Santina on 4/4/20.
//

import JWT

struct UserPayload {
    var id: Int
}

extension UserPayload: JWTPayload {
    func verify(using signer: JWTSigner) throws {

    }
}
