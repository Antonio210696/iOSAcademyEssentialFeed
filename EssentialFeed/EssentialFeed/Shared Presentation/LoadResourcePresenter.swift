//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 14/06/23.
//

import Foundation

public protocol ResourceView {
	associatedtype ResourceViewModel
	
	func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
	public typealias Mapper = (Resource) -> View.ResourceViewModel
	
	private let errorView: FeedErrorView
	private let loadingView: FeedLoadingView
	private let resourceView: View
	private let mapper: Mapper
	
	public init(resourceView: View, errorView: FeedErrorView, loadingView: FeedLoadingView, mapper: @escaping Mapper) {
		self.resourceView = resourceView
		self.errorView = errorView
		self.loadingView = loadingView
		self.mapper = mapper
	}
	
	public static var loadError: String {
		return NSLocalizedString(
			"GENERIC_CONNECTION_ERROR",
			tableName: "Shared",
			bundle: Bundle(for: Self.self),
			comment: "Error message displayed when we can't load the resource from the server")
	}
	
	public func didStartLoading() {
		errorView.display(.noError)
		loadingView.display(FeedLoadingViewModel(isLoading: true))
	}
	
	public func didFinishLoading(with resource: Resource) {
		resourceView.display(mapper(resource))
		loadingView.display(FeedLoadingViewModel(isLoading: false))
	}
	
	public func didFinishLoading(with error: Error) {
		loadingView.display(FeedLoadingViewModel(isLoading: false))
		errorView.display(.error(message: Self.loadError))
	}
}
