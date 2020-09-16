//
//  File.swift
//
//
//  Created by Maher Santina on 3/13/20.
//

import Vapor
import Fluent


public final class User2Row: DSJoinsRepresentableView {
    public static var viewFields: [DSViewField] {
        return CodingKeys.allCases
    }

    enum CodingKeys: String, DSViewCodingKeys {
        case id
        case user_id
        case user_name
        case user_email
        case user_password
        case user_roleID
        case role_id
        case role_name
    }


    public static var mainEntity: ViewInformation {
        return UserRow.viewInformation
    }

    public static var entities: [ViewInformation] {
        return [RoleRow.viewInformation]
    }

    public static var joins: [Join] {
        return [
            Join(joinType: .left, baseEntity: mainEntity.schema, baseEntityKey: UserRow.CodingKeys.roleID.rawValue, foreignEntity: RoleRow.schema, foreignEntityKey: RoleRow.CodingKeys.id.rawValue)
        ]
    }

    public static var queryField: String? {
        return CodingKeys.user_name.rawValue
    }

    public static var schema: String = "User2"

    @ID(custom: .id)
    public var id: Int?

    @Field(key: CodingKeys.user_id.fieldKey)
    public var user_id: UserRow.IDValue

    @Field(key: CodingKeys.user_name.fieldKey)
    public var user_name: String

    @Field(key: CodingKeys.user_email.fieldKey)
    public var user_email: String

    @Field(key: CodingKeys.user_password.fieldKey)
    public var user_password: String

    @Field(key: CodingKeys.user_roleID.fieldKey)
    public var user_roleID: RoleRow.IDValue

    @Field(key: CodingKeys.role_id.fieldKey)
    public var role_id: RoleRow.IDValue

    @Field(key: CodingKeys.role_name.fieldKey)
    public var role_name: String

    public var user: User {
        return User(id: user_id, name: user_name, email: user_email, role: RoleRow(id: role_id, name: role_name))
    }

    public init() { }
}

public enum RoleType: Int, CaseIterable, Content {
    case admin = 1
    case nurse

    public var displayName: String {
        switch self {
        case .admin:
            return "Admin"
        case .nurse:
            return "Nurse"
        }
    }
}

public struct User: Content {
    public var id: Int?
    public var name: String
    public var email: String
    public var role: RoleRow
}
