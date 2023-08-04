//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 04/05/23.
//

import EssentialFeed
import EssentialFeediOS
import UIKit

final class FeedViewAdapter: ResourceView {
	private weak var controller: ListViewController?
	private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
	private let selection: (FeedImage) -> Void
	
	private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
	private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
	
	init(controller: ListViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
		self.controller = controller
		self.imageLoader = imageLoader
		self.selection = selection
	}
	
	func display(_ viewModel: Paginated<FeedImage>) {
		let feed: [CellController] = viewModel.items.map { model in
			let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
				imageLoader(model.url)
			})
			
			let view = FeedImageCellController(
				viewModel: FeedImagePresenter.map(model),
				delegate: adapter,
				selection: { [selection] in
					selection(model)
				}
			)
			
			adapter.presenter = LoadResourcePresenter(
				resourceView: WeakRefVirtualProxy(view),
				errorView: WeakRefVirtualProxy(view),
				loadingView: WeakRefVirtualProxy(view),
				mapper: { data in
					guard let image = UIImage(data: data) else {
						throw InvalidImageData()
					}
					return image
				})
			
			return CellController(id: model, view)
		}
		
		guard let loadMorePublisher = viewModel.loadMorePublisher else {
			controller?.display(feed)
			return
		}
		
		let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
		
		let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
		
		loadMoreAdapter.presenter = LoadResourcePresenter(
			resourceView: self,
			errorView: WeakRefVirtualProxy(loadMore),
			loadingView: WeakRefVirtualProxy(loadMore),
			mapper: { $0 })
		
		let loadMoreSection = [CellController(id: UUID(), loadMore)]
		
		controller?.display(feed, loadMoreSection)
	}
}

private struct InvalidImageData: Error { }
