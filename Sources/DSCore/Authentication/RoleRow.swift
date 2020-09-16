//
//  File.swift
//
//
//  Created by Maher Santina on 3/5/20.
//

import Vapor
import Fluent

public final class RoleRow: DSModel {

    public static var schema: String = "role"

    public static var modelFields: [DSModelField] {
        return CodingKeys.allCases
    }

    public enum CodingKeys: String, DSModelCodingKeys {
        case id
        case name

        public var dataType: DatabaseSchema.DataType {
            switch self {
            case .id:
                return .int
            case .name:
                return .string
            }
        }

        public var constraints: [DatabaseSchema.FieldConstraint] {
            switch self {
            case .id:
                return [.identifier(auto: true)]
            case .name:
                return [.required]
            }
        }
    }

    @ID(custom: .id)
    public var id: Int?

    @Field(key: CodingKeys.name.fieldKey)
    public var name: String

    public init() { }

    public init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension RoleRow {
    public var type: RoleType {
        return RoleType(rawValue: id!)!
    }
}
