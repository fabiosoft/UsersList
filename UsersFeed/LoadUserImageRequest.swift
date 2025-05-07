//
//  LoadUserImageRequest.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation
public struct LoadUserImageRequest: DataRequest {
	public typealias Response = Data

	public var url: URL?
	public var headers: [String: String] { [:] }
	public var queryItems: [String: String] { [:] }

	public var urlRequest: URLRequest? {
		guard let url = url else {
			return nil
		}
		return URLRequest(url: url)
	}

	public var method: HTTPMethod { .get }

	public func decode(_ data: Data) throws -> Response {
		data
	}

	init(url: URL? = nil) {
		self.url = url
	}
}
