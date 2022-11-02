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
	
	public func testPairs() {
	
	 	func m(a: Int, b: Int) -> String { "\(a)\(b)" }
	 	
		XCTAssertEqual([1, 2, 3].pairs().map(m), ["12", "23"])
		XCTAssertEqual([1, 2].pairs().map(m), ["12"])
		XCTAssertEqual([1].pairs().map(m), [])
		XCTAssertEqual([].pairs().map(m), [])

		XCTAssertEqual((1...).pairs().prefix(5).map(m), ["12", "23", "34", "45", "56"])
	}
	
	public func testMMMElementMatchingPreferredLanguage() {
	
		let languages = ["de-AT", "de", "de_CH", "fr_FR"]
		
		XCTAssertEqual(MMMBestMatchingLanguage(in: languages, preferredLanguage: "de_CH", mode: .exact), "de_CH")
		// "Exact" means both language & region should match, case and modifiers are ignored.
		XCTAssertEqual(MMMBestMatchingLanguage(in: languages, preferredLanguage: "de_ch_POSIX", mode: .exact), "de_CH")
		XCTAssertEqual(MMMBestMatchingLanguage(in: languages, preferredLanguage: "de_DE", mode: .exact), nil)
		
		// An exact match goes first, if available.
		XCTAssertEqual(MMMBestMatchingLanguage(in: languages, preferredLanguage: "de_CH", mode: .allowPartiallyMatching), "de_CH")
		// A language without region is considered "more general", though other language could be closer to the preferred.
		XCTAssertEqual(MMMBestMatchingLanguage(in: languages, preferredLanguage: "de_IT", mode: .allowPartiallyMatching), "de")
		XCTAssertEqual(MMMBestMatchingLanguage(in: languages, preferredLanguage: "fr", mode: .allowPartiallyMatching), "fr_FR")

		XCTAssertEqual(
			MMMBestMatchingLanguage(in: languages, preferredLanguages: ["en", "de-DE"], mode: .allowPartiallyMatching),
			"de"
		)
		XCTAssertEqual(
			MMMBestMatchingLanguage(in: languages, preferredLanguages: ["en", "de-DE"], mode: .exact),
			nil
		)
		XCTAssertEqual(
			MMMBestMatchingLanguage(in: languages, preferredLanguages: ["en", "it"], mode: .allowPartiallyMatching),
			nil
		)
	}
}
