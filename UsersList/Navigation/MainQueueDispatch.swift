//
//  MainQueueDispatch.swift
//  UsersList
//
//  Created by Fabio Nisci on 21/12/22.
//

import Foundation

public final class MainQueueDispatchDecorator<T> {
	private let decoratee: T

	init(decoratee: T) {
		self.decoratee = decoratee
	}
}

extension MainQueueDispatchDecorator: RemoteFeedLoader where T == RemoteFeedLoader {
	public func loadUsers(page: UInt, completion: @escaping RemoteFeedLoader.Completion) {
		decoratee.loadUsers(page: page) { result in
			if Thread.isMainThread {
				completion(result)
			} else {
				DispatchQueue.main.async { completion(result) }
			}
		}
	}
}

extension MainQueueDispatchDecorator: RemoteImageLoader where T == RemoteImageLoader {
	public func loadUserImage(from url: URL, completion: @escaping RemoteImageLoader.Completion) -> NetworkSessionTask? {
		return decoratee.loadUserImage(from: url) { result in
			if Thread.isMainThread {
				completion(result)
			} else {
				DispatchQueue.main.async { completion(result) }
			}
		}
	}
}
