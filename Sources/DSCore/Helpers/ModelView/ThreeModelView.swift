//
//  ThreeModelView.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

public protocol ThreeModelView {
    associatedtype Model1: DSDatabaseEntity
    associatedtype Model2: DSDatabaseEntity
    associatedtype Model3: DSDatabaseEntity
}

extension MySQLView where Self: ThreeModelView {
    public static var modelNames: [String] {
        return [Model1.entity, Model2.entity, Model3.entity]
    }
}
