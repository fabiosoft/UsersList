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

	init(results: [User]?) {
		self.results = results
	}
}

// MARK: - Result
public class User: Codable {
	let name: Name?
	let email: String?
	let id: ID?
	let picture: Picture?

	init(name: Name?, email: String?, id: ID?, picture: Picture?) {
		self.name = name
		self.email = email
		self.id = id
		self.picture = picture
	}
}

// MARK: - ID
public class ID: Codable {
	let name, value: String?

	init(name: String?, value: String?) {
		self.name = name
		self.value = value
	}
}

// MARK: - Name
public class Name: Codable {
	let title, first, last: String?

	init(title: String?, first: String?, last: String?) {
		self.title = title
		self.first = first
		self.last = last
	}
}

// MARK: - Picture
public class Picture: Codable {
	let large, medium, thumbnail: String?

	init(large: String?, medium: String?, thumbnail: String?) {
		self.large = large
		self.medium = medium
		self.thumbnail = thumbnail
	}
}

public typealias UsersCollection = [User]
