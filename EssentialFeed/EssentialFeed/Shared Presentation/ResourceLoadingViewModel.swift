//
//  ResourceLoadingViewModel.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 16/06/23.
//

public struct ResourceLoadingViewModel {
	public let isLoading: Bool
	public var lastUpdated: String?
	
	public init(isLoading: Bool, lastUpdated: String? = nil) {
		self.isLoading = isLoading
		self.lastUpdated = lastUpdated
	}
}
