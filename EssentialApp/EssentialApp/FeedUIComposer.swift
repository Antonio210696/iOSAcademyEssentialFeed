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
	
	public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
		let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
		
		let feedController = makeFeedViewControllerWith(
			delegate: presentationAdapter,
			title: FeedPresenter.title)
		
		presentationAdapter.presenter = FeedPresenter(
			feedView: FeedViewAdapter(
				controller: feedController,
				imageLoader: { imageLoader($0).dispatchOnMainQueue() }),
			errorView: WeakRefVirtualProxy(feedController),
			loadingView: WeakRefVirtualProxy(feedController)
		)
		
		return feedController
	}
	
	
	private static func makeFeedViewControllerWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
		feedController.delegate = delegate
		feedController.title = title
		
		return feedController
	}
}
