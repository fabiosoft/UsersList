//
//  UsersImageLoader.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

public final class UsersImageLoader: RemoteImageLoader {
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(client: HTTPClient) {
		self.client = client
	}

	public func loadUserImage(from url: URL, completion: @escaping Completion) -> NetworkSessionTask? {
		let imageLoaderRequest = LoadUserImageRequest(url: url)
		return client.request(imageLoaderRequest) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success((imageData, response)):
				//improvement could be caching images
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
