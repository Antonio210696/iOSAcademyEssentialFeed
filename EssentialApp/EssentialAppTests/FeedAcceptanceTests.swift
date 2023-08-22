//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Antonio Epifani on 26/05/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

final class FeedAcceptanceTests: XCTestCase {
	
	func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
		let feed = launch(httpClient: .online(response))
		
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
		XCTAssertTrue(feed.canLoadMoreFeed)
		
		feed.simulateLoadMoreFeedAction()
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData())
		XCTAssertTrue(feed.canLoadMoreFeed)
		
		feed.simulateLoadMoreFeedAction()
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 3)
		XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
		XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData())
		XCTAssertFalse(feed.canLoadMoreFeed)
	}
	
	func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoCnnectivity() {
		let sharedStore = InMemoryFeedStore.empty
		let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
		
		onlineFeed.simulateFeedImageViewVisible(at: 0)
		onlineFeed.simulateFeedImageViewVisible(at: 1)
		onlineFeed.simulateLoadMoreFeedAction()
		onlineFeed.simulateFeedImageViewVisible(at: 2)
		
		let offlineFeed = launch(httpClient: .offline, store: sharedStore)
		
		XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 3)
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
		XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 2), makeImageData())
	}
	
	func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
		let feed = launch(httpClient: .offline, store: .empty)
		
		XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
	}
	
	func test_onEnteringBackground_deletesExpiredFeedCache() {
		let store = InMemoryFeedStore.withExpiredFeedCache
		
		enterBackground(with: store)
		
		XCTAssertNil(store.feedCache, "Expected to delete expired cache")
	}
	
	func test_onEnteringBackground_keepsNonExpiredFeedCache() {
		let store = InMemoryFeedStore.withNonExpiredFeedCache
		
		enterBackground(with: store)
		
		XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
	}
	
	func test_onFeedImageSelection_displaysComments() {
		let comments = showCommentsForFirstImage()
		
		XCTAssertEqual(comments.numberOfRenderedComments(), 1)
		XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
	}
	
	// MARK: - Helpers
	
	private func launch(
		httpClient: HTTPClientStub = .offline,
		store: InMemoryFeedStore = .empty
	) -> ListViewController {
		let sut = SceneDelegate(httpClient: httpClient, store: store, scheduler: .immediateOnMainQueue)
		sut.window = UIWindow()
		sut.configureWindow()
		
		let nav = sut.window?.rootViewController as? UINavigationController
		return nav?.topViewController as! ListViewController
	}
	
	private func enterBackground(with store: InMemoryFeedStore) {
		let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store, scheduler: .immediateOnMainQueue)
		sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
	}
	
	private func showCommentsForFirstImage() -> ListViewController {
		let feed = launch(httpClient: .online(response(for:)), store: .empty)
		
		feed.simulateTapOnFeedImage(at: 0)
		RunLoop.current.run(until: Date())
		
		let nav = feed.navigationController
		return nav?.topViewController as! ListViewController
	}
	
	private class HTTPClientStub: HTTPClient {
		private class Task: HTTPClientTask {
			func cancel() {}
		}
		
		private let stub: (URL) -> HTTPClient.Result
		
		init(stub: @escaping (URL) -> HTTPClient.Result) {
			self.stub = stub
		}
		
		func get(from url: URL, completion: @escaping(HTTPClient.Result) -> Void) -> HTTPClientTask {
			completion(stub(url))
			return Task()
		}
		
		static var offline: HTTPClientStub {
			HTTPClientStub { _ in .failure(NSError(domain: "offline", code: 0)) }
		}
		
		static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
			HTTPClientStub { url in  .success(stub(url)) }
		}
	}
	
	private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
		private(set) var feedCache: CachedFeed?
		private var feedImageDataCache: [URL: Data] = [:]
		
		init(feedCache: CachedFeed? = nil) {
			self.feedCache = feedCache
		}
		
		func insert(_ data: Data, for url: URL) throws {
			feedImageDataCache[url] = data
		}
		
		func retrieve(completion: @escaping RetrievalCompletion) {
			completion(.success(feedCache))
		}
		
		func retrieve(dataForURL url: URL) throws -> Data? {
			return feedImageDataCache[url]
		}
		
		func deleteCachedFeed(completion: @escaping FeedStore.DeletionCompletion) {
			feedCache = nil
			completion(.success(()))
		}
		
		func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
			feedCache = CachedFeed(feed: feed, timestamp: timestamp)
			completion(.success(()))
		}
		
		static var empty: InMemoryFeedStore {
			InMemoryFeedStore()
		}
		
		static var withExpiredFeedCache: InMemoryFeedStore {
			InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
		}
		
		static var withNonExpiredFeedCache: InMemoryFeedStore {
			InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
		}
	}
	
	private func response(for url: URL) -> (Data, HTTPURLResponse) {
		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		return (makeData(for: url), response)
	}
	
	private func makeData(for url: URL) -> Data {
		switch url.path {
		case "/image-1", "/image-2", "/image-3":
			return makeImageData()
			
		case "/essential-feed/v1/feed" where url.query?.contains("after_id") == false:
			return makeFirstFeedPageData()
			
		case "/essential-feed/v1/feed" where url.query?.contains("after_id=DB256423-0359-440B-B739-05286E0D943E") == true:
			return makeSecondFeedPageData()
			
		case "/essential-feed/v1/feed" where url.query?.contains("after_id=6D133EE6-AE42-4AE6-8F13-3B470ABCF622") == true:
			return makeLastFeedPageData()
			
		case "/essential-feed/v1/image/4735ED4C-EDEB-48D4-AC7E-D0E6403BEFB4/comments":
			return makeCommentsData()
		default:
			return Data()
		}
	}
	
	private func makeImageData() -> Data {
		return UIImage.make(withColor: .red).pngData()!
	}
	
	private func makeFirstFeedPageData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "4735ED4C-EDEB-48D4-AC7E-D0E6403BEFB4", "image": "http://feed.com/image-1"],
			["id": "DB256423-0359-440B-B739-05286E0D943E", "image": "http://feed.com/image-2"]
		]])
	}
	
	private func makeSecondFeedPageData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			["id": "6D133EE6-AE42-4AE6-8F13-3B470ABCF622", "image": "http://feed.com/image-3"],
		]])
	}
	
	private func makeLastFeedPageData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": []])
	}
	
	private func makeCommentsData() -> Data {
		return try! JSONSerialization.data(withJSONObject: ["items": [
			[
				"id": UUID().uuidString,
				"message": makeCommentMessage(),
				"created_at": "2020-05-20T11:23:59+0000",
				"author": [
					"username": "a username"
				]
			],
		]])
	}
	
	private func makeCommentMessage() -> String {
		"a message"
	}
}


