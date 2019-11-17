//
//  DSQueryParameter.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

struct DSQueryParameter {
    enum Operation {
        case lessThan
        case lessThanOrEqual
        case greaterThan
        case greaterThanOrEqual
        case equal
        
        var string: String {
            switch self {
            case .lessThan:
                return " < "
            case .lessThanOrEqual:
                return " <= "
            case .equal:
                return " = "
            case .greaterThan:
                return " > "
            case .greaterThanOrEqual:
                return " >= "
            }
        }
    }
    
    var key: String
    var operation: Operation
    var value: Encodable
}

extension DSQueryParameter: QueryParameter {
    var queryString: String {
        return "\(key)\(operation.string)?"
    }
    
    var queryValue: Encodable? {
        return value
    }
}

struct WMSNullQueryParameter {
    var key: String
}

protocol QueryParameter {
    var queryString: String { get }
    var queryValue: Encodable? { get }
}

extension QueryParameter {
    static func from(key: String, operation: DSQueryParameter.Operation, value: Encodable?) -> QueryParameter {
        if let v = value {
            return DSQueryParameter(key: key, operation: operation, value: v)
        }
        else {
            return WMSNullQueryParameter(key: key)
        }
    }
}
extension WMSNullQueryParameter: QueryParameter {
    var queryString: String {
        return "\(key) is null"
    }
    
    var queryValue: Encodable? {
        return nil
    }
}
