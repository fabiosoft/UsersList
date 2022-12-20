//
//  UsersFeedTests.swift
//  UsersListTests
//
//  Created by Fabio Nisci on 20/12/22.
//

import XCTest
import UsersList

final class UsersFeedTests: XCTestCase {
	func test_loader_doesNotRequestUrlUponCreation() {
		let (client, _) = makeSUT()

		XCTAssertEqual([], client.requestedUrls, "expecting sut not to perform any requests upon creation")
	}

	func test_loader_requestCorrectUrlEveryTimeIsInvoked() {
		let (client, sut) = makeSUT()

		sut.loadUsers(page: 1) { _ in }
		sut.loadUsers(page: 2) { _ in }

		XCTAssertEqual(2, client.requestedUrls.count,
		               "expecting sut to hit endpoint every time load is invoked"
		)
	}

	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy<LoadUsersRequest>, sut: UsersLoader) {
		let client = HTTPClientSpy<LoadUsersRequest>()
		let sut = UsersLoader(client)
		trackForMemoryLeaks(client, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (client, sut)
	}
}
