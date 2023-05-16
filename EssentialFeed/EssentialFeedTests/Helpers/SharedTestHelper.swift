//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 20/04/23.
//

import Foundation

func anyNSError() -> NSError {
	return NSError(domain: "Any error", code: 0)
}

func anyURL() -> URL {
	return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
	return Data("any data".utf8)
}

