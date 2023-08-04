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
	
	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}
	func simulateErrorViewTap() {
		errorView.simulateTap()
	}
	
	var errorMessage: String? {
		return errorView.message
	}
	
}

// MARK: Comment specific DSLs
extension ListViewController {
	func numberOfRenderedComments() -> Int {
		tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentSection)
	}
	
	private var commentSection: Int {
		return 0
	}
	
	func commentView(at row: Int) -> ImageCommentCell? {
		guard numberOfRenderedComments() > row else {
			return nil
		}
		
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: commentSection)
		return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
	}
	
	func commentMessage(at row: Int) -> String? {
		commentView(at: row)?.messageLabel.text
	}
	
	func commentDate(at row: Int) -> String? {
		commentView(at: row)?.dateLabel.text
	}
	
	func commentUsername(at row: Int) -> String? {
		commentView(at: row)?.usernameLabel.text
	}
}

// MARK: Feed specific DSLs
extension ListViewController {
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
	
	func simulateTapOnFeedImage(at row: Int) {
		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: feedImageSection)
		delegate?.tableView?(tableView, didSelectRowAt: index)
	}
	
	func simulateLoadMoreFeedAction() {
		guard let view = cell(row: 0, section: feedLoadMoreSection) else { return }
		
		let delegate = tableView.delegate
		let index = IndexPath(row: 0, section: feedLoadMoreSection)
		delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
	}
	
	func numberOfRenderedFeedImageViews() -> Int {
		return tableView.numberOfSections == 0 ? 0 :
		tableView.numberOfRows(inSection: feedImageSection)
	}
	
	func feedImageView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedFeedImageViews() > row else {
			return nil
		}
		
		return cell(row: row, section: feedImageSection)
	}
	
	private func cell(row: Int, section: Int) -> UITableViewCell? {
		let ds = tableView.dataSource
		let index = IndexPath(row: row, section: section)
		return ds?.tableView(tableView, cellForRowAt: index)
	}
	
	func renderedFeedImageData(at index: Int) -> Data? {
		return simulateFeedImageViewVisible(at: 0)?.renderedImage
	}
	
	private var feedImageSection: Int { 0 }
	private var feedLoadMoreSection: Int { 1 }
}
