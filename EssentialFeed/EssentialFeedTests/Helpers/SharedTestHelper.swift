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

func makeItemJson(_ items: [[String: Any]]) -> Data {
	let itemsJSON = ["items": items]
	return try! JSONSerialization.data(withJSONObject: itemsJSON)
}

extension HTTPURLResponse {
	convenience init(statusCode: Int) {
		self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
	}
}

extension Date {
	func adding(seconds: TimeInterval) -> Date {
		return self + seconds
	}
	
	func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .day, value: days, to: self)!
	}
	
	func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
		return calendar.date(byAdding: .minute, value: minutes, to: self)!
	}
}
