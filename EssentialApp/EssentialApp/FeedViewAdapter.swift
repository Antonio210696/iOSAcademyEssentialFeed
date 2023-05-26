//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 04/05/23.
//

import EssentialFeed
import EssentialFeediOS
import UIKit

final class FeedViewAdapter: FeedView {
	private weak var controller: FeedViewController?
	private let imageLoader: FeedImageDataLoader
	
	init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
		self.controller = controller
		self.imageLoader = imageLoader
	}
	
	func display(_ viewModel: FeedViewModel) {
		controller?.display(viewModel.feed.map { model in
			let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
			let view = FeedImageCellController(delegate: adapter)
			
			adapter.presenter = FeedImagePresenter(
				imageView: WeakRefVirtualProxy(view),
				imageDataTransformer: UIImage.init
			)
			
			return view
		})
	}
}
