//
//  Employee.swift
//  edcodePackageDescription
//
//  Created by Evgeniy Kalyada on 27/12/2017.
//

import Vapor
import FluentProvider
import HTTP

final class Employee : Model {
    
    var name: String?
    var skype: String?
    var position: String?
    var phone: String?
    var note: String?
    
    let storage = Storage()
    
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let skype = "skype"
        static let position = "position"
        static let phone = "phone"
        static let note = "note"
    }

    
    /// Creates a new
    init(name: String?, skype: String?, position: String?, phone: String?, note: String?) {
        self.name = name ?? ""
        self.skype = skype ?? ""
        self.position = position ?? ""
        self.phone = phone ?? ""
        self.note = note ?? ""
    }
    
    // MARK: Fluent Serialization
    /// Initializes the Employee from the
    /// database row
    init(row: Row) throws {
        name = try row.get(Employee.Keys.name) ?? ""
        skype = try row.get(Employee.Keys.skype) ?? ""
        position = try row.get(Employee.Keys.position) ?? ""
        phone = try row.get(Employee.Keys.phone) ?? ""
        note = try row.get(Employee.Keys.note) ?? ""
    }
    
    // Serializes the Employee to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Employee.Keys.name, name)
        try row.set(Employee.Keys.skype, skype)
        try row.set(Employee.Keys.position, position)
        try row.set(Employee.Keys.phone, phone)
        try row.set(Employee.Keys.note, note)
        return row
    }
}

extension Employee {
    
    var times: Children<Employee, Time>? {
        return children()
    }
}

extension Employee: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Employee.Keys.name, length: nil, optional: true, unique: false, default: nil)
            builder.string(Employee.Keys.skype, length: nil, optional: true, unique: false, default: nil)
            builder.string(Employee.Keys.phone, length: nil, optional: true, unique: false, default: nil)
            builder.string(Employee.Keys.position, length: nil, optional: true, unique: false, default: nil)
            builder.string(Employee.Keys.note, length: nil, optional: true, unique: false, default: nil)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Employee: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Employee.Keys.name) ?? "",
            skype: try json.get(Employee.Keys.skype) ?? "",
            position: try json.get(Employee.Keys.position) ?? "",
            phone: try json.get(Employee.Keys.phone) ?? "",
            note: try json.get(Employee.Keys.note) ?? ""
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Employee.Keys.id, id)
        try json.set(Employee.Keys.name, name)
        try json.set(Employee.Keys.skype, skype)
        try json.set(Employee.Keys.position, position)
        try json.set(Employee.Keys.phone, phone)
        try json.set(Employee.Keys.note, note)
        return json
    }
}

extension Employee: ResponseRepresentable { }

extension Employee: Updateable {

    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Employee>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Employee.Keys.name, String?.self) { item, name in
                item.name = name
            },
            UpdateableKey(Employee.Keys.skype, String?.self) { item, skype in
                item.skype = skype
            },
            UpdateableKey(Employee.Keys.position, String?.self) { item, position in
                item.position = position
            },
            UpdateableKey(Employee.Keys.phone, String?.self) { item, phone in
                item.phone = phone
            },
            UpdateableKey(Employee.Keys.note, String?.self) { item, note in
                item.note = note
            }
        ]
    }
}

