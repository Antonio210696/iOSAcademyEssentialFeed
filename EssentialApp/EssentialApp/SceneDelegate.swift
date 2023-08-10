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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
	
	private lazy var httpClient: HTTPClient = {
		URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
	}()
	
	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: store, currentDate: Date.init)
	}()
	
	private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")
	
	private lazy var navigationController: UINavigationController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
			feedLoader: makeRemoteFeedLoaderwithLocalFallback,
			imageLoader: makeLocalImageLoaderWithRemoteFallback,
			selection: showComments))
	
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
		window?.rootViewController = navigationController
		window?.makeKeyAndVisible()
	}
	
	func sceneWillResignActive(_ scene: UIScene) {
		localFeedLoader.validateCache { _ in }
	}
	
	private func showComments(for image: FeedImage) {
		let url = ImageCommentsEndpoint.get(image).url(baseURL: baseURL!)
		let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
		navigationController.pushViewController(comments, animated: true)
	}
	
	private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
		return { [httpClient] in
			return httpClient
				.getPublisher(url: url)
				.tryMap(ImageCommentsMapper.map)
				.eraseToAnyPublisher()
		}
	}
	
	private func makeRemoteFeedLoaderwithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
		makeRemoteFeedLoader()
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
			.map(makeFirstPage)
			.eraseToAnyPublisher()
	}
	
	private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
		makeRemoteFeedLoader(after: last)
			.map { newItems in
				return (items + newItems, newItems.last)
			}
			.map(makePage)
			.caching(to: localFeedLoader)
	}
	
	private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
		makePage(items: items, last: items.last)
	}
	
	private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
		return Paginated(items: items, loadMorePublisher: last.map { last in
			{ self.makeRemoteLoadMoreLoader(items: items, last: last) }
		})
	}
	
	private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
		let url = FeedEndpoint.get(after: after).url(baseURL: baseURL!)
		
		return httpClient
				.getPublisher(url: url)
				.tryMap(FeedItemsMapper.map)
				.eraseToAnyPublisher()
	}
	
	private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
		let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
		let localImageLoader = LocalFeedImageDataLoader(store: store)
		
		return localImageLoader
			.loadImageDataPublisher(from: url)
			.fallback(to: {
				remoteImageLoader
					.loadImageDataPublisher(from: url)
					.caching(to: localImageLoader, using: url)
			})
		
	}
}

