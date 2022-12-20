//
//  User.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

// MARK: - Users
public class Users: Codable {
	let results: [User]?

	public init(results: [User]?) {
		self.results = results
	}
}

// MARK: - Result
public class User: Codable {
	public let name: Name?
	let email: String?
	let id: ID?
	let picture: Picture?

	public init(name: Name?, email: String?, id: ID?, picture: Picture?) {
		self.name = name
		self.email = email
		self.id = id
		self.picture = picture
	}
}

// MARK: - ID
public class ID: Codable {
	let name, value: String?

	public init(name: String?, value: String?) {
		self.name = name
		self.value = value
	}
}

// MARK: - Name
public class Name: Codable {
	public let title, first, last: String?

	public init(title: String?, first: String?, last: String?) {
		self.title = title
		self.first = first
		self.last = last
	}
}

// MARK: - Picture
public class Picture: Codable {
	let large, medium, thumbnail: String?

	public init(large: String?, medium: String?, thumbnail: String?) {
		self.large = large
		self.medium = medium
		self.thumbnail = thumbnail
	}
}

public typealias UsersCollection = [User]
