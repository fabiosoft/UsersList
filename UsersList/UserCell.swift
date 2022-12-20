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

	var model: UserViewModel? {
		didSet {
			self.textLabel?.text = model?.name
		}
	}
}
