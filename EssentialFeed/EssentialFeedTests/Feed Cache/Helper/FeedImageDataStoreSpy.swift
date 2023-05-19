//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 19/05/23.
//

import Foundation
import EssentialFeed

final class FeedImageDataStoreSpy: FeedImageDataStore {
	enum Message: Equatable {
		case retrieve(dataFor: URL)
		case insert(data: Data, for: URL)
	}
	
	private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
	private(set) var receivedMessages = [Message]()
	
	func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		receivedMessages.append(.retrieve(dataFor: url))
		retrievalCompletions.append(completion)
	}
	
	func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
		receivedMessages.append(.insert(data: data, for: url))
	}
	
	func completeRetrieval(with error: Error, at index: Int = 0) {
		retrievalCompletions[index](.failure(error))
	}
	
	func completeRetrieval(with data: Data?, at index: Int = 0) {
		retrievalCompletions[index](.success(data))
	}
}