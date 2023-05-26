//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 14/05/23.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	let localStoreURL = NSPersistentContainer
		.defaultDirectoryURL()
		.appendingPathComponent("feed-store.sqlite")
	
	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()
	
	private lazy var store: FeedStore & FeedImageDataStore = {
		try! CoreDataFeedStore(storeURL: localStoreURL)
	}()
	
	convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
		self.init()
		self.httpClient = httpClient
		self.store = store
	}

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
		
	}
	
	func configureWindow() {
		let remote = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		
		let remoteClient = makeRemoteClient()
		let remoteFeedLoader = RemoteFeedLoader(url: remote, client: remoteClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
		
		let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
		let localImageLoader = LocalFeedImageDataLoader(store: store)
		
		window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
			feedLoader: FeedLoaderWithFallbackComposite(
				primary: FeedLoaderCacheDecorator(
					decoratee: remoteFeedLoader,
					cache: localFeedLoader),
				fallback: localFeedLoader),
			imageLoader: FeedImageDataLoaderWithFallbackComposite(
				primary: remoteImageLoader,
				fallback: FeedImageDataLoaderCacheDecorator(
					decoratee: remoteImageLoader,
					cache: localImageLoader))))
		
	}
	
	func makeRemoteClient() -> HTTPClient {
		return httpClient
	}
}

