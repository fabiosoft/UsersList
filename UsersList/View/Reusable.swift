//
//  Reusable.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation

protocol Reusable: NSObject {
	static var reuseIdentifier: String { get }

	associatedtype DataType
	var model: DataType? { get set }
}
