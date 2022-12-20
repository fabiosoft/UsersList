//
//  UsersViewControllerTests.swift
//  UsersListTests
//
//  Created by Fabio Nisci on 20/12/22.
//

import XCTest
import UsersList

final class UsersViewControllerTests: XCTestCase {
	func test_loadUsers_requestUsersToLoader() {
		let (loader, sut) = makeSUT()
		XCTAssertEqual(0, loader.loadFeedCallCount, "expected no service loading before the view is loaded into memory")

		sut.loadViewIfNeeded()
		XCTAssertEqual(1, loader.loadFeedCallCount, "expected loading once when the view is loaded into memory")

		sut.triggerReloading()
		XCTAssertEqual(2, loader.loadFeedCallCount, "expected loading when user pull to refresh")

		sut.triggerReloading()
		XCTAssertEqual(3, loader.loadFeedCallCount, "expected loading when user pull to refresh")
	}

	func test_loadingIndicator_isVisibleWhileLoading() {
		let (loader, sut) = makeSUT()

		sut.loadViewIfNeeded()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "expected to display loading indicator while service is loading")

		loader.completeLoading(at: 0)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "expected to hide loading indicator when service completes loading")

		sut.triggerReloading()
		XCTAssertTrue(sut.isShowingLoadingIndicator, "expected to display loading indicator when user trigger reloading")

		loader.completeLoadingWithError(at: 1)
		XCTAssertFalse(sut.isShowingLoadingIndicator, "expected to hide loading indicator when reloading completes")
	}

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
	// MARK: - UsersLoader

	private var feedRequests = [RemoteFeedLoader.Completion]()

	var loadFeedCallCount: Int {
		return feedRequests.count
	}

	func loadUsers(page: UInt, completion: @escaping RemoteFeedLoader.Completion) {
		feedRequests.append(completion)
	}

	func completeLoading(with users: UsersCollection = [], at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
		guard index < feedRequests.count else {
			return XCTFail("cannot complete loading never made")
		}

		feedRequests[index](.success(users))
	}

	func completeLoadingWithError(at index: Int = 0, error: NetworkError = .malformedData, file: StaticString = #filePath, line: UInt = #line) {
		guard index < feedRequests.count else {
			return XCTFail("cannot complete loading never made")
		}
		feedRequests[index](.failure(error))
	}

	func loadUserImage(from url: URL, completion: @escaping RemoteImageLoader.Completion) {}
}

private extension UsersViewController {
	func simulateUserViewVisible(at row: Int) {
		_ = userView(at: row)
	}

	func triggerReloading() {
		pullRefreshControl.simulatePullToRefresh()
	}

	func numberOfRenderedUsers() -> Int {
		return tableView.numberOfRows(inSection: 0)
	}

	func userView(at row: Int) -> UITableViewCell? {
		let datasource = tableView.dataSource
		let index = IndexPath(row: row, section: 0)
		return datasource?.tableView(tableView, cellForRowAt: index)
	}

	var isShowingLoadingIndicator: Bool {
		return pullRefreshControl.isRefreshing == true
	}
}

private extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
				(target as NSObject).perform(Selector($0))
			})
		}
	}
}
