//
//  Setting.swift
//  SwiftChart
//
//  Created by Tino Heth on 26.06.16.
//  Copyright © 2016 Tino Heth. All rights reserved.
//

import Foundation

/**
	The appearance of a chart should be customizable, yet it should be possible to get a nice layout without any explicit configuration.

	This class keeps track wether a setting like the visible range of a graph is provided by the user, or generated based on the displayed data.\
	In the latter case, the appearance will change when, for example, the value span of a graph is changed.

	To accomplish this, a closure is required to update the value if it is not set manually.
*/
public class Setting<T> {
	let valueFallback: () -> T
	public var didSet: ((T) -> Void)?

	public init(value: T? = nil, fallback: () -> T) {
		valueFallback = fallback
		if let value = value {
			self.mValue = value
		} else {
			self.mValue = fallback()
		}
	}

	public var value: T {
		get {
			return mValue
		}
		set(value) {
			set(value)
		}
	}
	var mValue: T
	private(set) public var isUserValue: Bool = false
	public func set(value: T) {
		self.mValue = value
		isUserValue = true
		didSet?(value)
	}

	public func reset() {
		mValue = valueFallback()
		isUserValue = false
		didSet?(mValue)
	}

	func update(value: T) {
		self.mValue = value
	}

	public func update() {
		guard !isUserValue else {
			return
		}
		mValue = valueFallback()
	}
}
