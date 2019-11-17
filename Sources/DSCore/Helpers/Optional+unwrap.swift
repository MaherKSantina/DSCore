//
//  Optional+unwrap.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

extension Optional {
    func unwrap(or error: Error) throws -> Wrapped {
        guard let wrapped = wrapped else {
            throw error
        }
        return wrapped
    }
}
