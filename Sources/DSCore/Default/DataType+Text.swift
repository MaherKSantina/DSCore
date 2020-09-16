//
//  File 2.swift
//  
//
//  Created by Maher Santina on 9/6/20.
//

import Fluent

extension DatabaseSchema.DataType {
    static var text: DatabaseSchema.DataType {
        return .custom("Text")
    }
}
