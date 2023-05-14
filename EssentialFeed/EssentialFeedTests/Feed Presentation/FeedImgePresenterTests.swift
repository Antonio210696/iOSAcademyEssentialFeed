import XCTest
import EssentialFeed

final class FeedImagePresenter<View: FeedImageView, Image> where Image == View.Image {
	
	private let imageView: View
	private let imageDataTransformer: (Data) -> Image?
	
	private struct InvalidDataImageError: Error { }
	
	init(imageView: View, imageDataTransformer: @escaping (Data) -> Image?) {
		self.imageView = imageView
		self.imageDataTransformer = imageDataTransformer
	}
	
	func didStartLoadingImageData(for: FeedImage) {
		imageView.display(FeedImageViewModel(
			isLoading: true,
			shouldRetry: false,
			image: nil))
	}
	
	func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
		guard let image = imageDataTransformer(data) else {
			return didFinishLoadingImageData(with: InvalidDataImageError(), for: model)
		}
		
		imageView.display(FeedImageViewModel(
			isLoading: false,
			shouldRetry: false,
			image: image))
	}
	
	func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
		imageView.display(FeedImageViewModel(isLoading: false, shouldRetry: true, image: nil))
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
		
		XCTAssertEqual(view.messages, [.display(isLoading: true, image: nil, shouldRetry: false)])
	}
	
	func test_didFinishLoadingImageData_showsRetryActionOnInvalidData() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingImageData(with: anyInvalidData(), for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(
			isLoading: false,
			image: nil,
			shouldRetry: true)
		])
	}
	
	func test_didFinishLoadingImageData_showsRetryActionOnError() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingImageData(with: anyNSError(), for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(
			isLoading: false,
			image: nil,
			shouldRetry: true)
		])
	}
	
	func test_didFinishLoadingImageData_showsImageWithNoError() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingImageData(with: anyData(), for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(
			isLoading: false,
			image: FakeImage(data: anyData()),
			shouldRetry: false)
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> (sut: FeedImagePresenter<ViewSpy, FakeImage>, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter(imageView: view) { data in
			guard data != self.anyInvalidData() else { return nil }
			
			return FakeImage(data: data)
		}
		
		return (sut, view)
	}
	
	private func anyData() -> Data {
		return Data("Test data".utf8)
	}
	
	private func anyInvalidData() -> Data {
		return Data("Test invalid data".utf8)
	}
	
	private final class ViewSpy: FeedImageView {
		private(set) var messages: [Message] = []
		
		enum Message: Equatable {
			case display(isLoading: Bool, image: FakeImage?, shouldRetry: Bool)
		}
		
		func display(_ model: FeedImageViewModel<FakeImage>) {
			messages.append(.display(
				isLoading: model.isLoading,
				image: model.image,
				shouldRetry: model.shouldRetry))
		}
	}
	
	private struct FakeImage: Equatable {
		let data: Data
	}
}
