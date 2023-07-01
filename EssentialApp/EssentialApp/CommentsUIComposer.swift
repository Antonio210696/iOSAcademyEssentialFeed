//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 01/07/23.
//

import UIKit
import EssentialFeed
import Combine
import EssentialFeediOS

public final class CommentsUIComposer {
	private init() { }
	
	public static func commentsComposedWith(
		commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>
	) -> ListViewController {
		let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: { commentsLoader().dispatchOnMainQueue() })
		
		let feedController = makeFeedViewControllerWith(title: FeedPresenter.title)
		feedController.onRefresh = presentationAdapter.loadResource
		
		presentationAdapter.presenter = LoadResourcePresenter(
			resourceView: FeedViewAdapter(
				controller: feedController,
				imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
			errorView: WeakRefVirtualProxy(feedController),
			loadingView: WeakRefVirtualProxy(feedController),
			mapper: FeedPresenter.map)
		
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
