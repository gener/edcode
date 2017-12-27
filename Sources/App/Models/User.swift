//
//  User.swift
//  edcodePackageDescription
//
//  Created by Eugene Kalyada on 27.12.2017.
//

import FluentProvider

final class User : Model {

	var name : String
	let storage = Storage()

	init(row: Row) throws {
		self.name = try row.get("name")
	}

	init(name: String) {
		self.name = name
	}

	func makeRow() throws -> Row {
		var row = Row()
		try row.set("name", name)
		return row
	}
}

extension User: Preparation {
	static func prepare(_ database: Database) throws {
		try database.create(self) { pets in
			pets.id()
			pets.string("name")
		}
	}

	static func revert(_ database: Database) throws {
		try database.delete(self)
	}
}
