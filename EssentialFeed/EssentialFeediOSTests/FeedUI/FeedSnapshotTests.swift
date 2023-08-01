//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 28/05/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedSnapshotTests: XCTestCase {
	
	func test_feedWithContent() {
		let sut = makeSUT()
		
		sut.display(feedWithContent())
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_CONTENT_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_CONTENT_dark")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_dark_extraExtraExtraLarge")
	}
	
	func test_feedWithFailedImageLoading() {
		let sut = makeSUT()
		
		sut.display(feedWithFailedImageLoading())
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
	}
	
	func test_feedWithLoadMoreIndicator() {
		let sut = makeSUT()
		
		sut.display(feedWithLoadMoreIndicator())
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
	}
	
	func test_feedWithLoadMoreError() {
		let sut = makeSUT()
		
		sut.display(feedWithLoadMoreError())
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_LOAD_MORE_ERROR_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_LOAD_MORE_ERROR_dark")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_ERROR_extraExtraExtraLarge")
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func emptyFeed() -> [FeedImageCellController] {
		return []
	}
	
	private func feedWithContent() -> [ImageStub] {
		return [
			ImageStub(
				description: "Some description for this first image to be rendered",
				location: "Lecce, somewhere",
				image: UIImage.make(withColor: .red)),
			ImageStub(
				description: "Some other description for the second image",
				location: "Bary, far away",
				image: UIImage.make(withColor: .green))
		]
	}
	
	private func feedWithLoadMoreIndicator() -> [CellController] {
		let loadMore = LoadMoreCellController()
		loadMore.display(ResourceLoadingViewModel(isLoading: true))
		
		return feedWith(loadMore: loadMore)
	}
	
	private func feedWithLoadMoreError() -> [CellController] {
		let loadMore = LoadMoreCellController()
		loadMore.display(ResourceErrorViewModel(message: "This is a multilne\nerror message"))
		
		return feedWith(loadMore: loadMore)
	}
	
	private func feedWith(loadMore: LoadMoreCellController) -> [CellController] {
		let stub = feedWithContent().last!
		let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
		stub.controller = cellController
		
		return [
			CellController(id: UUID(), cellController),
			CellController(id: UUID(), loadMore)
		]
	}
	
	private func feedWithFailedImageLoading() -> [ImageStub] {
		return [
			ImageStub(
				description: nil,
				location: "Lecce, somewhere",
				image: nil),
			ImageStub(
				description: nil,
				location: "Bary, far away",
				image: nil)
		]
	}
}


