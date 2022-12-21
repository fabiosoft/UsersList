//
//  UsersLoader.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

public final class UsersLoader: RemoteFeedLoader {
	public func map(_ usersCollection: UsersCollection) -> [UserViewModel] {
		usersCollection.map(UserViewModel.init)
	}

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	private let client: HTTPClient

	public init(_ client: HTTPClient) {
		self.client = client
	}

	public func loadUsers(page: UInt = 1, completion: @escaping Completion) {
		let userReq = LoadUsersRequest(page: page)
		client.request(userReq) { [weak self] result in
			guard self != nil else { return }
			switch result {
			case let .success((users, _)):
				completion(.success(users))
			case let .failure(error):
				completion(.failure(error))
			}
		}
	}
}
