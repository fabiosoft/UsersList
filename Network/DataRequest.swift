//
//  DataRequest.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}

public protocol DataRequest: Hashable { //To use your own custom type in a set or as the key type of a dictionary, add `Hashable` conformance
	associatedtype Response

	var url: URL? { get }
	var method: HTTPMethod { get }
	var headers: [String: String] { get }
	var queryItems: [String: String] { get }
	var urlRequest: URLRequest? { get }
	func decode(_ data: Data) throws -> Response
}

extension DataRequest where Response: Decodable {
	func decode(_ data: Data) throws -> Response {
		let decoder = JSONDecoder()
		return try decoder.decode(Response.self, from: data)
	}
}

extension DataRequest {
	var headers: [String: String] {
		[:]
	}

	var queryItems: [String: String] {
		[:]
	}

	var urlRequest: URLRequest? {
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
		urlRequest.allHTTPHeaderFields = headers
		return urlRequest
	}
}
