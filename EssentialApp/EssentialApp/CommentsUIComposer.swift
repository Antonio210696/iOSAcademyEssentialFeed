//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Antonio Epifani on 01/07/23.
//

import UIKit
import EssentialFeed
import Combine
import EssentialFeediOS

public final class CommentsUIComposer {
	private init() { }
	
	private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
	
	public static func commentsComposedWith(
		commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
	) -> ListViewController {
		let presentationAdapter = CommentsPresentationAdapter(loader: { commentsLoader().dispatchOnMainQueue() })
		
		let commentsController = makeCommentsViewController(title: ImageCommentsPresenter.title)
		commentsController.onRefresh = presentationAdapter.loadResource
		
		presentationAdapter.presenter = LoadResourcePresenter(
			resourceView: CommentsViewAdapter(controller: commentsController),
			errorView: WeakRefVirtualProxy(commentsController),
			loadingView: WeakRefVirtualProxy(commentsController),
			mapper: { ImageCommentsPresenter.map($0) })
		
		return commentsController
	}
	
	
	private static func makeCommentsViewController(title: String) -> ListViewController {
		let bundle = Bundle(for: ListViewController.self)
		let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
		let feedController = storyboard.instantiateInitialViewController() as! ListViewController
		feedController.title = title
		
		return feedController
	}
}

final class CommentsViewAdapter: ResourceView {
	private weak var controller: ListViewController?
	
	init(controller: ListViewController) {
		self.controller = controller
	}
	
	func display(_ viewModel: ImageCommentsViewModel) {
		controller?.display(viewModel.comments.map { viewModel in
			CellController(id: viewModel, ImageCommentCellController(model: viewModel))
		})
	}
}
