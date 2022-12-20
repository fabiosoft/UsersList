//
//  UsersFeedTests.swift
//  UsersListTests
//
//  Created by Fabio Nisci on 20/12/22.
//

import XCTest
import UsersList

final class UsersFeedTests: XCTestCase {
	func test_loader_deliversConnectivityErrorOnClientError() {
		let exp = XCTestExpectation()

		FeedLoaderMockURLProtocol.loadingHandler = { request in
			let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
			return (response, nil, NetworkError.networkError)
		}

		let (_, sut) = makeSUT()
		sut.loadUsers { result in
			switch result {
			case .success:
				break
			case .failure(let error):
				XCTAssertNotNil(error)
				XCTAssertEqual(error, NetworkError.networkError)
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClient, sut: UsersLoader) {
		let config = URLSessionConfiguration.ephemeral
		config.protocolClasses = [FeedLoaderMockURLProtocol.self]
		let session = URLSession(configuration: config)
		let client = NetworkService(session: session)
		let sut = UsersLoader(client)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (client, sut)
	}
}
