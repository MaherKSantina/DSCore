//
//  File.swift
//  
//
//  Created by Maher Santina on 11/23/19.
//

import Vapor

extension Container {
    public func respondToRequest(request: HTTPRequest) throws -> Future<Response> {
        let responder = try make(Responder.self)
        let wrappedRequest = Request(http: request, using: self)
        return try responder.respond(to: wrappedRequest)
    }
}

extension Response {
    public func decode<T>(_ entity: T.Type) throws -> T where T: Decodable {
        let data = http.body.data ?? Data()
        let responseEntity = try JSONDecoder().decode(T.self, from: data)
        return responseEntity
    }
}
