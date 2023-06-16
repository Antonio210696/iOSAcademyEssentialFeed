//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 12/05/23.
//

import Foundation

public protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
	private let errorView: ResourceErrorView
	private let loadingView: ResourceLoadingView
	private let feedView: FeedView
	
	public init(feedView: FeedView, errorView: ResourceErrorView, loadingView: ResourceLoadingView) {
		self.feedView = feedView
		self.errorView = errorView
		self.loadingView = loadingView
	}
	
	private var feedLoadError: String {
		return NSLocalizedString(
			"GENERIC_CONNECTION_ERROR",
			tableName: "Shared",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Error message displayed when we can't load the image feed from the server")
	}
	
	public static var title: String {
		return NSLocalizedString(
			"FEED_VIEW_TITLE",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Title for the feed view")
	}
		
	public func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(ResourceLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(ResourceLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeed(with error: Error) {
		loadingView.display(ResourceLoadingViewModel(isLoading: false))
		errorView.display(.error(message: feedLoadError))
	}
}

