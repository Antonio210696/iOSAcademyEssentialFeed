//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 11/05/23.
//

import UIKit

extension UIRefreshControl {
	func update(isRefreshing: Bool) {
		isRefreshing ? beginRefreshing() : endRefreshing()
	}
}
