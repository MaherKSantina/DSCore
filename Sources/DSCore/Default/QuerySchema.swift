import Foundation
import Vapor

class QuerySchema {

    struct Join {
        var type: String
        var schema: QuerySchema
        var key: String
        var foreignSchema: QuerySchema
        var foreignKey: String
    }

    var schema: String
    var alias: String
    var fieldsPrefix: String
    var fields: [String]
    var joins: [Join]

    init(schema: String, alias: String, fieldsPrefix: String, fields: [String], joins: [Join] = []) {
        self.schema = schema
        self.alias = alias
        self.fieldsPrefix = fieldsPrefix
        self.fields = fields
        self.joins = joins
    }

    @discardableResult
    func join(type: String, foreignSchema: QuerySchema, key: String, foreignKey: String) -> QuerySchema {
        joins.append(.init(type: type, schema: self, key: key, foreignSchema: foreignSchema, foreignKey: foreignKey))
        return self
    }
}
