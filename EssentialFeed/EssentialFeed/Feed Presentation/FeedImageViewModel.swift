//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 14/05/23.
//

import Foundation

public struct FeedImageViewModel<Image> {
	public init(
		isLoading: Bool,
		shouldRetry: Bool,
		image: Image?,
		description: String?,
		location: String?
	) {
		self.isLoading = isLoading
		self.shouldRetry = shouldRetry
		self.image = image
		self.description = description
		self.location = location
	}
	
	public let isLoading: Bool
	public let shouldRetry: Bool
	public let image: Image?
	public let description: String?
	public let location: String?
	
	public var hasLocation: Bool {
		return location != nil
	}
}

extension FeedImageViewModel: Equatable where Image: Equatable { }