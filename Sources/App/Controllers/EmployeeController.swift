//
//  EmployeeController.swift
//  edcodePackageDescription
//
//  Created by Evgeniy Kalyada on 27/12/2017.
//

import Vapor
import HTTP
import Foundation

final class EmployeeController: ResourceRepresentable {


    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Employee.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/posts' with valid JSON
    /// construct and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        let employee = try req.employee()
        try employee.save()
        return employee
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(_ req: Request, employee: Employee) throws -> ResponseRepresentable {
        return employee
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, employee: Employee) throws -> ResponseRepresentable {
        try employee.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Employee.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, employee: Employee) throws -> ResponseRepresentable {
        // See `extension Post: Updateable`
        try employee.update(for: req)
        try employee.save()
        return employee
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Post with the same ID.
    func replace(_ req: Request, employee: Employee) throws -> ResponseRepresentable {
        // First attempt to create a new Post from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.employee()

        // Update the post with all of the properties from
        // the new post
//        employee.note = new.content
        try employee.save()

        // Return the updated post
        return employee
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Employee> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func employee() throws -> Employee {
        guard let json = json else { throw Abort.badRequest }
        return try Employee(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension EmployeeController: EmptyInitializable { }

extension EmployeeController {
	func getTimes(_ req: Request) throws -> ResponseRepresentable {
		guard let employeeId = req.parameters["id"]?.int else {
			throw Abort.badRequest
		}
		var items = try Time.all().filter({ (item) -> Bool in
			return item.employeeId.int == employeeId
		})
		if let month = req.parameters["month"]?.int {
			let calendar = Calendar.current
			let year = req.parameters["year"]?.int ?? calendar.component(.year, from: Date())
			items = items.filter({ (item) -> Bool in
				return calendar.component(.month, from: item.date) == month &&
				calendar.component(.year, from: item.date) == year
			})
		}
		return try items.makeJSON()
	}
}

