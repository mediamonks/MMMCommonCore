//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2020 MediaMonks. All rights reserved.
//

import Foundation

/// Simple Semantic Versioning struct so you can easily compare 2 semantic versions.
///
/// **Example**
/// ```
///	let lower = SemVer(version: "1.5.2")
///	let higher = SemVer(major: 1, minor: 6, patch: 0)
///
/// lower == higher // false
/// lower < higher // true
/// ```
public struct SemVer: Codable {
	
	public static let zero = SemVer(major: 0, minor: 0, patch: 0)
	
	public let major: Int
	public let minor: Int
	public let patch: Int
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		
		self.init(version: try container.decode(String.self))
	}
	
	public init(major: Int, minor: Int, patch: Int) {
		self.major = major
		self.minor = minor
		self.patch = patch
	}
	
	/// Initialize by parsing a string version. This strips any non-numerical characters; `0.9-dev.5` becomes `0.9.5`.
	/// - Parameter version: The version in string format
	public init(version: String) {
	
		let onlyDigits = CharacterSet.decimalDigits.inverted
	
		var parts = version
			// We accept 1_2_4 as 1.2.4 as well, strange format, but seen occasionaly;
			// and shouldn't bother proper semantic versions.
			.replacingOccurrences(of: "_", with: ".")
			.split(separator: ".")
			.compactMap { Int($0.trimmingCharacters(in: onlyDigits)) }
		
		self.major = parts.popFirst() ?? 0
		self.minor = parts.popFirst() ?? 0
		self.patch = parts.popFirst() ?? 0
	}
	
	public var version: String { "\(major).\(minor).\(patch)" }
}

extension SemVer: Hashable {}
extension SemVer: Equatable {}

extension SemVer: Comparable {
	public static func < (lhs: SemVer, rhs: SemVer) -> Bool {
		// Could do more elaborate methods, but trying to keep this as simple as possible.
		if lhs.major < rhs.major { return true }
		if lhs.major > rhs.major { return false }
		
		if lhs.minor < rhs.minor { return true }
		if lhs.minor > rhs.minor { return false }
		
		if lhs.patch < rhs.patch { return true }
		if lhs.patch > rhs.patch { return false }
		
		return false
	}
}

extension SemVer: CustomDebugStringConvertible {
	public var debugDescription: String { version }
}

fileprivate extension Array {
	
	/// Safely remove the first (pop) item in the array, returning nil if array.count == 0.
	/// - Returns: The first element in the array
	mutating func popFirst() -> Element? {
		
		guard count > 0 else {
			// No elements.
			return nil
		}
		
		return removeFirst()
	}
}
