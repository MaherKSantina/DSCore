import Fluent
import Vapor

public final class UserRow: DSModel {
    
    public static var schema: String = "user"


    public static var modelFields: [DSModelField] {
        return CodingKeys.allCases
    }

    public enum CodingKeys: String, DSModelCodingKeys {
        case id
        case name
        case email
        case password
        case roleID

        public var dataType: DatabaseSchema.DataType {
            switch self {
            case .id, .roleID:
                return .int
            case .name, .email, .password:
                return .string
            }
        }

        public var constraints: [DatabaseSchema.FieldConstraint] {
            switch self {
            case .id:
                return [.identifier(auto: true)]
            case .name, .email, .password, .roleID:
                return [.required]
            }
        }
    }

    @ID(custom: .id)
    public var id: Int?

    @Field(key: CodingKeys.name.fieldKey)
    public var name: String

    @Field(key: CodingKeys.email.fieldKey)
    public var email: String

    @Field(key: CodingKeys.password.fieldKey)
    public var password: String

    @Field(key: CodingKeys.roleID.fieldKey)
    public var roleID: RoleRow.IDValue

    public init() { }

    public init(id: Int? = nil, name: String, email: String, password: String, roleID: RoleRow.IDValue) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.roleID = roleID
    }
}

extension UserRow {
    public struct Post: Content {
        public var id: UserRow.IDValue
        public var name: String

        public init(id: UserRow.IDValue, name: String) {
            self.id = id
            self.name = name
        }

        public func row(req: Request) throws -> EventLoopFuture<UserRow> {
            return UserRow.find(id, on: req.db).unwrap(or: Abort(.notFound)).map{ row in
                row._$id.exists = true
                row.name = self.name
                return row
            }
        }
    }
}

extension UserRow {
    public static func withEmail(email: String, req: Request) -> EventLoopFuture<UserRow?> {
        return UserRow.query(on: req.db)
            .filter(.string(CodingKeys.email.rawValue), .equality(inverse: false), email)
            .first()
    }
}

extension UserRow {
    public func user2Row(req: Request) -> EventLoopFuture<User2Row?> {
        return User2Row.find(id, on: req.db)
    }
}
