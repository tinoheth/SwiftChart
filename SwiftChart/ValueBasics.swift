//
//  ValueBasics.swift
//  SwiftChart
//
//  Created by Tino Heth on 25.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import Foundation

public typealias ValueType = Double

public struct ValueRange {
	public var min: ValueType
	public var max: ValueType

	var size: ValueType {
		return max - min
	}

	public init(min: ValueType, max: ValueType) {
		self.min = min
		self.max = max
	}

	init() {
		self.init(min: 0, max: 1)
	}
}