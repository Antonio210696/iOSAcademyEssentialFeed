//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 10/04/23.
//

import XCTest

class URLSessionHTTPClient {
	private let session: URLSession
	
	init(session: URLSession) {
		self.session = session
	}
	
	func get(from url: URL) {
		session.dataTask(with: url) { _, _, _ in}.resume()
	}
}
class URLSessionHTTLClientTests: XCTestCase {
	
	func test_getFromURL_resumesDataTaskWithURL() {
		let url = URL(string: "http://any-url.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		session.stub(url: url, task: task)
		let sut = URLSessionHTTPClient(session: session)
		
		sut.get(from: url)
		
		XCTAssertEqual(task.resumeCallCount, 1)
	}
	// MARK: - Helpers
		
	private class URLSessionSpy: URLSession {
		private var stubs = [URL : URLSessionDataTask]()
		
		func stub(url: URL, task: URLSessionDataTask) {
			stubs[url] = task
		}
		
		override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
			return stubs[url] ?? FakeURLSessionDataTask()
		}
	}
	
	private class FakeURLSessionDataTask: URLSessionDataTask {
		override func resume() { }
	}
	private class URLSessionDataTaskSpy: URLSessionDataTask {
		var resumeCallCount = 0
		
		override func resume() {
			resumeCallCount += 1
		}
	}
}

// mocking subclasses of foundation classes can be dangerous because we dont have implementation detail about those classes and we do not override all their methods
// we are coupling a lot the tests with the API implementation.
