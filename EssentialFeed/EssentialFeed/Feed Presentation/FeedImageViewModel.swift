//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 14/05/23.
//

import Foundation

public struct FeedImageViewModel {
	public init(
		description: String?,
		location: String?
	) {
		self.description = description
		self.location = location
	}
	
	public let description: String?
	public let location: String?
	
	public var hasLocation: Bool {
		return location != nil
	}
}
