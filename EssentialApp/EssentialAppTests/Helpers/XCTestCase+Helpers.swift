//
//  XCTestCase+Helpers.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 21/05/23.
//

import XCTest
import EssentialFeed

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
	
	func uniqueFeed() -> [FeedImage] {
		return [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "http://any-url.com")!)]
	}
	
	private class DummyView: ResourceView {
		func display(_ viewModel: Any) { }
	}
	
	var loadError: String {
		LoadResourcePresenter<Any, DummyView>.loadError
	}
	
	var feedTitle: String {
		FeedPresenter.title
	}
	
	var commentsTitle: String {
		ImageCommentsPresenter.title
	}
}
