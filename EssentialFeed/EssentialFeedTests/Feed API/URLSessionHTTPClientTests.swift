//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 10/04/23.
//

import XCTest
import EssentialFeed


class URLSessionHTTPClient {
	private let session: URLSession
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
		session.dataTask(with: url) { _, _, error in
			if let error = error {
				completion(.failure(error))
			}
		}.resume()
	}
}
class URLSessionHTTLClientTests: XCTestCase {
	
	func test_getFromURL_failsOnRequestError() {
		URLProtocolStub.startInterceptingRequests()
		let url = URL(string: "http://any-url.com")!
		let error = NSError(domain: "any-error", code: 1)
		URLProtocolStub.stub(url: url, error: error)
		
		let sut = URLSessionHTTPClient()
		
		let exp = expectation(description: "Wait for completion")
		sut.get(from: url) { result in
			switch result {
			case let .failure(receivedError as NSError):
				XCTAssertEqual(receivedError, error)
			default:
				XCTFail("Expected failure with error \(error), got \(result) instead")
			}
			
			exp.fulfill()
		}
		
		wait(for: [exp], timeout: 1.0)
		URLProtocolStub.stopInterceptingRequests()
	}
	// MARK: - Helpers
		
	private class URLProtocolStub: URLProtocol {
		private static  var stubs = [URL : Stub]()
		
		private struct Stub {
			let error: Error?
		}
		
		static func stub(url: URL, error: Error? = nil) {
			stubs[url] = Stub(error: error)
		}
		
		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stubs = [:]
		}
		
		override class func canInit(with request: URLRequest) -> Bool {
			guard let url = request.url else { return false }
			
			return URLProtocolStub.stubs[url] != nil
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
			
			if let error = stub.error {
				client?.urlProtocol(self, didFailWithError: error)
			}
			
			client?.urlProtocolDidFinishLoading(self)
		}
		
		override func stopLoading() { }
	}
}

// mocking subclasses of foundation classes can be dangerous because we dont have implementation detail about those classes and we do not override all their methods
// we are coupling a lot the tests with the API implementation.

// a way could be to use protocols with just the signature of the method that we previously overrode
// We copy exactly the same methods that we have in the foundation classes, and we have added these methods only for testing purposes.

// URLProtocol API
// perform url request, a url loadign System with URL protocol, abstract class. If we register to this class, we can intercept requests. URLProtocol can be used to implement custom protocols, analytics, cache profiling and other stuff
// We can create a subclass that intercepts our request and return our stubbed responses.
