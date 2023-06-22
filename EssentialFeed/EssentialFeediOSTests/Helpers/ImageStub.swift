//
//  ImageStub.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 22/06/23.
//

import EssentialFeediOS
import EssentialFeed
import UIKit

class ImageStub: FeedImageCellControllerDelegate {
	weak var controller: FeedImageCellController?
	let image: UIImage?
	let viewModel: FeedImageViewModel
	
	init(description: String?, location: String?, image: UIImage?) {
		self.viewModel = FeedImageViewModel(
			description: description,
			location: location)
		self.image = image
	}
	
	func didRequestImage() {
		controller?.display(ResourceLoadingViewModel(isLoading: false))
		
		if let image {
			controller?.display(image)
			controller?.display(ResourceErrorViewModel(message: .none))
		} else {
			controller?.display(ResourceErrorViewModel(message: "any"))
		}
	}
	
	func didCancelImageRequest() { }
}
