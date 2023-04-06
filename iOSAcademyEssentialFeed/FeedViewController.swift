//
//  FeedViewController.swift
//  iOSAcademyEssentialFeed
//
//  Created by Antonio Epifani on 04/04/23.
//

import UIKit
// Feed Module

typealias FeedItem = String

// protocols with one method can always be replaced with a closure
protocol FeedLoader {
	func loadFeed(completion: @escaping ([FeedItem]) -> Void)
}

class FeedViewController: UIViewController {
	var loader: FeedLoader!
	
	convenience init(loader: FeedLoader) {
		self.init()
		self.loader = loader
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		loader.loadFeed { loadedItems in
			
		}
	}
}

class RemoteFeedLoader: FeedLoader {
	func loadFeed(completion: @escaping ([FeedItem]) -> Void) {
		// do soth
	}
}

class LocalFeedLoader: FeedLoader {
	func loadFeed(completion: @escaping ([FeedItem]) -> Void) {
		// do somehting
	}
}

struct Reachability {
	static let networkAvailable = false
}

class RemoteWithLocalFallbackFeedLoader: FeedLoader {
	let remote: RemoteFeedLoader
	let local: LocalFeedLoader
	
	init(remote: RemoteFeedLoader, local: LocalFeedLoader) {
		self.remote = remote
		self.local = local
	}
	
	func loadFeed(completion: @escaping ([FeedItem]) -> Void) {
		let load = Reachability.networkAvailable
		? remote.loadFeed
		: local.loadFeed
		load(completion)
	}
}

let vc = FeedViewController(loader: RemoteFeedLoader())
let vc2 = FeedViewController(loader: LocalFeedLoader())
let vc3 = FeedViewController(loader: RemoteWithLocalFallbackFeedLoader(
	remote: RemoteFeedLoader(),
	local: LocalFeedLoader()))


// Initial contract can be set initially to start working independently.  
