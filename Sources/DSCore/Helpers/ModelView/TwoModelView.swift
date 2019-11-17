//
//  TwoModelView.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

protocol TwoModelView {
    associatedtype Model1: DSModel
    associatedtype Model2: DSModel
}

extension ModelView where Self: TwoModelView {
    static var modelNames: [String] {
        return [Model1.entity, Model2.entity]
    }
}
