//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 10/04/23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
	override func tearDown() {
		super.tearDown()
		
		URLProtocolStub.removeStub()
	}
	
	func test_getFromURL_performsGETRequestWithURL() {
		let url = anyURL()
		let exp = expectation(description: "Wait for request")
		
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}
		
		makeSUT().get(from: url) { _ in }
		
		wait(for: [exp], timeout: 1.0)
	}
	
	func test_getFromURL_failsOnRequestError() {
		let requestError = anyNSError()
		
		let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
		
		XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
		XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
	}
	
	func test_getFromURL_failsOnAllInvalidRepresentationCases() {
		XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
		XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPResponse(), error: nil)))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPResponse(), error: anyNSError())))
		XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPResponse(), error: nil)))
	}
	
	func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
		let data = anyData()
		let response = anyHTTPResponse()
		let receivedValues = resultValuesFor((data: data, response: response, error: nil))
		
		XCTAssertEqual(receivedValues?.data, data)
		XCTAssertEqual(receivedValues?.response.url, response?.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
	}
	
	func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
		let response = anyHTTPResponse()
		let receivedValues = resultValuesFor((data: nil, response: anyHTTPResponse(), error: nil))
		
		let emptyData = Data()
		XCTAssertEqual(receivedValues?.data, emptyData)
		XCTAssertEqual(receivedValues?.response.url, response?.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response?.statusCode)
	}
	
	func test_cancelGetFromURLTask_cancelsURLRequest() {
		let exp = expectation(description: "Wait for request")
		URLProtocolStub.observeRequests { _ in exp.fulfill() }
		
		let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
		wait(for: [exp], timeout: 1.0)
		
		XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
	}
	
	// MARK: - Helpers
	
	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [URLProtocolStub.self]
		let session = URLSession(configuration: configuration)
		
		let sut = URLSessionHTTPClient(session: session)
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func nonHTTPResponse() -> URLResponse {
		URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
		
	private func anyHTTPResponse() -> HTTPURLResponse! {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
		let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
		
		switch result {
		case .failure(let  error):
			return error
		default:
			XCTFail("Expected failure, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
		let result = resultFor(values, file: file, line: line)
		
		switch result {
		case .success(let data, let response):
			return (data, response)
		default:
			XCTFail("Expected success, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
		values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
		
		let sut = makeSUT(file: file, line: line)
		 
		var receivedResult: HTTPClient.Result!
		
		let exp = expectation(description: "Wait for completion")
		taskHandler(sut.get(from: anyURL()) { result in
				receivedResult = result
				exp.fulfill()
			})
		
		wait(for: [exp], timeout: 1.0)
		return receivedResult
	}
}

// mocking subclasses of foundation classes can be dangerous because we dont have implementation detail about those classes and we do not override all their methods
// we are coupling a lot the tests with the API implementation.

// a way could be to use protocols with just the signature of the method that we previously overrode
// We copy exactly the same methods that we have in the foundation classes, and we have added these methods only for testing purposes.

// URLProtocol API
// perform url request, a url loadign System with URL protocol, abstract class. If we register to this class, we can intercept requests. URLProtocol can be used to implement custom protocols, analytics, cache profiling and other stuff
// We can create a subclass that intercepts our request and return our stubbed responses.

// abstractions in tests allow for easy refactoring, like replacing a type with a type extension
