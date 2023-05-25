//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 25/05/23.
//

import Foundation
import EssentialFeed

final class FeedImageDataLoaderSpy: FeedImageDataLoader {
	typealias Completion = (FeedImageDataLoader.Result) -> Void
	private var messages = [(url: URL, completion: Completion)]()
	
	var loadedURLs: [URL] {
		messages.map { $0.url }
	}
	var completions: [Completion] {
		messages.map { $0.completion }
	}
	
	var cancelledURLs = [URL]()
	
	private struct Task: FeedImageDataLoaderTask {
		let callback: () -> Void
		func cancel() { callback() }
	}
	
	func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
		messages.append((url: url, completion: completion))
		return Task() { [weak self] in
			self?.cancelledURLs.append(url)
		}
	}
	
	func completeSuccessfully(with image: Data, at index: Int = 0) {
		completions[index](.success(image))
	}
	
	func complete(with error: NSError, at index: Int = 0) {
		completions[index](.failure(error))
	}
}
