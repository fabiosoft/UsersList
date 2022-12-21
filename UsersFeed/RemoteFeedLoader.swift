//
//  RemoteFeedLoader.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation

public protocol RemoteFeedLoader {
	typealias Result = Swift.Result<UsersCollection, NetworkError>
	typealias Completion = (Result) -> Void

	func loadUsers(page: UInt, completion: @escaping Completion)
	func map(_ usersCollection: UsersCollection) -> [UserViewModel]
}

public extension RemoteFeedLoader {
	func map(_ collection: UsersCollection) -> [UserViewModel] {
		collection.map(UserViewModel.init)
	}
}
