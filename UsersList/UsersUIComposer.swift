//
//  UsersUIComposer.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation

public final class UsersUIComposer {
	private init() {}

	public static func usersController(withImageLoader: RemoteImageLoader, usersLoader: RemoteFeedLoader) -> UsersViewController {
		let usersFeedVC = UsersViewController()
		usersFeedVC.imageLoader = MainQueueDispatchDecorator(decoratee: withImageLoader)
		usersFeedVC.usersLoader = MainQueueDispatchDecorator(decoratee: usersLoader)
		return usersFeedVC
	}
}

private final class MainQueueDispatchDecorator<T> {
	private let decoratee: T

	init(decoratee: T) {
		self.decoratee = decoratee
	}
}

extension MainQueueDispatchDecorator: RemoteFeedLoader where T == RemoteFeedLoader {
	func loadUsers(page: UInt, completion: @escaping RemoteFeedLoader.Completion) {
		decoratee.loadUsers(page: page) { result in
			if Thread.isMainThread {
				completion(result)
			} else {
				DispatchQueue.main.async { completion(result) }
			}
		}
	}
}

extension MainQueueDispatchDecorator: RemoteImageLoader where T == RemoteImageLoader {
	func loadUserImage(from url: URL, completion: @escaping RemoteImageLoader.Completion) -> NetworkSessionTask? {
		return decoratee.loadUserImage(from: url) { result in
			if Thread.isMainThread {
				completion(result)
			} else {
				DispatchQueue.main.async { completion(result) }
			}
		}
	}
}
