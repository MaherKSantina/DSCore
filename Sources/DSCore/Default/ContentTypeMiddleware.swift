//
//  File.swift
//  
//
//  Created by Maher Santina on 4/4/20.
//

import Vapor

public final class ContentTypeMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let response = next.respond(to: request)
        return response.map{ response in response.headers.contentType = .json; return response }
    }


}
