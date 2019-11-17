//
//  DSQueryParameter.swift
//  App
//
//  Created by Maher Santina on 8/3/19.
//

import Foundation

public struct DSQueryParameter {
    public enum Operation {
        case lessThan
        case lessThanOrEqual
        case greaterThan
        case greaterThanOrEqual
        case equal
        
        public var string: String {
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
    
    public var key: String
    public var operation: Operation
    public var value: Encodable
}

extension DSQueryParameter: QueryParameter {
    public var queryString: String {
        return "\(key)\(operation.string)?"
    }
    
    public var queryValue: Encodable? {
        return value
    }
}

public struct WMSNullQueryParameter {
    public var key: String
}

public protocol QueryParameter {
    var queryString: String { get }
    var queryValue: Encodable? { get }
}

extension QueryParameter {
    public static func from(key: String, operation: DSQueryParameter.Operation, value: Encodable?) -> QueryParameter {
        if let v = value {
            return DSQueryParameter(key: key, operation: operation, value: v)
        }
        else {
            return WMSNullQueryParameter(key: key)
        }
    }
}
extension WMSNullQueryParameter: QueryParameter {
    public var queryString: String {
        return "\(key) is null"
    }
    
    public var queryValue: Encodable? {
        return nil
    }
}
