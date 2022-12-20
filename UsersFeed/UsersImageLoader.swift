//
//  UsersImageLoader.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

public protocol RemoteImageLoader {
	typealias Result = Swift.Result<Data, Error>
	typealias Completion = (Result) -> Void

	func loadUserImage(from url: URL, completion: @escaping Completion)
}

public final class UsersImageLoader: RemoteImageLoader {
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(client: HTTPClient) {
		self.client = client
	}

	public func loadUserImage(from url: URL, completion: @escaping Completion) {
		let imageLoaderRequest = LoadUserImageRequest(url: url)
		client.request(imageLoaderRequest) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success((imageData, response)):
				completion(self.map(imageData, and: response))
			case let .failure(error):
				completion(.failure(error))
			}
		}
	}

	private func map(_ data: Data, and response: HTTPURLResponse) -> RemoteImageLoader.Result {
		guard response.statusCode < 400 else {
			return .failure(Error.invalidData)
		}

		return .success(data)
	}
}

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
