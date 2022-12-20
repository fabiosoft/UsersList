//
//  UserCell.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import Foundation
import UIKit

protocol Reusable: NSObject {
	static var reuseIdentifier: String { get }

	associatedtype DataType
	var model: DataType? { get set }
}

public class UserCell: UITableViewCell, Reusable {
	static var reuseIdentifier: String = "UserCell"
	private var imageTask: NetworkSessionTask?
	var imageLoader: RemoteImageLoader?

	public lazy var userImageView: UIImageView = {
		let img = UIImageView()
		img.widthAnchor.constraint(equalToConstant: 60).isActive = true
		let heightAnchor = img.heightAnchor.constraint(equalToConstant: 60)
		heightAnchor.priority = .defaultHigh
		heightAnchor.isActive = true
		img.translatesAutoresizingMaskIntoConstraints = false
		img.contentMode = .scaleAspectFit
		return img
	}()

	public lazy var userLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .preferredFont(forTextStyle: .body)
		return lbl
	}()

	public lazy var emailLabel: UILabel = {
		let lbl = UILabel()
		lbl.font = .preferredFont(forTextStyle: .body)
		return lbl
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		let labels = UIStackView(arrangedSubviews: [userLabel, emailLabel])
		labels.distribution = .fill
		labels.axis = .vertical

		let stackview = UIStackView(arrangedSubviews: [userImageView, labels])
		stackview.distribution = .fill
		stackview.axis = .horizontal
		stackview.translatesAutoresizingMaskIntoConstraints = false
		stackview.spacing = 8
		contentView.addSubview(stackview)
		NSLayoutConstraint.activate([
			stackview.leadingAnchor.constraint(equalTo: contentView.readableContentGuide.leadingAnchor),
			stackview.trailingAnchor.constraint(equalTo: contentView.readableContentGuide.trailingAnchor),
			stackview.topAnchor.constraint(equalTo: contentView.topAnchor),
			stackview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		])
	}

	var model: UserViewModel? {
		didSet {
			self.userLabel.text = model?.name
			self.emailLabel.text = model?.email

			if let imageURL = model?.imageURL {
				self.imageTask = self.imageLoader?.loadUserImage(from: imageURL, completion: { [weak self] result in
					guard let self = self else { return }
					if let imageData = try? result.get() {
						self.userImageView.image = UIImage(data: imageData)
					}
				})
			}
		}
	}

	public override func prepareForReuse() {
		super.prepareForReuse()
		self.imageTask?.cancel()
	}
}
