//
//  LoadUsersRequest.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation

public struct LoadUsersRequest: DataRequest {
	public typealias Response = UsersCollection

	public var url: URL? {
		URL(string: "https://randomuser.me/api")
	}

	public let page: UInt
	public let perPage: UInt
	public let seed: String
	init(page: UInt, perPage: UInt = 20, seed: String = "usersList") {
		self.page = page
		self.perPage = perPage
		self.seed = seed
	}

	public var headers: [String: String] { [:] }
	public var queryItems: [String: String] {
		[
			"page": String(page),
			"results": String(perPage),
			"seed": seed,
		]
	}

	public var urlRequest: URLRequest? {
		guard let url = url else {
			return nil
		}
		guard var urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			return nil
		}
		var queryItems: [URLQueryItem] = []
		self.queryItems.forEach {
			let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
			urlComponent.queryItems?.append(urlQueryItem)
			queryItems.append(urlQueryItem)
		}
		urlComponent.queryItems = queryItems

		guard let url = urlComponent.url else {
			return nil
		}

		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = method.rawValue
		return urlRequest
	}

	public var method: HTTPMethod { .get }

	public func decode(_ data: Data) throws -> UsersCollection {
		do {
			let usersPage = try JSONDecoder().decode(Users.self, from: data)
			return usersPage.results ?? []
		} catch {
			return []
		}
	}
}
