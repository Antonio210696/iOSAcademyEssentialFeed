//
//  ResourceLoadingView.swift
//  EssentialFeed
//
//  Created by Antonio Epifani on 16/06/23.
//

public protocol ResourceLoadingView: AnyObject {
	func display(_ viewModel: ResourceLoadingViewModel)
}
