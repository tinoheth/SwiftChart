//
//  Scale.swift
//  SwiftChart
//
//  Created by Tino Heth on 25.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import Foundation

public class Scale {
	public func transformValue(value: ValueType, offset: ValueType = 0) -> CGFloat {
		return CGFloat(value - offset)
	}

	public func transformCoordinate(coordiante: CGFloat, offset: ValueType) -> ValueType {
		return offset + ValueType(coordiante)
	}

	public var isLinear: Bool {
		return true
	}
}

public class ResizedScale: Scale {
	public let factor: ValueType

	public init(factor: ValueType = 1) {
		self.factor = factor
	}

	override public func transformValue(value: ValueType, offset: ValueType = 0) -> CGFloat {
		return CGFloat((value - offset) * factor)
	}

	override public func transformCoordinate(coordiante: CGFloat, offset: ValueType) -> ValueType {
		return offset + ValueType(coordiante) / factor
	}
}