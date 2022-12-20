//
//  UsersViewController.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import UIKit

public final class UsersViewController: UITableViewController {
	var imageLoader: RemoteImageLoader?
	var usersLoader: RemoteFeedLoader?

	private var model = UsersCollection()

	public let pullRefreshControl = UIRefreshControl()
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		load()
	}

	private func setupViews() {
		pullRefreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
		tableView.addSubview(pullRefreshControl)
	}

	@objc
	private func load() {
		pullRefreshControl.beginRefreshing()

		usersLoader?.loadUsers(page: 1, completion: { [weak self] result in
			guard let self = self else { return }
			if let users = try? result.get() {
				self.model = users
				self.tableView.reloadData()
			}
			self.pullRefreshControl.endRefreshing()
		})
	}
}
