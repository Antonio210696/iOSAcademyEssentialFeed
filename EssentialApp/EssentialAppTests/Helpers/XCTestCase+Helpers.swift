//
//  XCTestCase+Helpers.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 21/05/23.
//

import XCTest

extension XCTestCase {
	func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 0)
	}
	
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
		}
	}
}
