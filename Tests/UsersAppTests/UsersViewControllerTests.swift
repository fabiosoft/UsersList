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

	func test_loadCompletion_rendersSuccessfullyLoadedCountries() {
		let user0 = makeUser()
		let user1 = makeUser()
		let user2 = makeUser()

		let pageWithoutCountries = makePage([])
		let pageWithOneCountry = makePage([user0])
		let pageWithThreeCountries = makePage([user0, user1, user2])

		let (loader, sut) = makeSUT()

		sut.loadViewIfNeeded()
		assertThat(sut, isRendering: pageWithoutCountries)

		loader.completeLoading(with: pageWithOneCountry, at: 0)
		assertThat(sut, isRendering: pageWithOneCountry)

		sut.triggerReloading()
		loader.completeLoading(with: pageWithThreeCountries, at: 1)
		assertThat(sut, isRendering: pageWithThreeCountries)

		sut.triggerReloading()
		loader.completeLoadingWithError(at: 2)
		assertThat(sut, isRendering: pageWithThreeCountries)
	}

	// MARK: - Helpers

	private func assertThat(_ sut: UsersViewController, isRendering users: UsersCollection, file: StaticString = #filePath, line: UInt = #line) {
		XCTAssertEqual(users.count, sut.numberOfRenderedUsers(), "expected view controller to render \(users.count) cells, got \(sut.numberOfRenderedUsers()) instead", file: file, line: line)

		users.enumerated().forEach { idx, user in
			let view = sut.userView(at: idx)
			XCTAssertNotNil(view, "expected view controller to render view with \(user)", file: file, line: line)
			let name = user.name?.first?.capitalized
			let surname = user.name?.last
			let completeName = "\(name!) \(surname!)"
			XCTAssertEqual(completeName, view?.userName, "expected view controller to configure cell with \(completeName), got \(view?.userName ?? "") instead", file: file, line: line)
		}
	}

	private func makePage(_ users: [User]) -> UsersCollection {
		return users
	}

	private func makeUser(name: String = "any user name", surname: String = "any surname", flagURL url: URL = URL(string: "http://a-user-url.com")!) -> User {
		User(name: Name(title: nil, first: name, last: surname), email: nil, id: ID(name: UUID().uuidString, value: UUID().uuidString), picture: Picture(large: url.absoluteString, medium: url.absoluteString, thumbnail: url.absoluteString))
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: UsersFeedLoaderSpy, sut: UsersViewController) {
		let loader = UsersFeedLoaderSpy()
		let sut = UsersUIComposer.usersController(withImageLoader: loader, usersLoader: loader)
		trackForMemoryLeaks(loader, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		return (loader, sut)
	}
}

class UsersFeedLoaderSpy: RemoteFeedLoader, RemoteImageLoader {
	func map(_ userCollection: UsersList.UsersCollection) -> [UsersList.UserViewModel] {
		userCollection.map(UserViewModel.init)
	}

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

private extension UITableViewCell {
	var userName: String? {
		return textLabel?.text
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
