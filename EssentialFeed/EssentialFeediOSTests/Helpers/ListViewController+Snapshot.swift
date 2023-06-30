//
//  ListViewController+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Antonio Epifani on 22/06/23.
//

import Foundation
import EssentialFeediOS

extension ListViewController {
	func display(_ stubs: [ImageStub]) {
		let cells: [CellController] = stubs.map { stub in
			let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
			stub.controller = cellController
			return CellController(id: UUID(), cellController)
		}
		
		display(cells)
	}
}
