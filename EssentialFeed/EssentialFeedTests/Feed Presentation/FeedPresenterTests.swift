//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Antonio Epifani on 12/05/23.
//

import XCTest

struct FeedErrorViewModel {
	let message: String?
	
	static var noError: FeedErrorViewModel {
		return FeedErrorViewModel(message: nil)
	}
}

struct FeedLoadingViewModel {
	let isLoading: Bool
	var lastUpdated: String?
}

protocol FeedLoadingView: AnyObject {
	func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
	private let errorView: FeedErrorView
	private let loadingView: FeedLoadingView
	
	init(errorView: FeedErrorView, loadingView: FeedLoadingView) {
		self.errorView = errorView
		self.loadingView = loadingView
	}
	
	func didStartLoadingFeed() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
}

class FeedPresenterTests: XCTestCase {
	
	func test_init_doesNotSentMessagesToView() {
		let(_, view) = makeSUT()
		
		XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
	}
	
	func test_didStartLoadingFeed_displaysNoErrorMessageAndStartsLoading() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingFeed()
		
		XCTAssertEqual(view.messages, [
			.display(errorMessage: .none),
			.display(isLoading: true)
		])
	}
	
	// MARK: - Helpers.
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedPresenter(errorView: view, loadingView: view)
		
		trackForMemoryLeaks(view, file: file, line: line)
		trackForMemoryLeaks(sut, file: file, line: line)
		
		return (sut, view)
	}
	
	private class ViewSpy: FeedErrorView, FeedLoadingView {
		func display(_ viewModel: FeedLoadingViewModel) {
			messages.append(.display(isLoading: viewModel.isLoading ))
		}
		
		func display(_ viewModel: FeedErrorViewModel) {
			messages.append(.display(errorMessage: viewModel.message))
		}
		
		enum Message: Equatable {
			case display(errorMessage: String?)
			case display(isLoading: Bool)
		}
		
		private(set) var messages = [Message]()
	}
}
