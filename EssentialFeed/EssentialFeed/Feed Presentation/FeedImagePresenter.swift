import Foundation

public protocol FeedImageView {
	associatedtype Image
	
	func display(_ model: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where Image == View.Image {
	
	private let imageView: View
	private let imageDataTransformer: (Data) -> Image?
	
	private struct InvalidDataImageError: Error { }
	
	public init(imageView: View, imageDataTransformer: @escaping (Data) -> Image?) {
		self.imageView = imageView
		self.imageDataTransformer = imageDataTransformer
	}
	
	public func didStartLoadingImageData(for model: FeedImage) {
		imageView.display(FeedImageViewModel(
			isLoading: true,
			shouldRetry: false,
			image: nil,
			description: model.description,
			location: model.location))
	}
	
	public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
		guard let image = imageDataTransformer(data) else {
			return didFinishLoadingImageData(with: InvalidDataImageError(), for: model)
		}
		
		imageView.display(FeedImageViewModel(
			isLoading: false,
			shouldRetry: false,
			image: image,
			description: model.description,
			location: model.location))
	}
	
	public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
		imageView.display(FeedImageViewModel(
			isLoading: false,
			shouldRetry: true,
			image: nil,
			description: model.description,
			location: model.location))
	}
}
