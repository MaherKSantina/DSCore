//
//  File.swift
//  
//
//  Created by Maher Santina on 5/2/20.
//

import Vapor
import Fluent
import FluentMySQLDriver

public protocol DSParent {
    associatedtype Child
    static var childKeyPath: WritableKeyPath<Self, [Child]> { get }
}

public protocol DSParent2 {
    associatedtype Child1
    associatedtype Child2
    static var childKeyPath1: WritableKeyPath<Self, [Child1]> { get }
    static var childKeyPath2: WritableKeyPath<Self, [Child2]> { get }
}

public extension Array where Element: DSIdentifiable, Element.IDValue: LosslessStringConvertible, Element: DSParent {
    var flatten: [Element] {
        var dict: [Element.IDValue: Element] = [:]
        self.forEach { (item) in
            guard let id = item.id else { assertionFailure(); return }
            let parentItem = dict[id]
            guard var exists = parentItem else {
                dict[id] = item
                return
            }
            exists[keyPath: Element.childKeyPath] = exists[keyPath: Element.childKeyPath] + item[keyPath: Element.childKeyPath]
            dict[id] = exists
        }
        return dict.map{ $0.value }
    }
}

public extension Array where Element: DSIdentifiable, Element.IDValue: LosslessStringConvertible, Element: DSParent2 {
    var flatten: [Element] {
        var dict: [Element.IDValue: Element] = [:]
        self.forEach { (item) in
            guard let id = item.id else { assertionFailure(); return }
            let parentItem = dict[id]
            guard var exists = parentItem else {
                dict[id] = item
                return
            }

            exists[keyPath: Element.childKeyPath1] = exists[keyPath: Element.childKeyPath1] + item[keyPath: Element.childKeyPath1]

            exists[keyPath: Element.childKeyPath2] = exists[keyPath: Element.childKeyPath2] + item[keyPath: Element.childKeyPath2]
            dict[id] = exists
        }
        return dict.map{ $0.value }
    }
}
