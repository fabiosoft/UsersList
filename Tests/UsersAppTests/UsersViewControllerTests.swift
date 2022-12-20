//
//  UsersViewControllerTests.swift
//  UsersListTests
//
//  Created by Fabio Nisci on 20/12/22.
//

import XCTest
import UsersList

final class UsersViewControllerTests: XCTestCase {
	// MARK: - Helpers

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: UsersFeedLoaderSpy, sut: UsersViewController) {
		let loader = UsersFeedLoaderSpy()
		let sut = UsersUIComposer.usersController(withImageLoader: loader, usersLoader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (loader, sut)
	}
}

class UsersFeedLoaderSpy: RemoteFeedLoader, RemoteImageLoader {
	func loadUsers(page: UInt, completion: @escaping RemoteFeedLoader.Completion) {}

	func loadUserImage(from url: URL, completion: @escaping RemoteImageLoader.Completion) {}
}
