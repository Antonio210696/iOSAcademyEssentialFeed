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

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
		
	}
	
	func configureWindow() {
		let remote = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		
		let remoteClient = makeRemoteClient()
		let remoteFeedLoader = RemoteFeedLoader(url: remote, client: remoteClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
		
		let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
		let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
		let localImageLoader = LocalFeedImageDataLoader(store: localStore)
		
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
		return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}
}

