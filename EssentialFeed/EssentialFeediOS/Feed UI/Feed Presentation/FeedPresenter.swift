//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 01/05/23.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView: AnyObject {
	func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
	private var feedView: FeedView
	private var loadingView: FeedLoadingView
	private var errorView: FeedErrorView
	
	init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
		self.feedView = feedView
		self.loadingView = loadingView
		self.errorView = errorView
	}
	
	static var title: String {
		return NSLocalizedString(
			"FEED_VIEW_TITLE",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Title for the feed view")
	}
	
	private var feedLoadError: String {
		return NSLocalizedString(
			"FEED_VIEW_CONNECTION_ERROR",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Error message displayed when we can't load the image feed from the server")
	}
	
	func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingFeed(with feed: [FeedImage]) {
		
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingFeed(with error: Error) {
		errorView.display(.error(message: feedLoadError))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}
