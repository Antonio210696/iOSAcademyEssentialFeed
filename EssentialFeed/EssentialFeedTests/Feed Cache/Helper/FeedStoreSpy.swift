//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 19/04/23.
//

import EssentialFeed

class FeedStoreSpy: FeedStore {
	enum ReceivedMessage: Equatable {
		case deleteCachedFeed
		case insert([LocalFeedImage], Date)
		case retrieve
	}
	
	private(set) var receivedMessages = [ReceivedMessage]()
	
	private var deletionCompletions = [DeletionCompletion]()
	private var insertionCompletions = [InsertionCompletion]()
	private var retrievalCompletions = [RetrievalCompletion]()
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		receivedMessages.append(.retrieve)
		retrievalCompletions.append(completion)
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		deletionCompletions.append(completion)
		receivedMessages.append(.deleteCachedFeed)
	}
	
	func completeDeletion(with error: Error, at index: Int = 0) {
		deletionCompletions[index](.failure(error))
	}
	
	func completeDeletionSuccessfully(at index: Int = 0) {
		deletionCompletions[index](.success(Void()))
	}
	
	func completeInsertion(with error: Error, at index: Int = 0) {
		insertionCompletions[index](.failure(error))
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		insertionCompletions.append(completion)
		receivedMessages.append(.insert(feed, timestamp))
	}
	
	func completeInsertionSuccessfully(at index: Int = 0) {
		insertionCompletions[index](.success(Void()))
	}
	
	func completeRetrieval(with error: Error, at index: Int = 0) {
		retrievalCompletions[index](.failure(error))
	}
	
	func completeRetrievalWithEmptyCache(at index: Int = 0) {
		retrievalCompletions[index](.success(.none))
	}
	
	func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
		retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
	}
}
