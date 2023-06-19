//
//  FeedCacheTestHelper.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 20/04/23.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
	return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]) {
	let models = [uniqueImage(), uniqueImage()]
	let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
	
	return (models, local)
}

extension Date {
	func minusFeedCacheMaxAge() -> Date {
		return adding(days: -feedCacheMaxAgeInDays)
	}
	
	private var feedCacheMaxAgeInDays: Int { 7 }
	
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
