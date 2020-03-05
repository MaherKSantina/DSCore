//
//  File.swift
//  
//
//  Created by Maher Santina on 3/5/20.
//

import Vapor

public final class IDOnly: Content {
    public var id: Int

    public init(id: Int) {
        self.id = id
    }
}
