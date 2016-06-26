//
//  Axes.swift
//  SwiftChart
//
//  Created by Tino Heth on 26.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import Foundation

public enum Tickmarks {
	case none
	case generate(ValueRange -> [ValueType])
	case userDefined(values: [ValueType])

	public func valuesForRange(range: ValueRange) -> [ValueType] {
		switch self {
		case .none: return []
		case .userDefined(values: let values): return values
		case .generate(let generator): return generator(range)
		}
	}
}

public enum Labels {
	case none
	case generate(ValueRange -> [ValueType: String])
	case userDefined(values: [ValueType: String])
}

public class Abscissa {
	unowned let chartView: ChartView

	var size: CGFloat = 0 {
		didSet {
			factor = size / CGFloat(range.value.size)
		}
	}
	var factor: CGFloat = 1
	public let scale: Scale
	public let range: Setting<ValueRange>
	public lazy var tickmarks: Tickmarks = .generate(self.tickmarkGenerator)
	public var labels: Labels = .none
	public var lineWidth: CGFloat = 1
	public var lineColor = UIColor.blackColor()
	public var minimalLabelSpace: CGFloat = 32

	let layer = CAShapeLayer()

	public init(chartView: ChartView, scale: Scale = Scale(), rangeAccessor: (AbstractLineChart) -> ValueRange = AbstractLineChart.getXRange) {
		self.chartView = chartView
		self.scale = scale
		range = Setting {
			var result = ValueRange()
			let ranges = chartView.lineCharts.map(rangeAccessor)
			for current in ranges {
				result.merge(current)
			}
			return result
		}
	}

	private func tickmarkGenerator(range: ValueRange) -> [ValueType] {
		return Abscissa.generateTickmarkPositions(range: range, space: size, minimalSpacing: minimalLabelSpace)
	}

	public func update(chart: AbstractLineChart) {
		range.update()
	}

	public func transformValue(value: ValueType) -> CGFloat {
		return scale.transformValue(value, offset: range.value.min) * factor
	}

	func drawAxis() {
		let x = UIBezierPath()
		x.moveToPoint(CGPoint(x: -size, y: 0))
		x.addLineToPoint(CGPoint(x: 2 * size, y: 0))

		let marks = tickmarks.valuesForRange(range.value)//Abscissa.generateTickmarkPositions(range: range.value, space: size)

		layer.sublayers?.forEach {
			$0.removeFromSuperlayer()
		}
		for mark in marks {
			let pos = transformValue(mark)
			x.moveToPoint(CGPoint(x: pos, y: 4))
			x.addLineToPoint(CGPoint(x: pos, y: -4))

			let legend = CATextLayer()
			legend.foregroundColor = UIColor.blackColor().CGColor
			legend.string = mark.description
			legend.fontSize = 16
			legend.transform = CATransform3DMakeScale(0.5, -0.5, 1)
			legend.alignmentMode = kCAAlignmentCenter
			legend.frame = CGRect(x: pos - 32, y: -20, width: 64, height: 16)
			layer.addSublayer(legend)
		}

		layer.configureStroke(color: .blackColor(), lineWidth: 1)
		layer.path = x.CGPath
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
}

public class Ordinate: Abscissa {
}