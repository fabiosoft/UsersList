//
//  Coordinator.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation
import UIKit

protocol Coordinator {
	var childCoordinators: [Coordinator] { get set } // larger app, sub sections coordinators
	var navigationController: UINavigationController { get set }

	func start()
}
