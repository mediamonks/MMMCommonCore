//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2020 MediaMonks. All rights reserved.
//

import Foundation

extension Array {
	/// Iterates through all neighbouring pairs of elements (a[i], a[i + 1]) in a regular order.
	public func mmm_forEachPair(block: @escaping (Element, Element) -> Void) {
		for index in stride(from: 0, to: self.count - 1, by: 1) {
			block(self[index], self[index + 1])
		}
	}
	
	/// Find the first element that can map to a certain type, it's like doing a `.compactMap {}.first` without the
	/// overhead of mapping all values first.
	/// - Parameter predicate: The predicate to match and map the value.
	/// - Throws: Only rethrows.
	/// - Returns: The first value that the predicate matched.
	public func firstMap<T>(where predicate: (Element) throws -> T?) rethrows -> T? {
		for element in self {
			if let value = try predicate(element) {
				return value
			}
		}
		
		return nil
	}
}

// MARK: -

extension Error {
	/// Better string representation for `Error` and `NSError`s.
	///
	/// This is a Swift version of `mmm_description` that allows to avoid casting to `NSError`
	/// and which falls back `String(describing:)` for "not really" `NSError`s to avoid meaningless
	/// "The operation couldn't be completed" messages.
	public var mmm_description: String {
		if type(of: self) is NSError.Type {
			return (self as NSError).mmm_description()
		} else {
			return String(describing: self)
		}
	}
}

extension Optional where Wrapped == Error {
	/// To describe errors wrapped into optionals as well.
	public var mmm_description: String {
		switch self {
		case .none:
			return "<no error>"
		case .some(let error):
			return error.mmm_description
		}
	}
}

extension Optional {
	
	/// Unwrap an optional value, or throw the provided error when `nil`
	/// - Returns: `Wrapped` value.
	@available(*, deprecated, renamed: "unwrap(orThrow:)")
	public func unwrapped<E: Error>(orThrowing error: @autoclosure () -> E) throws -> Wrapped {
		try unwrap(orThrow: error())
	}
	
	/// Execute the callback when the optional is non-nil.
	/// - Parameter execute: The callback to be executed.
	/// - Returns: Self for chaining
	@discardableResult
	public func unwrapped(_ execute: (Wrapped) throws -> Void) rethrows -> Optional<Wrapped> {
		if let value = self {
			try execute(value)
		}
		return self
	}
	
	/// Unwrap an optional value, or throw the provided error when `nil`
	/// - Returns: `Wrapped` value.
	public func unwrap<E: Error>(orThrow error: @autoclosure () -> E) throws -> Wrapped {
		guard let value = self else {
			throw error()
		}
		return value
	}
	
	/// Unwrap an optional value, or return the provided fallback value. Basically the same as using a the `??` operator
	/// with a non-optional value, that might look strange, or get lost in a long chain.
	/// - Returns: `Wrapped` value if not nil, or `fallback`.
	public func unwrap(withFallback fallback: @autoclosure () -> Wrapped) -> Wrapped {
		return self ?? fallback()
	}
}

// MARK: -

/// Adding this to your Swift errors makes them better fit the ObjC world avoiding the dreaded
/// "The operation couldn’t be completed (<type> error 1.)" when tracing.
///
/// (The names with underscores are recognized by the standard Swift library and are needed for the magic.)
public protocol NSErrorFriendly: Error {
	var _userInfo: AnyObject? { get }
	var _code: Int { get }
}

extension NSErrorFriendly {

	public var _userInfo: AnyObject? {
		NSDictionary(dictionary: [ NSLocalizedDescriptionKey: String(describing: self) ])
	}

	// Swift uses code 1 for all cases, which just like the fixed description looks confusing on its own and when
	// traced with `mmm_description`, as it's making you think that it has picked a code based on case index.
	public var _code: Int { -1 }
}


// MARK: -

