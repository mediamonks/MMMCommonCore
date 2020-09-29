//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2020 MediaMonks. All rights reserved.
//

import Foundation

/// This to be able to test classes depending on real time.
public protocol MMMTimeSource: AnyObject {

	/// Current time. It might be frozen, but should never go back.
	var now: Date { get }

	/// Time interval of the source scaled to real time. Needed when a class under tests uses timers, etc.
	func realTimeIntervalFrom(_ timeInterval: TimeInterval) -> TimeInterval
}

/// Time source for unit tests, where the "now" can be set externally and the scale or real time can be changed.
public final class MMMMockTimeSource: MMMTimeSource {

	private let scale: Double

	public init(scale: Double = 1) {
		self.scale = scale
	}

	/// Controlled from the unit test to override the meaning of now for the class under test.
	public var now: Date = Date(timeIntervalSinceReferenceDate: 622072000)

	public func realTimeIntervalFrom(_ timeInterval: TimeInterval) -> TimeInterval {
		return timeInterval * scale
	}
}

/// A regular (real time) time source.
public final class MMMDefaultTimeSource: MMMTimeSource {

	public var now: Date { Date() }

	public func realTimeIntervalFrom(_ timeInterval: TimeInterval) -> TimeInterval {
		return timeInterval
	}

	public init() {}
}
