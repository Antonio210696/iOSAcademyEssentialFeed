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

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
		
		let remote = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
		
		let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
		let remoteFeedLoader = RemoteFeedLoader(url: remote, client: remoteClient)
		let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
		
		window?.rootViewController = FeedUIComposer.feedComposedWith(
			feedLoader: remoteFeedLoader,
			imageLoader: remoteImageLoader)
	}
}

