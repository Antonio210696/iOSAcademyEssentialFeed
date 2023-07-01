//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 11/05/23.
//

import UIKit
import EssentialFeediOS

extension ListViewController {
	
	public override func loadViewIfNeeded() {
		super.loadViewIfNeeded()
		
		tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
	}
	
	func simulateUserInitiatedReload() {
		refreshControl?.simulatePullToRefresh()
	}
	
	@discardableResult
	func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
		return feedImageView(at: index) as? FeedImageCell
	}
	
	@discardableResult
	func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell? {
		let view = simulateFeedImageViewVisible(at: index)
		
		let delegate = tableView.delegate
		let index = IndexPath(row: index, section: feedImageSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
		return view
	}
	
	func simulateFeedImageViewNearVisible(at row: Int) {
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImageSection)
		ds?.tableView(tableView, prefetchRowsAt: [index])
	}
	
	func simulateFeedImageViewNotNearVisible(at row: Int) {
		simulateFeedImageViewNearVisible(at: row)
		
		let ds = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: feedImageSection)
		ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	
	func numberOfRenderedFeedImageViews() -> Int {
		return tableView.numberOfSections == 0 ? 0 :
		tableView.numberOfRows(inSection: feedImageSection)
	}
	
	func feedImageView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedImageViews() > row else {
			return nil
		}
		
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: feedImageSection)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	func renderedFeedImageData(at index: Int) -> Data? {
		return simulateFeedImageViewVisible(at: 0)?.renderedImage
	}
	
	func simulateErrorViewTap() {
		errorView.simulateTap()
	}
	
	var errorMessage: String? {
		return errorView.message
	}
	
	private var feedImageSection: Int {
		return 0
	}
}
