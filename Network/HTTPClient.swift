//
//  HTTPClient.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation

public enum NetworkError: Error {
	case networkError
	case malformedURL
	case malformedData
}

public protocol NetworkSessionTask {
	func cancel()
}

extension URLSessionDataTask: NetworkSessionTask {}

public protocol HTTPClient {
	@discardableResult
	func request<Request: DataRequest>(_ request: Request, completion: @escaping (Result<(Request.Response, HTTPURLResponse), NetworkError>) -> Void) -> NetworkSessionTask?
}
