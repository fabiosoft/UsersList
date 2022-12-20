//
//  UserViewModel.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

public enum UsersFeedSection {
	case main
}

public struct UserViewModel {
	private let user: User
	public init(user: User) {
		self.user = user
	}

	public var name: String? {
		if let name = self.user.name?.first?.capitalized, let surname = self.user.name?.last {
			return "\(name) \(surname)"
		}
		return self.user.name?.first
	}

	var email: String? {
		user.email
	}

	var imageURL: URL? {
		guard let png = self.user.picture?.medium else {
			return nil
		}
		return URL(string: png)
	}
}

extension UserViewModel: Hashable {
	public static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
		lhs.user.name?.first == rhs.user.name?.first
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(user.name?.first)
	}
}
