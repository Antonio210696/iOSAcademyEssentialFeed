//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 29/04/23.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
	func didRequestFeedRefresh()
}

public protocol CellController {
	func view(in: UITableView) -> UITableViewCell
	func preload()
	func cancelLoad()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
	
	@IBOutlet private(set) public var errorView: ErrorView?
	
	private var loadingControllers = [IndexPath: CellController]()
	
	var tableModel = [CellController]() {
		didSet { tableView.reloadData() }
	}
	
	public var delegate: FeedViewControllerDelegate?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		refresh()
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		tableView.sizeTableHeaderToFit()
	}
	
	public func display(_ viewModel: ResourceLoadingViewModel) {
		refreshControl?.update(isRefreshing: viewModel.isLoading)
	}
	
	public func display(_ cellControllers: [CellController]) {
		loadingControllers = [:]
		tableModel = cellControllers
	}
	
	public func display(_ viewModel: ResourceErrorViewModel) {
		errorView?.message = viewModel.message
	}
	
	@IBAction private func refresh() {
		delegate?.didRequestFeedRefresh()
	}
	
	public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableModel.count
	}
	
	public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return cellController(forRowAt: indexPath).view(in: tableView)
	}
	
	public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard tableModel.count > indexPath.row else { return }
		
		cancelCellControllerLoad(forRowAt: indexPath)
	}
	
	public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { indexPath in
			cellController(forRowAt: indexPath).preload()
		}
	}
	
	public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach(cancelCellControllerLoad)
	}
	
	private func cellController(forRowAt indexPath: IndexPath) -> CellController {
		let controller = tableModel[indexPath.row]
		loadingControllers[indexPath] = controller
		return controller
	}
	
	private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
		loadingControllers[indexPath]?.cancelLoad()
		loadingControllers[indexPath] = nil
	}
}
