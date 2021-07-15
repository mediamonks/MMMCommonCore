//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2020 MediaMonks. All rights reserved.
//

import XCTest
@testable import MMMCommonCore

public final class MMMCommonTestCase: XCTestCase {

	private enum Err: Error {
		case `default`
	}

	public func testOptionalHelpers() {
		
		let empty: String? = nil
		
		XCTAssertThrowsError(try empty.unwrap(orThrow: Err.default))
		XCTAssertEqual(empty.unwrap(withFallback: "foo"), "foo")
		
		let notEmpty: String? = "Val"

		XCTAssertNoThrow(try notEmpty.unwrap(orThrow: Err.default))
		XCTAssertEqual(try notEmpty.unwrap(orThrow: Err.default), "Val")
		
		XCTAssertEqual(notEmpty.unwrap(withFallback: "foo"), "Val")
	}
}