/// The name of the value's type suitable for logs or NSError domains: without the name of the module
/// and/or private contexts.
public func MMMTypeName(_ value: Any) -> String {
	// To avoid "Something.Type" when the type is passed as value.
	let name = type(of: value) is AnyClass
		? String(reflecting: type(of: value))
		: String(reflecting: value)
	return name
		.split(separator: ".")
		// Skip "(unknown context at $...)" added for private types.
		.filter { !($0.hasPrefix("(") && $0.hasSuffix(")")) }
		// Ignore module names as it's the main module most of the time.
		.dropFirst()
		.joined(separator: ".")
}

extension NSError {
	/// Initialize using the given value's type name as a domain string.
	public convenience init(domain: Any, message: String, code: Int = -1, underlyingError: Error? = nil) {
		var userInfo = [String: Any]()
		userInfo[NSLocalizedDescriptionKey] = message
		if let underlyingError = underlyingError as NSError? {
			userInfo[NSUnderlyingErrorKey] = underlyingError
		}
		let domain = (domain as? String) ?? MMMTypeName(domain)
		self.init(domain: domain, code: code, userInfo: userInfo)
	}
}

// MARK: -

extension String {
	
    /// Swift (`String`) version for replacing `${variable_name}` with a value from a providing dictionary.
    ///
    /// **Example**
    /// ```
    /// let str = "String with ${VARIABLES} in it, supports ${MULTIPLE} variables."
    /// str.mmm_stringBySubstitutingVariables([
    ///     "VARIABLES": "Foo",
    ///     "MULTIPLE": "Bar"
    /// ]) // String with Foo in it, supports Bar variables.
    /// ```
	public func mmm_stringBySubstitutingVariables(_ variables: [String: String]) -> String {
		return NSString(string: self).mmm_string(bySubstitutingVariables: variables)
	}
}

extension Scanner {

	/// Scans a single character unless at the end (or a null-terminator).
	///
	/// - Note: This is needed only before iOS 13, which has a corresponding shortcut.
	public func mmm_scanNextCharacter() -> Character? {
		let ch = self.__mmm_scanNextCharacter()
		guard ch != 0 else { return nil }
		if let scalar = UnicodeScalar(ch) {
			return Character(scalar)
		} else {
			return nil
		}
	}

	/// Scans the given strings if it follows next.
	///
	/// - Note: This is needed only before iOS 13, which has a corresponding shortcut.
	public func mmm_scanString(_ s: String) -> Bool {
		return self.scanString(s, into: nil)
	}
}

// MARK: - This is for misc stuff that is hard to group initially now.

/// Unwraps the given "parent" object and either executes the given closure with it or, if the parent is `nil`,
/// triggers `preconditionFailure()` with a corresponding message.
///
/// This is handy for objects that keep a weak reference to their "parent" object and depend on it for certain
/// operations. Normally these objects should not be used when their parent is deallocated, but it could be handy
/// to flag such misuse. Using a guard with a corresponding preconditionFailure() is fine, but can be repetitive
/// especially if a nicer message is wanted.
public func withParent<Parent, ReturnType>(
	_ parent: Parent?,
	function: StaticString = #function, file: StaticString = #file, line: UInt = #line,
	block: (Parent) -> ReturnType
) -> ReturnType {
	guard let parent = parent else {
		preconditionFailure("Using \(function) on an object without parent `\(Parent.self)`", file: file, line: line)
	}
	return block(parent)
}

/// `NSLocalizedString()` without `comment` and with an optional dictionary of `${VAR}` substitutions
/// (see `mmm_stringBySubstitutingVariables`).
public func MMMLocalizedString(_ key: String, vars: [String: String]? = nil) -> String {
	let notFoundSentinel = "__MMMLocalizedStringValueNotFound__"
	let result = NSLocalizedString(key, value: notFoundSentinel, comment: "") // swiftlint:disable:this nslocalizedstring_key
	guard result != notFoundSentinel else {
		#if !DEBUG
			// The Swift version of NSLocalizedString() would return and empty string by default.
			// The key's name would look bad in the release for sure but it might give more information
			// to the end user and can make reporting the untranslated keys easier.
			return key
		#else
			// And let's make sure to give more attention to untranslated strings in Debug builds.
			return "[[\(key)]]"
		#endif
	}
	if let vars = vars {
		return result.mmm_stringBySubstitutingVariables(vars)
	} else {
		return result
	}
}

