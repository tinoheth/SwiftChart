//
//  LineChart.swift
//  SwiftChart
//
//  Created by Tino Heth on 23.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import Foundation

public struct ChartAppearance {
	var color: UIColor
}

public struct Point {
	public var x: ValueType
	public var y: ValueType

	public init(x: ValueType, y: ValueType) {
		self.x = x
		self.y = y
	}
}

public class AbstractLineChart {
	//public let appearance: ChartAppearance? = nil

	public func yValueAtXPosition(x: ValueType, hint: Any? = nil) -> (ValueType, Any?) {
		return (value: x, hint)
	}

	public func pointsInRange(xMin xMin: ValueType, xMax: ValueType) -> [Point] {
		return []
	}

	var xRange: ValueRange {
		return ValueRange(min: .infinity, max: -.infinity)
	}

	var yRange: ValueRange {
		return ValueRange(min: .infinity, max: -.infinity)
	}
}

public class LineChart: AbstractLineChart {

	private var points = [Point]()

	override public init() {}

	public func insertPoint(p: Point) -> Self {
		points.append(p) // TODO: Order?
		cachedYRange.min = min(cachedYRange.min, p.y)
		cachedYRange.max = max(cachedYRange.max, p.y)
		return self
	}

	override public func pointsInRange(xMin xMin: ValueType, xMax: ValueType) -> [Point] {
		return points
	}

	override var xRange: ValueRange {
		guard let first = points.first, let last = points.last else {
			return super.xRange
		}
		return ValueRange(min: first.x, max: last.x)
	}

	var cachedYRange: ValueRange = ValueRange(min: .infinity, max: -.infinity)
	override var yRange: ValueRange {
		return cachedYRange
	}
}
