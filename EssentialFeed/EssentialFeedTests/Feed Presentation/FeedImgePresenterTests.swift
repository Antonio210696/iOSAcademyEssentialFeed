import XCTest

final class FeedImagePresenter {
	
}

protocol FeedImageView { }

final class FeedImagePresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertEqual(view.messages, [])
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> (sut: FeedImagePresenter, view: ViewSpy) {
		let sut = FeedImagePresenter()
		let view = ViewSpy()
		
		return (sut, view)
	}
	
	private final class ViewSpy: FeedImageView {
		private(set) var messages: [Message] = []
		
		enum Message: Equatable {
			
		}
	}
}
