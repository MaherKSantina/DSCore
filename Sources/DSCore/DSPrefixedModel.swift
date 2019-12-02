//
//  File.swift
//  
//
//  Created by Maher Santina on 12/2/19.
//

import Foundation

public protocol DSPrefixedModel: DSModel {
    static var baseName: String { get }
    static var namePrefix: String { get }
}

public extension DSPrefixedModel {
    static var entity: String {
        return "\(Self.namePrefix)_\(Self.baseName)"
    }
}
