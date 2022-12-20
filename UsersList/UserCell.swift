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

class UserCell: UITableViewCell, Reusable {
	static var reuseIdentifier: String = "UserCell"
	private var imageTask: NetworkSessionTask?
	var imageLoader: RemoteImageLoader?

	var model: UserViewModel? {
		didSet {
			self.imageView?.contentMode = .scaleAspectFit
			self.textLabel?.text = model?.name

			if let imageURL = model?.imageURL {
				self.imageTask = self.imageLoader?.loadUserImage(from: imageURL, completion: { [weak self] result in
					guard self != nil else { return }
					if let imageData = try? result.get() {
						self?.imageView?.image = UIImage(data: imageData)
					}
				})
			}
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.imageTask?.cancel()
	}
}
