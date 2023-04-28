//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 21/04/23.
//

import Foundation

final class FeedCachePolicy {
	private init() { }
	
	static private let calendar = Calendar(identifier: .gregorian)
	
	static private var maxCacheAgeInDays: Int { 7 }
	
	static func validate(_ timestamp: Date, against date: Date) -> Bool {
		guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
			return false
		}
		
		return date < maxCacheAge
	}
}
