//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 22/06/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
	func test_listWithComments() {
		let sut = makeSUT()
		
		sut.display(comments())
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "IMAGE_COMMENTS_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "IMAGE_COMMENTS_dark")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark, contentSize: .extraExtraExtraLarge)), named: "IMAGE_COMMENTS_dark_extraExtraExtraLarge")
	}
	
	
	private func makeSUT() -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! ListViewController
		controller.loadViewIfNeeded()
		controller.tableView.showsVerticalScrollIndicator = false
		controller.tableView.showsHorizontalScrollIndicator = false
		return controller
	}
	
	private func comments() -> [CellController] {
		commentControllers().map { CellController($0)}
	}
	
	private func commentControllers() -> [ImageCommentCellController] {
		return [
			ImageCommentCellController(model: ImageCommentViewModel(message: "Some description for this first image to be rendered going to write a very long text to see how the UI adapts to multiline text. This sometimes is painful but it is necessary", date: "1000 years ago", username: "a long long long username")),
			ImageCommentCellController(model: ImageCommentViewModel(message: "Some description for this first image ", date: "10 days ago", username: "a username")),
			ImageCommentCellController(model: ImageCommentViewModel(message: "nice", date: "1 hour ago", username: "a.")),
		]
	}
}
