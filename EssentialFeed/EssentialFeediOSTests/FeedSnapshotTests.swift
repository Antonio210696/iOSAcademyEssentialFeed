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
	func test_emptyFeed() {
		let sut = makeSUT()
		
		sut.display(emptyFeed())
		
		record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
	}
	
	func test_feedWithContent() {
		let sut = makeSUT()
		
		sut.display(feedWithContent())
		
		record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
	}
	
	private func makeSUT() -> FeedViewController {
		let bundle = Bundle(for: FeedViewController.self)
		let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
		let controller = storyboard.instantiateInitialViewController() as! FeedViewController
		controller.loadViewIfNeeded()
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
	
	private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
		guard let snapshotData = snapshot.pngData() else {
			XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
			return
		}
		
		let snapshotURL = URL(fileURLWithPath: String(describing: file))
			.deletingLastPathComponent()
			.appendingPathComponent("snapshots")
			.appendingPathComponent("\(name).png")
		
		do {
			try FileManager.default.createDirectory(
				at: snapshotURL.deletingLastPathComponent(),
				withIntermediateDirectories: true)
			try snapshotData.write(to: snapshotURL)
		} catch {
			XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
		}
	}
}

extension UIViewController {
	func snapshot() -> UIImage {
		let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
		return renderer.image { action in
			view.layer.render(in: action.cgContext)
		}
	}
}

private extension FeedViewController {
	func display(_ stubs: [ImageStub]) {
		let cells: [FeedImageCellController] = stubs.map { stub in
			let cellController = FeedImageCellController(delegate: stub)
			stub.controller = cellController
			return cellController
		}
		
		display(cells)
	}
}

private class ImageStub: FeedImageCellControllerDelegate {
	weak var controller: FeedImageCellController?
	let viewModel: FeedImageViewModel<UIImage>
	
	init(description: String?, location: String?, image: UIImage?) {
		viewModel = FeedImageViewModel(
			isLoading: false,
			shouldRetry: image == nil,
			image: image,
			description: description,
			location: location)
	}
	
	func didRequestImage() {
		controller?.display(viewModel)
	}
	
	func didCancelImageRequest() { }
}
