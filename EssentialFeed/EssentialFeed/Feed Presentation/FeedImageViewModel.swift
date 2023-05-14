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
	
	let isLoading: Bool
	let shouldRetry: Bool
	let image: Image?
	let description: String?
	let location: String?
}

extension FeedImageViewModel: Equatable where Image: Equatable { }
