//
//  ChartView.swift
//  SwiftChart
//
//  Created by Tino Heth on 23.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import UIKit

public class ChartView: UIView {
	static let defaultRange = ValueRange(min: 0, max: 1)

	let chartsLayer = CAScrollLayer()

	private(set) public lazy var abscissa: Abscissa = Abscissa(chartView: self)
	private(set) public lazy var ordinate: Ordinate = Ordinate(chartView: self, rangeAccessor: AbstractLineChart.getYRange)

	func setup() {
		transform = CGAffineTransformMakeScale(1, -1)
		layer.addSublayer(chartsLayer)
		layer.addSublayer(abscissa.layer)
		layer.addSublayer(ordinate.layer)
		let translate = CATransform3DMakeTranslation(leftMargin, bottomMargin, 0)
		chartsLayer.anchorPoint = CGPoint.zero
		chartsLayer.transform = translate
		chartsLayer.masksToBounds = false
		abscissa.layer.anchorPoint = CGPoint.zero
		abscissa.layer.transform = translate
		ordinate.layer.transform = translate
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
		abscissa.size = w
		ordinate.size = h
		chartsLayer.frame = CGRect(x: leftMargin, y: bottomMargin, width: w, height: h)
		abscissa.layer.frame = CGRect(x: leftMargin, y: bottomMargin, width: w, height: bottomMargin)
		refreshCharts()
		layoutGraphs()
	}

	public func blockRefresh(@noescape block: ChartView -> Void) -> Self {
		block(self)
		layoutGraphs()
		return self
	}
	
	func layoutGraphs() {
		// Fast and suited for animation... don't need those now ;-)
		//let p = CGPoint(x: xScale.transformValue(0, offset: mXRange.value.min) * xFactor, y: yScale.transformValue(0, offset: mYRange.value.min) * yFactor)
		//chartsLayer.position = p
		//abscissa.layer.position = p
		abscissa.drawAxis()
		refreshCharts()
		//drawAxis()
	}

	public func addLineChart(chart: AbstractLineChart) {
		lineCharts.append(chart)

		abscissa.update(chart)
		ordinate.update(chart)
		let chartLayer = fillLayer(CAShapeLayer(), chart: chart)

		chartsLayer.addSublayer(chartLayer)
		chartLayers.append(chartLayer)
	}

	func refreshCharts() {
		for i in 0..<lineCharts.count {
			fillLayer(chartLayers[i], chart: lineCharts[i])
		}
	}

	//MARK:- Internal stuff

	func translateValuePoint(p: Point) -> CGPoint {
		return CGPoint(x: abscissa.transformValue(p.x), y: ordinate.transformValue(p.y))
	}

	func fillLayer(chartLayer: CAShapeLayer, chart: AbstractLineChart) -> CAShapeLayer {
		var points = chart.pointsInRange(xMin: abscissa.range.value.min, xMax: abscissa.range.value.max)

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
