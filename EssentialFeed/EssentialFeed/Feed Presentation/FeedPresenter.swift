//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 12/05/23.
//

import Foundation

public struct FeedErrorViewModel {
	public let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
	
	static func error(message: String) -> FeedErrorViewModel {
		return FeedErrorViewModel(message: message)
	}
}

public struct FeedLoadingViewModel {
	public let isLoading: Bool
	public var lastUpdated: String?
}

public struct FeedViewModel {
	public let feed: [FeedImage]
}

public protocol FeedLoadingView: AnyObject {
	func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

public protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
	private let errorView: FeedErrorView
	private let loadingView: FeedLoadingView
	private let feedView: FeedView
	
	public init(feedView: FeedView, errorView: FeedErrorView, loadingView: FeedLoadingView) {
		self.feedView = feedView
		self.errorView = errorView
		self.loadingView = loadingView
	}
	
	private var feedLoadError: String {
		return NSLocalizedString(
			"FEED_VIEW_CONNECTION_ERROR",
			tableName: "Feed",
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
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoadingFeed(with feed: [FeedImage]) {
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoadingFeed(with error: Error) {
		loadingView.display(FeedLoadingViewModel(isLoading: false))
		errorView.display(.error(message: feedLoadError))
	}
}

