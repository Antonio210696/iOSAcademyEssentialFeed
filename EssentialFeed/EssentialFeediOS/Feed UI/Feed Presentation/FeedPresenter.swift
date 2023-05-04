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

protocol FeedView {
	func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
	private var feedView: FeedView
	private var loadingView: FeedLoadingView
	
	init(feedView: FeedView, loadingView: FeedLoadingView) {
		self.feedView = feedView
		self.loadingView = loadingView
	}
	
	static var title: String {
		return NSLocalizedString(
			"FEED_VIEW_TITLE",
			tableName: "Feed",
			bundle: Bundle(for: FeedPresenter.self),
			comment: "Title for the feed view")
	}
	
	func didStartLoadingFeed() {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { [weak self] in
				self?.didStartLoadingFeed()
			}
		}
		
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	func didFinishLoadingFeed(with feed: [FeedImage]) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { [weak self] in
				self?.didStartLoadingFeed()
			}
		}
		
		feedView.display(FeedViewModel(feed: feed))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	func didFinishLoadingFeed(with error: Error) {
		guard Thread.isMainThread else {
			return DispatchQueue.main.async { [weak self] in
				self?.didStartLoadingFeed()
			}
		}
		
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
}
