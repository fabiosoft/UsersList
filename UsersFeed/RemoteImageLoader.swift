//
//  RemoteImageLoader.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation

public protocol RemoteImageLoader {
	typealias Result = Swift.Result<Data, Error>
	typealias Completion = (Result) -> Void

	func loadUserImage(from url: URL, completion: @escaping Completion) -> NetworkSessionTask?
}
