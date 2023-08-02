//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 01/05/23.
//

import UIKit
import EssentialFeed
import Combine
import EssentialFeediOS


public final class FeedUIComposer {
	private init() { }
	private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
	
	public static func feedComposedWith(
		feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
		imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
		selection: @escaping (FeedImage) -> Void = { _ in }
	) -> ListViewController {
		let presentationAdapter = FeedPresentationAdapter(loader: { feedLoader().dispatchOnMainQueue() })
		
		let feedController = makeFeedViewControllerWith(title: FeedPresenter.title)
		feedController.onRefresh = presentationAdapter.loadResource
		
		presentationAdapter.presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				controller: feedController,
				imageLoader: { imageLoader($0).dispatchOnMainQueue() },
				selection: selection),
			errorView: WeakRefVirtualProxy(feedController),
			loadingView: WeakRefVirtualProxy(feedController),
			mapper: { $0 })
		
		return feedController
	}
	
	
	private static func makeFeedViewControllerWith(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! ListViewController
		feedController.title = title
		
		return feedController
	}
}
