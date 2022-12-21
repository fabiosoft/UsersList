//
//  UsersListUITests.swift
//  UsersListUITests
//
//  Created by Fabio Nisci on 21/12/22.
//

import XCTest
import UsersList

final class UsersListUITests: XCTestCase {
	func test_emptyFeed() {
		let sut = makeSUT()

		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "EMPTY_FEED_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "EMPTY_FEED_dark")
	}

	func test_displayedSomeUsers() {
		let sut = makeSUT([
			User(name: Name(title: "Mr.", first: "Foo", last: "Bar"), email: "foo.bar@email.com", id: nil, picture: nil),
			User(name: Name(title: "Ms.", first: "Boo", last: "Beep"), email: "boo.beep@email.com", id: nil, picture: nil)
		])

		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "USERS_FEED_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "USERS_FEED_dark")
	}

	// MARK: - Helpers

	private func makeSUT(_ users: UsersCollection = []) -> UsersViewController {
		let loader = AlwaysSucceedingFeedLoader(users)
		let sut = UsersUIComposer.usersController(withImageLoader: loader, usersLoader: loader)
		sut.loadViewIfNeeded()
		sut.tableView.showsVerticalScrollIndicator = false
		sut.tableView.showsHorizontalScrollIndicator = false
		return sut
	}

	private func emptyFeed() -> UsersCollection {
		[]
	}

	private class AlwaysSucceedingFeedLoader: RemoteFeedLoader, RemoteImageLoader {
		let users: UsersCollection
		internal init(_ users: UsersCollection) {
			self.users = users
		}

		func loadUserImage(from url: URL, completion: @escaping RemoteImageLoader.Completion) -> NetworkSessionTask? {
			completion(.success(Data()))
			return nil
		}

		func loadUsers(page: UInt, completion: @escaping RemoteFeedLoader.Completion) {
			completion(.success(users))
		}
	}
}

extension XCTestCase {
	func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)

		guard let snapshotData = snapshot.pngData() else {
			XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
			return
		}

		guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
			XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
			return
		}

		if !match(snapshotData, storedSnapshotData, tolerance: 0.00001) {
			let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
				.appendingPathComponent(snapshotURL.lastPathComponent)

			try? snapshotData.write(to: temporarySnapshotURL)

			XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
		}
	}

	func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)

		guard let snapshotData = snapshot.pngData() else {
			XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
			return
		}

		do {
			try FileManager.default.createDirectory(
				at: snapshotURL.deletingLastPathComponent(),
				withIntermediateDirectories: true
			)

			try snapshotData.write(to: snapshotURL)
			XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
		} catch {
			XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
		}
	}

	private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
		return URL(fileURLWithPath: String(describing: file))
			.deletingLastPathComponent()
			.appendingPathComponent("snapshots")
			.appendingPathComponent("\(name).png")
	}

	private func match(_ oldData: Data, _ newData: Data, tolerance: Float = 0) -> Bool {
		if oldData == newData { return true }

		guard let oldImage = UIImage(data: oldData)?.cgImage, let newImage = UIImage(data: newData)?.cgImage else {
			return false
		}

		guard oldImage.width == newImage.width, oldImage.height == newImage.height else {
			return false
		}

		let minBytesPerRow = min(oldImage.bytesPerRow, newImage.bytesPerRow)
		let bytesCount = minBytesPerRow * oldImage.height

		var oldImageByteBuffer = [UInt8](repeating: 0, count: bytesCount)
		guard let oldImageData = data(for: oldImage, bytesPerRow: minBytesPerRow, buffer: &oldImageByteBuffer) else {
			return false
		}

		var newImageByteBuffer = [UInt8](repeating: 0, count: bytesCount)
		guard let newImageData = data(for: newImage, bytesPerRow: minBytesPerRow, buffer: &newImageByteBuffer) else {
			return false
		}

		if memcmp(oldImageData, newImageData, bytesCount) == 0 { return true }

		return match(oldImageByteBuffer, newImageByteBuffer, tolerance: tolerance, bytesCount: bytesCount)
	}

	private func data(for image: CGImage, bytesPerRow: Int, buffer: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
		guard
			let space = image.colorSpace,
			let context = CGContext(
				data: buffer,
				width: image.width,
				height: image.height,
				bitsPerComponent: image.bitsPerComponent,
				bytesPerRow: bytesPerRow,
				space: space,
				bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
			)
		else { return nil }

		context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))

		return context.data
	}

	private func match(_ bytes1: [UInt8], _ bytes2: [UInt8], tolerance: Float, bytesCount: Int) -> Bool {
		var differentBytesCount = 0
		for i in 0 ..< bytesCount where bytes1[i] != bytes2[i] {
			differentBytesCount += 1

			let percentage = Float(differentBytesCount) / Float(bytesCount)
			if percentage > tolerance {
				return false
			}
		}
		return true
	}
}
