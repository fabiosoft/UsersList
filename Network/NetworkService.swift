//
//  NetworkService.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

public enum NetworkError: Error {
	case networkError
	case malformedURL
	case malformedData
}

public protocol NetworkService {
	func request<Request: DataRequest>(_ request: Request, completion: @escaping (Result<(Request.Response, HTTPURLResponse), NetworkError>) -> Void)
}

final public class HTTPClient: NetworkService {
	private var session: URLSession

	public init(session: URLSession = URLSession.shared) {
		self.session = session
	}

	public func request<Request: DataRequest>(_ request: Request, completion: @escaping (Result<(Request.Response, HTTPURLResponse), NetworkError>) -> Void) {
		guard let urlRequest = request.urlRequest else {
			return completion(.failure(.malformedURL))
		}

		let task = session.dataTask(with: urlRequest) { (data, response, error) in
			if error != nil {
				return completion(.failure(.networkError))
			}

			guard let response = response as? HTTPURLResponse, 200 ..< 300 ~= response.statusCode else {
				return completion(.failure(.networkError))
			}

			guard let data = data else {
				return completion(.failure(.malformedData))
			}

			do {
				let decoded = try request.decode(data)
				completion(.success((decoded, response)))
			} catch {
				completion(.failure(.malformedData))
			}
		}
		task.resume()
	}
}
