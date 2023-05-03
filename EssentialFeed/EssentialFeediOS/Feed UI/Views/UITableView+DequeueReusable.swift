//
//  UITableView+DequeueReusable.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 03/05/23.
//

import UIKit

extension UITableView {
	func dequeuReusableCell<T: UITableViewCell>() -> T {
		let identifier = String(describing: T.self)
		return dequeueReusableCell(withIdentifier: identifier) as! T
	}
}
