import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {
	
	func test_map_createsViewModel() {
		let image = uniqueImage()
		
		let viewModel = FeedImagePresenter<ViewSpy, FakeImage>.map(image)
		
		XCTAssertEqual(viewModel.description, image.description)
		XCTAssertEqual(viewModel.location, image.location)
	}
	
	func test_init_doesNotSendMessagesToView() {
		let (_, view) = makeSUT()
		
		XCTAssertEqual(view.messages, [])
	}
	
	func test_didStartLoadingImage_displaysLoadingImageAndNoRetryActionWithCorrectImageInfo() {
		let (sut, view) = makeSUT()
		
		sut.didStartLoadingImageData(for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(FeedImageViewModel(
			isLoading: true,
			shouldRetry: false,
			image: nil,
			description: uniqueImage().description,
			location: uniqueImage().location))
		])
	}
	
	func test_didFinishLoadingImageData_showsRetryActionOnInvalidDataWithCorrectImageInfo() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingImageData(with: anyInvalidData(), for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(FeedImageViewModel(
			isLoading: false,
			shouldRetry: true,
			image: nil,
			description: uniqueImage().description,
			location: uniqueImage().location))
		])
	}
	
	func test_didFinishLoadingImageData_showsRetryActionOnErrorWithCorrectImageInfo() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingImageData(with: anyNSError(), for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(FeedImageViewModel(
			isLoading: false,
			shouldRetry: true,
			image: nil,
			description: uniqueImage().description,
			location: uniqueImage().location))
		])
	}
	
	func test_didFinishLoadingImageData_showsImageWithNoErrorWithCorrectImageInfo() {
		let (sut, view) = makeSUT()
		
		sut.didFinishLoadingImageData(with: anyData(), for: uniqueImage())
		
		XCTAssertEqual(view.messages, [.display(FeedImageViewModel(
			isLoading: false,
			shouldRetry: false,
			image: FakeImage(data: anyData()),
			description: uniqueImage().description,
			location: uniqueImage().location))
		])
	}
	
	// MARK: - Helpers
	
	private func makeSUT() -> (sut: FeedImagePresenter<ViewSpy, FakeImage>, view: ViewSpy) {
		let view = ViewSpy()
		let sut = FeedImagePresenter(imageView: view) { data in
			guard data != self.anyInvalidData() else { return nil }
			
			return FakeImage(data: data)
		}
		
		trackForMemoryLeaks(view)
		trackForMemoryLeaks(sut)
		
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
			case display(FeedImageViewModel<FakeImage>)
		}
		
		func display(_ model: FeedImageViewModel<FakeImage>) {
			messages.append(.display(model))
		}
	}
	
	private struct FakeImage: Equatable {
		let data: Data
	}
}
