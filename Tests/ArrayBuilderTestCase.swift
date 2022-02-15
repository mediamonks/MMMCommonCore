//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2022 MediaMonks. All rights reserved.
//

import XCTest
@testable import MMMCommonCore

internal func test<T>(@ArrayBuilder<T> block: () -> [T]) -> [T] {
	block()
}

internal final class ArrayBuilderTestCase: XCTestCase {
	
	private enum State {
		case a, b, c
	}
	
	private class ViewModel {
		
		var widgets: [String] = []
		
		func update() {
			self.widgets.build {
				"A"
				"B"
				"C"
			}
		}
	}
	
	public func testBasics() {
		
		var condition = false
		
		@ArrayBuilder<String> var strings: [String] {
			"Foo"
			"Bar"
			"Baz"
			
			if condition {
				"Baz2"
			}
		}
		
		XCTAssertEqual(strings.count, 3)
		
		condition = true
		
		XCTAssertEqual(strings.count, 4)
		
		let others = test {
			"Foo"
			"Bar"
			
			["Bar", "Boo"]
		}
		
		XCTAssertEqual(others.count, 4)
		XCTAssertEqual(others, ["Foo", "Bar", "Bar", "Boo"])
		
		var val = State.a
		
		@ArrayBuilder<String> var switches: [String] {
			switch val {
			case .a:
				"One"
				
			case .b:
				"One"
				"Two"
				
			case .c:
				"One"
				"Two"
				"Three"
			}
		}
		
		XCTAssertEqual(switches, ["One"])
		
		val = .b
		
		XCTAssertEqual(switches, ["One", "Two"])
		
		val = .c
		
		XCTAssertEqual(switches, ["One", "Two", "Three"])
		
		let complex = test {
			switch val {
			case .a:
				"One"
				
			case .b:
				"One"
				"Two"
				
			case .c:
				"One"
				"Two"
				
				["Intermediate", "Array"]
				
				if condition {
					["With", "Condition"]
				}
				
				"Three"
			}
		}
		
		XCTAssertEqual(complex, ["One", "Two", "Intermediate", "Array", "With", "Condition", "Three"])
	}
}
