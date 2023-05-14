import XCTest
import EssentialFeed

final class FeedImagePresenter<View: FeedImageView, Image> where Image == View.Image {
	
	private let imageView: View
	
	init(imageView: View) {
		self.imageView = imageView
	}
	
	func didStartLoadingImageData(for: FeedImage) {
		imageView.display(FeedImageViewModel(
			isLoading: true,
			shouldRetry: false,
			image: nil))
	}
}

struct FeedImageViewModel<Image> {
	let isLoading: Bool
	let shouldRetry: Bool
	let image: Image?
}

protocol FeedImageView {
	associatedtype Image
	
	func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenterTests: XCTestCase {
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertEqual(view.messages, [])
	}
	
	func test_didStartLoadingImage_displaysLoadingImageAndNoRetryAction() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingImageData(for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(isLoading: true, image: nil, error: false)])
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> (sut: FeedImagePresenter<ViewSpy, FakeImage>, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter(imageView: view)
		
		return (sut, view)
	}
	
	private final class ViewSpy: FeedImageView {
		private(set) var messages: [Message] = []
		
		enum Message: Equatable {
			case display(isLoading: Bool, image: FakeImage?, error: Bool)
		}
		
		func display(_ model: FeedImageViewModel<FakeImage>) {
			messages.append(.display(
				isLoading: model.isLoading,
				image: model.image,
				error: model.shouldRetry))
		}
	}
	
	private struct FakeImage: Equatable { }
}
