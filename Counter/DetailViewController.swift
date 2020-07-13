//
//  DetailViewController.swift
//  Counter
//
//  Created by Akaash Venkat on 7/7/20.
//  Copyright © 2020 Akaash Venkat. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

	@IBOutlet weak var countTitleLabel: UILabel!
	@IBOutlet weak var countHeaderLabel: UILabel!
	@IBOutlet weak var countLabel: UILabel!
	@IBOutlet weak var subtractButton: UIButton!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var resetButton: UIButton!
	
	@IBAction func subtractButton(_ sender: Any) {
		if let detail = detailItem {
			detail.counterVal -= 1
		}
		updateCountLabel()
	}
	
	@IBAction func addButton(_ sender: Any) {
		if let detail = detailItem {
			detail.counterVal += 1
		}
		updateCountLabel()
	}
	
	@IBAction func resetButton(_ sender: Any) {
		if let detail = detailItem {
			detail.counterVal = 0
		}
		updateCountLabel()
	}
	
	func updateCountLabel() -> Void {
		var count = Int64(-1)
		if let detail = detailItem {
			count = detail.counterVal
			
			if let label = countLabel {
				label.text = String(count)
			}
			if let label = countTitleLabel {
				label.text = detail.counterTitle
			}
		}
		
		if (count != 0) {
			if let button = subtractButton {
				button.isEnabled = true
				button.alpha = 1.0
			}
		} else {
			if let button = subtractButton {
				button.isEnabled = false
				button.alpha = 0.5
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			if self.traitCollection.userInterfaceStyle == .dark {
				self.view.backgroundColor = UIColor.black
				self.countTitleLabel.textColor = UIColor.white
				self.countHeaderLabel.textColor = UIColor.white
				self.countLabel.textColor = UIColor.systemGreen
				self.subtractButton.backgroundColor = UIColor.black
				self.subtractButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
				self.addButton.backgroundColor = UIColor.black
				self.addButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
				self.resetButton.backgroundColor = UIColor.black
				self.resetButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
			} else {
				self.view.backgroundColor = UIColor.white
				self.countTitleLabel.textColor = UIColor.black
				self.countHeaderLabel.textColor = UIColor.black
				self.countLabel.textColor = UIColor.blue
				self.subtractButton.backgroundColor = UIColor.white
				self.subtractButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
				self.addButton.backgroundColor = UIColor.white
				self.addButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
				self.resetButton.backgroundColor = UIColor.white
				self.resetButton.setTitleColor(UIColor.red, for: UIControl.State.normal)
			}
		}
		
		updateCountLabel()
	}

	var detailItem: Event? {
		didSet {
			updateCountLabel()
		}
	}

}

