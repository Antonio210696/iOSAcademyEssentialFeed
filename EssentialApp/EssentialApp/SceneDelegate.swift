//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 14/05/23.
//

import UIKit
import CoreData
import EssentialFeed
import Combine
import EssentialFeedAPI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()
	
	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()
	
	private lazy var store: FeedStore & FeedImageDataStore = {
		try! CoreDataFeedStore(storeURL: NSPersistentContainer
		.defaultDirectoryURL()
		.appendingPathComponent("feed-store.sqlite"))
	}()
	
	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
		self.init()
		self.httpClient = httpClient
		self.store = store
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let scene = (scene as? UIWindowScene) else { return }
		
		window = UIWindow(windowScene: scene)
		configureWindow()
	}
	
	func configureWindow() {
		let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
		
		let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
		let localImageLoader = LocalFeedImageDataLoader(store: store)
		
		window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
			feedLoader: makeRemoteFeedLoaderwithLocalFallback,
			imageLoader: FeedImageDataLoaderWithFallbackComposite(
				primary: localImageLoader,
				fallback: FeedImageDataLoaderCacheDecorator(
					decoratee: remoteImageLoader,
					cache: localImageLoader))))
		window?.makeKeyAndVisible()
		
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
	
	private func makeRemoteFeedLoaderwithLocalFallback() -> FeedLoader.Publisher {
		let remote = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		let remoteFeedLoader = RemoteFeedLoader(url: remote, client: httpClient)
		
		return remoteFeedLoader.loadPublisher()
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
	}
}

extension FeedLoader {
	public typealias Publisher = AnyPublisher<[FeedImage], Error>
	
	public func loadPublisher() -> Publisher {
		return Deferred {
			Future(self.load)
		}
		.eraseToAnyPublisher()
	}
}

extension Publisher where Output == [FeedImage] {
	func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
		handleEvents(receiveOutput: cache.saveIgnoringResult)
		.eraseToAnyPublisher()
	}
}

extension Publisher {
	func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
		self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
	}
}
