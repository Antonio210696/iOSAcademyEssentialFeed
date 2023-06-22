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
	}
	
	func test_feedWithFailedImageLoading() {
		let sut = makeSUT()
		
		sut.display(feedWithFailedImageLoading())
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
	}
	
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


