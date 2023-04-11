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
class URLSessionHTTPClientTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		URLProtocolStub.startInterceptingRequests()
	}
	
	override func tearDown() {
		super.tearDown()
		
		URLProtocolStub.stopInterceptingRequests()
	}
	
	func test_getFromURL_performsGETRequestWithURL() {
		let url = URL(string: "http://any-url.com")!
		let exp = expectation(description: "Wait for request")
		
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}
		
		URLSessionHTTPClient().get(from: url) { _ in }
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_getFromURL_failsOnRequestError() {
		let url = URL(string: "http://any-url.com")!
		let error = NSError(domain: "any-error", code: 1)
		URLProtocolStub.stub(data: nil, response: nil, error: error)
		
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
	}
	// MARK: - Helpers
		
	private class URLProtocolStub: URLProtocol {
		private static var stub: Stub?
		private static var requestObserver: ((URLRequest) -> Void)?
		
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}
		
		static func stub(data: Data?, response: URLResponse? , error: Error? = nil) {
			stub = Stub(data: data, response: response, error: error)
		}
		
		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
			requestObserver = nil
		}
		
		static func observeRequests(observer: @escaping (URLRequest) -> Void) {
			requestObserver = observer
		}
		
		override class func canInit(with request: URLRequest) -> Bool {
			requestObserver?(request)
			return true
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			if let data = URLProtocolStub.stub?.data {
				client?.urlProtocol(self, didLoad: data)
			}
			
			if let response = URLProtocolStub.stub?.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			if let error = URLProtocolStub.stub?.error {
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
