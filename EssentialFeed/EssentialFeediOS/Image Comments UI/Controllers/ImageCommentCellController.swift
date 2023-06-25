//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Antonio Epifani on 22/06/23.
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: CellController {
	private let model: ImageCommentViewModel
	
	public init(model: ImageCommentViewModel) {
		self.model = model
	}
	
	public func view(in tableView: UITableView) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeuReusableCell()
		cell.messageLabel.text = model.message
		cell.usernameLabel.text = model.username
		cell.dateLabel.text = model.date
		
		return cell
	}
}
