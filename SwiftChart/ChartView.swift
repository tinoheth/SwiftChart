//
//  ChartView.swift
//  SwiftChart
//
//  Created by Tino Heth on 23.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import UIKit

enum Setting<T> {
	case userDefined(value: T)
	case generated(value: T, source: AnyClass)
}

public class ChartView: UIView {
	static let defaultRange = ValueRange(min: 0, max: 1)

	let chartsLayer = CAScrollLayer()
	let xAxisLayer = CAShapeLayer()
	let yAxisLayer = CAShapeLayer()

	public var xScale: Scale = Scale()
	public var yScale: Scale = Scale()

	var xFactor: CGFloat = 1
	var yFactor: CGFloat = 1

	public var xRange: ValueRange? {
		get {
			return mXRange.value
		}
		set(value) {
			if let value = value {
				mXRange = (value: value, origin: self)
			} else {
				mXRange = (value: ChartView.defaultRange, origin: nil)
			}
			self.layoutGraphs()
		}
	}

	public var yRange: ValueRange? {
		get {
			return mYRange.value
		}
		set(value) {
			if let value = value {
				mYRange = (value: value, origin: self)
			} else {
				mYRange = (value: ChartView.defaultRange, origin: nil)
			}
			self.layoutGraphs()
		}
	}