/// Picks an element of a sequence that is matching the given preferred language identifier the best.
///
/// This is to offload an often used piece of logic where we need to find a suitable translation.
/// (This should be an extension on Sequence as it's irrelevant to most sequences.)
///
/// Language identifiers can have any case and both `-` and `_` are supported as separators
/// (although the latter is incorrect when we are talking about language identifiers on iOS).
///
/// - Parameters:
///   - languageOfElement: Returns the language corresponding to an element of the sequence.
///   - mode: Tells if partial matches are acceptable in case no exact match can be found.
public func MMMElementMatchingPreferredLanguage<T: Sequence>(
	in sequence: T,
	preferredLanguage: String,
	languageOfElement: (T.Element) -> String,
	mode: LanguageMatchingMode
) -> T.Element? {

	let preferred = SplitLanguageIdentifier(preferredLanguage)
	let available = sequence.map { (id: SplitLanguageIdentifier(languageOfElement($0)), element: $0) }
	
	// Let's look for the exact match first.
	var bestMatching = available.first { $0.id == preferred }
	
	if bestMatching == nil && mode == .allowPartiallyMatching {
		// A partial match favoring identifiers without region first (e.g. to make 'de' match earlier than 'de-AT'
		// for a preferred language 'de' or 'de-something', where something is not 'AT').
		bestMatching = available.first { $0.id.region.isEmpty && $0.id.lang == preferred.lang }
			?? available.first { $0.id.lang == preferred.lang }
	}
	
	return bestMatching.map { $0.element }
}

public func MMMBestMatchingLanguage(in languages: [String], preferredLanguage: String, mode: LanguageMatchingMode) -> String? {
	MMMElementMatchingPreferredLanguage(
		in: languages,
		preferredLanguage: preferredLanguage,
		languageOfElement: { $0 },
		mode: mode
	)
}

public enum LanguageMatchingMode {
	/// Only return an element where both the "language" and the "region" parts of the identifier match.
	case exact
	/// If no exact match is available, then return an element where at least the "language" part matches,
	/// giving preference to identifiers without the "region" part (e.g. 'de' is going to match earlier
	/// than 'de-AT').
	case allowPartiallyMatching
}

/// A little helper for parsing/comparing language IDs.
private struct SplitLanguageIdentifier: Equatable {

	/// The original identifier, "as is".
	public let identifier: String

	public let lang: String
	public let region: String

	public init(_ identifier: String) {
		self.identifier = identifier
		// Note that this is able to split both language and locale identifiers correctly.
		let components = Locale.components(fromIdentifier: identifier)
		self.lang = components[NSLocale.Key.languageCode.rawValue]?.lowercased() ?? ""
		self.region = components[NSLocale.Key.countryCode.rawValue]?.lowercased() ?? ""
	}

	public static func == (left: SplitLanguageIdentifier, right: SplitLanguageIdentifier) -> Bool {
		left.lang == right.lang && left.region == right.region
	}
}

extension Sequence {

	/// Elements of this sequence in the same order but with elements having the same identifier
	/// (as given by a closure) occurring only once.
	///
	/// ```
	/// let countries = [
	/// 	("JP", "Japan", "Tokyo"), ("JP", "Japan", "Osaka"),
	/// 	("IT", "Italy", "Milan"), ("IT", "Italy", "Rome")
	/// ]
	/// print(countries.unique { $0.0 })
	/// // Prints [("JP", "Japan", "Tokyo"), ("IT", "Italy", "Milan")]
	/// ```
	///
	/// - Parameter elementId: A closure providing identifier for every element of the sequence.
	public func unique<Identifier: Hashable>(by elementId: (Element) -> Identifier) -> [Element] {
		var seen: Set<Identifier> = []
		var result: [Element] = []
		for element in self {
			let id = elementId(element)
			if !seen.contains(id) {
				result.append(element)
				seen.insert(id)
			}
		}
		return result
	}
}
