//
//  NetworkService.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

final public class NetworkService: HTTPClient { // a.k.a URLSessionHTTPClient
	private var session: URLSession

	public init(session: URLSession = URLSession.shared) {
		self.session = session
	}

	public func request<Request: DataRequest>(_ request: Request, completion: @escaping (Result<(Request.Response, HTTPURLResponse), NetworkError>) -> Void) -> NetworkSessionTask? {
		guard let urlRequest = request.urlRequest else {
			completion(.failure(.malformedURL))
			return nil
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
		return task
	}
}
