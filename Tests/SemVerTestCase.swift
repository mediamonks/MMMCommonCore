//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2020 MediaMonks. All rights reserved.
//

import XCTest
@testable import MMMCommonCore

internal final class SemVerTests: XCTestCase {
	
	public func testBasics() {
		
		let baseline = "1.2.3"
		let sem = SemVer(version: baseline)
		
		XCTAssertEqual(baseline, sem.version)
		XCTAssertEqual(1, sem.major)
		XCTAssertEqual(2, sem.minor)
		XCTAssertEqual(3, sem.patch)
	}
	
	public func testEquateable() {
		
		let baseline = "1.2.3"
		let sem = SemVer(version: baseline)
		let sem2 = SemVer(major: 1, minor: 2, patch: 3)
		
		XCTAssertEqual(sem, sem2)
	}
	
	public func testCompareable() {
		
		let major1 = SemVer(version: "3.2.0")
		let major2 = SemVer(version: "1.3.6")
		
		XCTAssert(major1 > major2)
		XCTAssertNotEqual(major1, major2)
		
		let minor1 = SemVer(version: "1.5.2")
		let minor2 = SemVer(version: "1.2.6")
		
		XCTAssert(major1 > minor1)
		
		XCTAssert(minor1 > minor2)
		XCTAssertNotEqual(major1, major2)
		
		let patch1 = SemVer(version: "0.3.2")
		let patch2 = SemVer(version: "0.3.0")
		
		XCTAssert(minor1 > patch1)
		
		XCTAssert(patch1 > patch2)
		XCTAssertNotEqual(patch1, patch2)
	}
	
	public func testParser() {
	
		XCTAssertEqual(SemVer(version: "0.1.200").version, "0.1.200")
		XCTAssertEqual(SemVer(version: "2000000.1.200").version, "2000000.1.200")
		XCTAssertEqual(SemVer(version: "0.1.200_abc").version, "0.1.200")
		XCTAssertEqual(SemVer(version: "0.100-dev.200").version, "0.100.200")
		XCTAssertEqual(SemVer(version: "1.2.3.4.5").version, "1.2.3")
	}
}
