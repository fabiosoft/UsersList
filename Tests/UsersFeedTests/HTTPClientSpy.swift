//
//  HTTPClientSpy.swift
//  UsersListTests
//
//  Created by Fabio Nisci on 20/12/22.
//

import XCTest
import UsersList

class HTTPClientSpy<Request: DataRequest>: HTTPClient {
	private(set) var requestedUrls = [String]()
	//    private var completions = [(Result<(Data, HTTPURLResponse), Error>) -> Void]()
	private var completions = [(Result<(Request.Response, HTTPURLResponse), UsersList.NetworkError>) -> Void]()

	func request<Request>(_ request: Request, completion: @escaping (Result<(Request.Response, HTTPURLResponse), UsersList.NetworkError>) -> Void) where Request: UsersList.DataRequest {
		requestedUrls.append(request.urlRequest?.url?.absoluteString ?? "")
		completions.append { result in
			switch result {
			case .success(let (output, httpResponse)):
				print(output)
			//                completion(.success(("", httpResponse)))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
