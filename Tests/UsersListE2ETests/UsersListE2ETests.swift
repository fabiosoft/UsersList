//
//  UsersListE2ETests.swift
//  UsersList
//
//  Created by Fabio Nisci on 20/12/22.
//

import XCTest
import UsersList

final class UsersListE2ETests: XCTestCase {
	func test_HTTPClient_completesWithGivenStatusCode() {
		let sut = makeSUT()

		let samples = [200, 300, 400, 500]
		let exp = expectation(description: "wait for client completion")
		exp.expectedFulfillmentCount = samples.count

		for sample in samples {
			let request = StatusRequest(status: sample)
			sut.request(request) { result in
				if let (_, httpResponse) = try? result.get() {
					XCTAssertEqual(sample, httpResponse.statusCode, "expected status code \(sample), got \(httpResponse.statusCode) instead")
				}
				exp.fulfill()
			}
		}

		wait(for: [exp], timeout: 3.0)
	}

	func test_HTTPClient_completesWithGivenBodyResponse() {
		let sut = makeSUT()

		let exp = expectation(description: "wait for client completion")
		let req = B64BodyRequest(body: "SFRUUEJJTiBpcyBhd2Vzb21l")
		sut.request(req) { result in
			if let (output, _) = try? result.get() {
				XCTAssertEqual("HTTPBIN is awesome", output, "expected 'HTTPBIN is awesome' when getting \(String(describing: req.url))")
			} else {
				XCTFail("expected 'HTTPBIN is awesome', got \(result) instead")
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 3.0)
	}

	// MARK: - Helper

	private struct StatusRequest: DataRequest {
		typealias Response = String

		var url: URL? {
			URL(string: "https://httpbin.org/status/\(status)")
		}

		var method: UsersList.HTTPMethod { .get }

		var headers: [String: String] {
			["accept": "text/plain"]
		}

		var queryItems: [String: String] { [:] }

		var urlRequest: URLRequest? { nil }

		func decode(_ data: Data) throws -> String {
			return String(data: data, encoding: .utf8) ?? ""
		}

		let status: Int
		init(status: Int) {
			self.status = status
		}
	}

	private struct B64BodyRequest: DataRequest {
		typealias Response = String

		var url: URL? {
			URL(string: "https://httpbin.org/base64/\(body)")
		}

		var method: UsersList.HTTPMethod { .get }

		var headers: [String: String] {
			["accept": "text/plain"]
		}

		var queryItems: [String: String] { [:] }

		var urlRequest: URLRequest? {
			guard let url = self.url else {
				return nil
			}
			return URLRequest(url: url)
		}

		func decode(_ data: Data) throws -> String {
			return String(data: data, encoding: .utf8) ?? ""
		}

		let body: String
		init(body: String) {
			self.body = body
		}
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
		let session = URLSession(configuration: .ephemeral)
		let sut = HTTPClient(session: session)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
}