	func setup() {
		transform = CGAffineTransformMakeScale(1, -1)
		layer.addSublayer(chartsLayer)
		layer.addSublayer(xAxisLayer)
		layer.addSublayer(yAxisLayer)
		let translate = CATransform3DMakeTranslation(leftMargin, bottomMargin, 0)
		chartsLayer.anchorPoint = CGPoint.zero
		chartsLayer.transform = translate
		chartsLayer.masksToBounds = false
		xAxisLayer.anchorPoint = CGPoint.zero
		xAxisLayer.transform = translate
		yAxisLayer.transform = translate
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	public override func layoutSubviews() {
		let w = bounds.size.width
		let h = bounds.size.height
		chartsLayer.frame = CGRect(x: leftMargin, y: bottomMargin, width: w, height: h)
		xAxisLayer.frame = CGRect(x: leftMargin, y: bottomMargin, width: w, height: bottomMargin)
		refreshCharts()
		drawAxis()
		layoutGraphs()
	}

	func layoutGraphs() {
		xFactor = bounds.size.width / CGFloat(mXRange.value.size)
		yFactor = bounds.size.height / CGFloat(mYRange.value.size)
		// Fast and suited for animation... don't need those now ;-)
		//let p = CGPoint(x: xScale.transformValue(0, offset: mXRange.value.min) * xFactor, y: yScale.transformValue(0, offset: mYRange.value.min) * yFactor)
		//chartsLayer.position = p
		//xAxisLayer.position = p
		refreshCharts()
		drawAxis()
	}

	public func addLineChart(chart: AbstractLineChart) {
		lineCharts.append(chart)

		updateConfigurationForChart(chart)
		let chartLayer = fillLayer(CAShapeLayer(), chart: chart)

		chartsLayer.addSublayer(chartLayer)
		chartLayers.append(chartLayer)
	}

	func refreshCharts() {
		for i in 0..<lineCharts.count {
			fillLayer(chartLayers[i], chart: lineCharts[i])
		}
	}

	func updateConfigurationForChart(chart: AbstractLineChart) {
		if mXRange.origin == nil || mXRange.origin === chart {
			mXRange = (value: chart.xRange, origin: chart)
		}
		if mYRange.origin == nil || mYRange.origin === chart {
			mYRange = (value: chart.yRange, origin: chart)
		}
	}

	func drawAxis() {
		let x = UIBezierPath()
		let size = bounds.size.width
		let offset = -chartsLayer.position.x
		x.moveToPoint(CGPoint(x: offset - size, y: 0))
		x.addLineToPoint(CGPoint(x: offset + 2 * size, y: 0))

		let marks = ChartView.generateTickmarkPositions(range: mXRange.value, space: size)

		xAxisLayer.sublayers?.forEach {
			$0.removeFromSuperlayer()
		}
		for mark in marks {
			let pos = xScale.transformValue(mark, offset: mXRange.value.min) * xFactor + offset
			x.moveToPoint(CGPoint(x: pos, y: 4))
			x.addLineToPoint(CGPoint(x: pos, y: -4))

			let legend = CATextLayer()
			legend.foregroundColor = UIColor.blackColor().CGColor
			legend.string = mark.description
			legend.fontSize = 16
			legend.transform = CATransform3DMakeScale(0.5, -0.5, 1)
			legend.alignmentMode = kCAAlignmentCenter
			legend.frame = CGRect(x: pos - 32, y: -20, width: 64, height: 16)
			xAxisLayer.addSublayer(legend)
		}

		xAxisLayer.configureStroke(color: .blackColor(), lineWidth: 1)
		xAxisLayer.path = x.CGPath
	}

	static func generateTickmarkPositions(range range: ValueRange, space: CGFloat, minimalSpacing: CGFloat = 32) -> [ValueType] {
		var result = Array<ValueType>()

		let maxCount = max(1, Int(space/minimalSpacing))
		let distance = range.size / ValueType(maxCount)

		let stepFactors: [ValueType] = [5, 2]

		var step = ValueType(1)
		var stepCount = Int(0)

		if step < distance {
			while step < distance {
				step *= stepFactors[stepCount % stepFactors.count]
				stepCount += 1
			}
		}
		else {
			while step > distance {
				step /= stepFactors[stepCount % stepFactors.count]
				stepCount += 1
			}
		}

		let remainder = range.min % step

		let base = range.min - remainder
		result.append(base)
		var current = base

		var i = ValueType(1)
		while current < range.max {
			current = base + step * i
			i += 1
			result.append(current)
		}

		return result
	}

	//MARK:- Internal stuff

	func translateValuePoint(p: Point) -> CGPoint {
		return CGPoint(x: xScale.transformValue(p.x, offset: mXRange.value.min) * xFactor, y: yScale.transformValue(p.y, offset: mYRange.value.min) * yFactor)
	}

	func fillLayer(chartLayer: CAShapeLayer, chart: AbstractLineChart) -> CAShapeLayer {
		var points = chart.pointsInRange(xMin: mXRange.value.min, xMax: mXRange.value.min)

		if points.count > 1 {
			let path = UIBezierPath()
			path.moveToPoint(translateValuePoint(points.removeFirst()))
			for p in points {
				path.addLineToPoint(translateValuePoint(p))
			}
			chartLayer.configureStroke(color: .greenColor())
			chartLayer.path = path.CGPath
		} else {
			chartLayer.path = nil
		}
		return chartLayer
	}

	var bottomMargin: CGFloat = 24
	var leftMargin: CGFloat = 24

	private(set) var lineCharts = Array<AbstractLineChart>()
	private var chartLayers = Array<CAShapeLayer>()
	private var mXRange: (value: ValueRange, origin: AnyObject?) = (ChartView.defaultRange, nil) {
		didSet {
			xFactor = bounds.size.width / CGFloat(mXRange.value.size)
		}
	}
	private var mYRange: (value: ValueRange, origin: AnyObject?) = (ChartView.defaultRange, nil) {
		didSet {
			yFactor = bounds.size.width / CGFloat(mYRange.value.size)
		}
	}
}

extension CAShapeLayer {
	func configureStroke(color color: UIColor = UIColor.blackColor(), lineWidth: CGFloat = 2) -> Self {
		fillColor = nil
		self.lineWidth = lineWidth
		strokeColor = color.CGColor
		return self
	}
}

func *(a: CATransform3D, b: CATransform3D) -> CATransform3D {
	return CATransform3DConcat(a, b)
}
