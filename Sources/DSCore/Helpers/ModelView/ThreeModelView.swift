//
//  ThreeModelView.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

protocol ThreeModelView {
    associatedtype Model1: DSModel
    associatedtype Model2: DSModel
    associatedtype Model3: DSModel
}

extension ModelView where Self: ThreeModelView {
    static var modelNames: [String] {
        return [Model1.entity, Model2.entity, Model3.entity]
    }
}
