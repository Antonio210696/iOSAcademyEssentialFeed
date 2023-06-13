//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 22/05/23.
//

import EssentialFeed

class FeedLoaderStub {
	private let result: Swift.Result<[FeedImage], Error>
	
	init(result: Swift.Result<[FeedImage], Error>) {
		self.result = result
	}
	
	func load(completion: @escaping (Result<[FeedImage], Error>) -> Void) {
		completion(result)
	}
}
