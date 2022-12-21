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
	private var isLoadingNewPage = false
	private var currentLoadedPage = 0
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
		dataSource.defaultRowAnimation = .fade
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
		self.loadUsers(page: 1, completion: { [weak self] result in
			guard let self = self else { return }
			if let users = try? result.get() {
				self.model = users
				self.applySnapshot(items: users.map(UserViewModel.init), animatingDifferences: true)
			}
			self.pullRefreshControl.endRefreshing()
		})
	}

	private func requestNextPage() {
		tableView.tableFooterView = loadingSpinnerView()
		let pageToLoad = currentLoadedPage + 1
		self.loadUsers(page: pageToLoad, completion: { [weak self] result in
			guard let self = self else { return }
			if let users = try? result.get() {
				self.model.append(contentsOf: users)
				var snapshot = self.diffDataSource.snapshot()
				snapshot.appendItems(users.map(UserViewModel.init))
				self.diffDataSource.apply(snapshot, animatingDifferences: true)
			}
			self.tableView.tableFooterView = nil
		})
	}

	private func loadUsers(page: Int, completion: @escaping RemoteFeedLoader.Completion) {
		isLoadingNewPage = true
		usersLoader?.loadUsers(page: UInt(page), completion: { [weak self] result in
			guard let self = self else { return }
			self.isLoadingNewPage = false
			self.currentLoadedPage = page
			completion(result)
		})
	}

	public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let user = diffDataSource.itemIdentifier(for: indexPath) {
			self.didSelect?(user)
		}
	}

	public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isDragging else { return }

		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		if (offsetY > contentHeight - scrollView.frame.height && !isLoadingNewPage) {
			requestNextPage()
		}
	}

	private func loadingSpinnerView() -> UIView {
		let spinnerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
		let spinner = UIActivityIndicatorView(style: .medium)
		spinner.center = spinnerView.center
		spinnerView.addSubview(spinner)
		spinner.startAnimating()
		return spinnerView
	}
}
