//
//  AppDelegate.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let session = URLSession(configuration: .ephemeral)
		let service = NetworkService(session: session)
		let imageloader = UsersImageLoader(client: service)
		let usersLoader = UsersLoader(service)
		let feed = UsersUIComposer.usersController(withImageLoader: imageloader, usersLoader: usersLoader)
		let nav = UINavigationController(rootViewController: feed)
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = nav
		window?.makeKeyAndVisible()
		return true
	}
}
