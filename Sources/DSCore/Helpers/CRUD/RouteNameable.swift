//
//  RouteNameable.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Vapor

protocol RouteNameable {
    static func routePath() throws -> String
}
