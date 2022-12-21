//
//  MainCoordinator.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {
	var childCoordinators = [Coordinator]()
	var navigationController: UINavigationController

	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}

	func start() {
		let feed = feedUsersVC()
		navigationController.pushViewController(feed, animated: false)
	}

	private func feedUsersVC() -> UsersViewController {
        let session = URLSession(configuration: .ephemeral, delegate: nil /*SSLPinningManager()*/, delegateQueue: nil)
		let service = NetworkService(session: session)
		let imageLoader = UsersImageLoader(client: service)
		let usersLoader = UsersLoader(service)
		let feed = UsersUIComposer.usersController(withImageLoader: imageLoader, usersLoader: usersLoader)
		//feed.didSelect = { [weak self] user in
		//    guard let _ = self else { return }
		//    //no-op
		//}
		return feed
	}
}
