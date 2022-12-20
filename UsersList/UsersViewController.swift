//
//  UsersViewController.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import UIKit

public final class UsersViewController: UITableViewController {
	public typealias UsersDataSource = UITableViewDiffableDataSource<UsersFeedSection, UserViewModel>
	public typealias UsersSnapshot = NSDiffableDataSourceSnapshot<UsersFeedSection, UserViewModel>

	var didSelect: ((UserViewModel) -> Void)?
	var imageLoader: RemoteImageLoader?
	var usersLoader: RemoteFeedLoader?

	private var model = UsersCollection()

	public lazy var diffDataSource = makeDataSource()

	public let pullRefreshControl = UIRefreshControl()
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		load()
	}

	public func cellProvider(_ tableView: UITableView, _ indexPath: IndexPath, _ itemIdentifier: UserViewModel) -> UITableViewCell? {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
		cell.imageLoader = self.imageLoader
		cell.model = itemIdentifier
		return cell
	}

	public func makeDataSource() -> UsersDataSource {
		let dataSource = UsersDataSource(
			tableView: tableView,
			cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
				return self?.cellProvider(tableView, indexPath, itemIdentifier)
			})
		var snapshot = UsersSnapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems([])
		dataSource.apply(snapshot, animatingDifferences: false)
		return dataSource
	}

	func applySnapshot(items: [UserViewModel], animatingDifferences: Bool = false) {
		var snapshot = UsersSnapshot()
		snapshot.appendSections([.main])
		snapshot.appendItems(items)
		self.diffDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
	}

	private func setupViews() {
		pullRefreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
		tableView.addSubview(pullRefreshControl)
		tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
	}

	@objc
	private func load() {
		pullRefreshControl.beginRefreshing()

		usersLoader?.loadUsers(page: 1, completion: { [weak self] result in
			guard let self = self else { return }
			if let users = try? result.get() {
				self.model = users
				self.applySnapshot(items: users.map(UserViewModel.init), animatingDifferences: true)
			}
			self.pullRefreshControl.endRefreshing()
		})
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let user = diffDataSource.itemIdentifier(for: indexPath) {
			self.didSelect?(user)
		}
	}
}
