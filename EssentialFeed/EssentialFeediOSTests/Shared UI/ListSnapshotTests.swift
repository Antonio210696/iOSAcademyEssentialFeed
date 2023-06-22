//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 22/06/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ListSnapshotTests: XCTestCase {

	func test_emptyList() {
		let sut = makeSUT()
		
		sut.display(emptyList())
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "EMPTY_LIST_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "EMPTY_LIST_dark")
	}
	
	func test_listWithErrorMessage() {
		let sut = makeSUT()
		
		sut.display(.error(message: "This is a\nmulti-line\nerror message"))
		
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
		assert(snapshot: sut.snapshot(for: .iPhone13(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
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
	
	private func emptyList() -> [FeedImageCellController] {
		return []
	}
	
	private func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)
		let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
		
		guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
			XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
			return
		}
		
		if snapshotData != storedSnapshotData {
			let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
				.appendingPathComponent(snapshotURL.lastPathComponent)
			
			try? snapshotData?.write(to: temporarySnapshotURL)
			
			XCTFail("New snapshot does not match stored snapsht. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
		}
	}
	
	private func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
		let snapshotURL = makeSnapshotURL(named: name, file: file)
		let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
		
		do {
			try FileManager.default.createDirectory(
				at: snapshotURL.deletingLastPathComponent(),
				withIntermediateDirectories: true)
			try snapshotData?.write(to: snapshotURL)
		} catch {
			XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
		}
	}
	
	private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
		return URL(fileURLWithPath: String(describing: file))
			.deletingLastPathComponent()
			.appendingPathComponent("snapshots")
			.appendingPathComponent("\(name).png")
	}
	
	private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
		guard let data = snapshot.pngData() else {
			XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
			return nil
		}
		
		return data
	}
}
