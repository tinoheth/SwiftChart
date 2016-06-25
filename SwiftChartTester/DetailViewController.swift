//
//  DetailViewController.swift
//  SwiftChartTester
//
//  Created by Tino Heth on 23.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import UIKit
import SwiftChart

class DetailViewController: UIViewController {

	@IBOutlet weak var detailDescriptionLabel: UILabel!
	@IBOutlet weak var chartView: ChartView!

	var detailItem: AnyObject? {
		didSet {
		    // Update the view.
		    self.configureView()
		}
	}

	func configureView() {
		// Update the user interface for the detail item.
		if let detail = self.detailItem {
		    if let label = self.detailDescriptionLabel {
		        label.text = detail.description
		    }
		}

		let chart = LineChart()
		for i in 0...100 {
			let x = Double(i)
			chart.insertPoint(Point(x: x, y: i == 50 ? 0 : x*x))
		}

		chartView.addLineChart(chart)

		//NSOperationQueue().addOperationWithBlock(self.queueTest)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}

	var xStart: Double = 0
	var xRange: Double = 100

	@IBAction func zoomOut(sender: AnyObject) {
		xRange *= 1.2
		chartView.xRange = ValueRange(min: xStart, max: xStart + xRange)
	}

	@IBAction func zoomIn(sender: AnyObject) {
		xRange /= 1.2
		chartView.xRange = ValueRange(min: xStart, max: xStart + xRange)
	}

	@IBAction func moveLeft(sender: AnyObject) {
		xStart -= 25
		chartView.xRange = ValueRange(min: xStart, max: xStart + xRange)
	}

	@IBAction func moveRight(sender: AnyObject) {
		xStart += 25
		chartView.xRange = ValueRange(min: xStart, max: xStart + xRange)
	}
}
