//
//  UsersViewController.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import UIKit

public final class UsersViewController: UITableViewController {
	typealias UsersDataSource = UITableViewDiffableDataSource<UsersFeedSection, UserViewModel>
	typealias UsersSnapshot = NSDiffableDataSourceSnapshot<UsersFeedSection, UserViewModel>

	var imageLoader: RemoteImageLoader?
	var usersLoader: RemoteFeedLoader?

	private var model = UsersCollection() {
		didSet {
			self.applySnapshot(items: usersLoader?.map(model) ?? [], animatingDifferences: true)
		}
	}

	private(set) lazy var dataSource = makeDataSource()

	public let pullRefreshControl = UIRefreshControl()
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		load()
	}

	func makeDataSource() -> UsersDataSource {
		let dataSource = UsersDataSource(
			tableView: tableView,
			cellProvider: { tableView, indexPath, itemIdentifier in
				let cell = tableView.dequeueReusableCell(
					withIdentifier: UserCell.reuseIdentifier, for: indexPath) as! UserCell
				cell.model = itemIdentifier
				return cell
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
		self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
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
			}
			self.pullRefreshControl.endRefreshing()
		})
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
