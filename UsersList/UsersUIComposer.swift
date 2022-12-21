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
		usersFeedVC.title = UsersViewModel.title
		return usersFeedVC
	}
}
