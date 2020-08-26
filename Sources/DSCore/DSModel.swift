//
//  File.swift
//  
//
//  Created by Maher Santina on 5/2/20.
//

import Vapor
import Fluent
import FluentMySQLDriver

public protocol DSModelCodingKeys: CodingKey, CaseIterable, DSModelField { }

public protocol DSModelField: DSViewField {
    var dataType: DatabaseSchema.DataType { get }
    var constraints: [DatabaseSchema.FieldConstraint] { get }
}

public protocol DSModelFields {
    static var modelFields: [DSModelField] { get }
}

public protocol DSModel: DSEntityWrite, DSDatabaseFieldsRepresentable, DSModelFields {

}

public extension DSDatabaseFieldsRepresentable where Self: DSModelFields {
    static func setupFields(schemaBuilder: SchemaBuilder) -> SchemaBuilder {
        var newSchemaBuilder = schemaBuilder
        modelFields.forEach { (modelField) in
            newSchemaBuilder = newSchemaBuilder.field(.definition(name: .key(FieldKey.string(modelField.key)), dataType: modelField.dataType, constraints: modelField.constraints))
        }
        return newSchemaBuilder
    }
}
