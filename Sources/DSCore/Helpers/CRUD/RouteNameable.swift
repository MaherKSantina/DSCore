//
//  RouteNameable.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Vapor

public protocol RouteNameable {
    static func routePath() throws -> String
}
