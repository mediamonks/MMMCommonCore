# MMMCommonCore

[![Build](https://github.com/mediamonks/MMMCommonCore/workflows/Build/badge.svg)](https://github.com/mediamonks/MMMCommonCore/actions?query=workflow%3ABuild)
[![Test](https://github.com/mediamonks/MMMCommonCore/workflows/Test/badge.svg)](https://github.com/mediamonks/MMMCommonCore/actions?query=workflow%3ATest)

Small bits and pieces reused in many pods from MMMTemple.

(This is a part of `MMMTemple` suite of iOS libraries we use at [MediaMonks](https://www.mediamonks.com/).)

## Installation

Podfile:

```ruby
source 'https://github.com/mediamonks/MMMSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'
...
pod 'MMMCommonCore'
```

(Use 'MMMCommonCore/ObjC' when Swift wrappers are not needed.)

SPM:

```swift
.package(url: "https://github.com/mediamonks/MMMCommonCore", .upToNextMajor(from: "1.8.1"))
```

## Usage

MMMCommonCore contains some concrete classes, global functions as well as extensions to 
Foundation & native Swift types. There are also some Objective-C macro's available, have
a peek at `MMMCommonCore.h` for more info on that.

### MMMNetworkConditioner

This is to help with network-related simulated delays and failures.

**Example:**

```swift

// Somewhere in your setup code we initialize a network conditioner.
// You probably want to only fail and delay on debug builds, you can
// pass `nil` as the condition to avoid any delays or failures.
self.conditioner = MMMNetworkConditioner(
    condition: MMMSimpleNetworkCondition(
        minDelay: 1, // Delay all requests for at least 1 second.
        maxDelay: 5, // at most 5 seconds.
        failureRate: 0.3 // Fail 30% of the time.
    )
)

// This will also replace the shared instance, as long as the 
// MMMNetworkConditioner is initialized exactly once.
//
// So we can use the shared() instance from now on.
MMMNetworkConditioner.shared().conditionBlock { err in
    
    if let error = error {
        // Result failed due to simulated error, this will happen 30% of the time.
        promise.fail(error)
        return
    }
    
    let task = URLSession.shared.dataTask(with: myUrl) { data, response, error in
        
        if let error = error {
            // Result actually failed.
            promise.fail(error)
        }
        
        ...
    }
    
    ...
}
```

### MMMWeakProxy

This is to be able to cut strong references, such as the ones NSTimer creates to its
targets. The proxy will forward all method calls to the target, but at the same time
won't hold a reference to the target.

**Example:**

```swift
foo.addTarget(MMMWeakProxy(target: self), selector: ...)
```

### MMMTimeSource

This to be able to test classes depending on real time. Default implementations are
`MMMMockTimeSource` and `MMMDefaultTimeSource`. `MMMMockTimeSource` is a time source 
for unit tests, where the "now" can be set externally and the scale or real time 
can be changed. `MMMDefaultTimeSource` is a regular (real time) time source.

```swift
class Foo {

    init(timeSource: MMMTimeSource) {
        // Current time. It might be frozen, but should never go back.
        print("Current time: ", timeSource.now)
    }
}

// Use in app:

let foo = Foo(timeSource: MMMDefaultTimeSource())

// Use in tests:

// Now we can mock the time.
let time = MMMMockTimeSource()
let foo = Foo(timeSource: time)
```

### SemVer

Simple Semantic Versioning struct so you can easily compare 2 semantic versions.

**Example:**

```swift
let lower = SemVer(version: "1.5.2")
let higher = SemVer(major: 1, minor: 6, patch: 0)

lower == higher // false
lower < higher // true
```

### ArrayBuilder

A `resultBuilder` to help with constructing arrays. This can be useful when you want to 
create an array, in order, that depends on a number of conditions.

**Example:**

```swift
// For example populating an array of widgets (inside your ViewModel).
self.widgets.build {
	ProfileWidget(user: self.user)

	if let avatar = userAvatar() {
		AvatarWidget(avatar: avatar)
	}

	switch user.type {
	case .admin:
		AdminPanel(user: user)
		DeveloperPanel(user: user)

	case .developer:
		DeveloperPanel(user: user)
	}
}
```

Now `widgets.didSet` only get's called once, allowing you to trigger changes once.

The `ArrayBuilder` has some extensions on `Array` for ease of use:

```swift
/// Rebuild the array using the ``ArrayBuilder``.
mutating func build(@ArrayBuilder<Element> builder: () -> [Element])
	
/// Rebuild the array using the ``ArrayBuilder``, returning a new array.
func building(@ArrayBuilder<Element> builder: () -> [Element]) -> [Element]

/// Append contents to the array using the ``ArrayBuilder``.
mutating func append(@ArrayBuilder<Element> builder: () -> [Element])

/// Append contents to the array using the ``ArrayBuilder``, returning a new array.
func appending(@ArrayBuilder<Element> builder: () -> [Element]) -> [Element]
```

### Extensions

All extensions are summarized per type, click on the typename to view it's extensions.

<details><summary><strong>Array</strong></summary>
<p>

#### `Array.firstMap`

```swift
/// Find the first element that can map to a certain type, it's like doing a `.compactMap {}.first` 
/// without the overhead of mapping all values first.
/// - Parameter predicate: The predicate to match and map the value.
/// - Throws: Only rethrows.
/// - Returns: The first value that the predicate matched.
func firstMap<T>(where predicate: (Element) throws -> T?) rethrows -> T?
```

</p>
</details>

<details><summary><strong>Sequence</strong></summary>
<p>

#### `Sequence.unique`

```swift
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
func unique<Identifier: Hashable>(by elementId: (Element) -> Identifier) -> [Element]
```

</p>
</details>

<details><summary><strong>Error & NSError</strong></summary>
<p>

#### `Error.mmm_description + NSError.mmm_description`

> **Note:** Also works on `Optional<Error>`.

```swift
/// Better string representation for `Error` and `NSError`s.
///
/// This is a Swift version of `mmm_description` that allows to avoid casting to `NSError`
/// and which falls back `String(describing:)` for "not really" `NSError`s to avoid meaningless
/// "The operation couldn't be completed" messages.
var mmm_description: String { get }
```

#### `NSError.mmm_underlyingError`

```swift
/// A shortcut fetching the underlying error.
func mmm_underlyingError() -> Error?
```

#### `NSError.init`

```swift
/// Initialize using the given value's type name as a domain string.
init(domain: Any, message: String, code: Int = -1, underlyingError: Error? = nil)
```

#### `NSError.mmm_error`

```swift
/// A convenience initializer accepting an underlying error as a parameter (can be nil).
class func mmm_error(withDomain domain: String, code: Int, message: String, underlyingError: Error?) -> Error

/// An initializer with the code being optional (set to -1, so is not displayed by mmm_description).
class func mmm_error(withDomain domain: String, message: String, underlyingError: Error?) -> Error

/// Another initializer hiding both the code (setting it to -1) and the underlyingError.
class func mmm_error(withDomain domain: String, message: String) -> Error
```


</p>
</details>

<details><summary><strong>Optional</strong></summary>
<p>

#### `Optional.unwrapped`

```swift
/// Execute the callback when the optional is non-nil.
/// - Parameter execute: The callback to be executed.
/// - Returns: Self for chaining
@discardableResult
func unwrapped(_ execute: (Wrapped) throws -> Void) rethrows -> Optional<Wrapped>
```

#### `Optional.unwrap(orThrow:)`

```swift
/// Unwrap an optional value, or throw the provided error when `nil`
/// - Returns: `Wrapped` value.
func unwrap<E: Error>(orThrow error: @autoclosure () -> E) throws -> Wrapped
```

#### `Optional.unwrap(withFallback:)`

```swift
/// Unwrap an optional value, or return the provided fallback value. Basically the same as 
/// using a the `??` operator with a non-optional value, that might look strange, or get 
/// lost in a long chain.
/// - Returns: `Wrapped` value if not nil, or `fallback`.
func unwrap(withFallback fallback: @autoclosure () -> Wrapped) -> Wrapped
```

</p>
</details>

<details><summary><strong>String</strong></summary>
<p>

#### `String.mmm_stringBySubstitutingVariables`

```swift
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
func mmm_stringBySubstitutingVariables(_ variables: [String: String]) -> String
```

</p>
</details>

<details><summary><strong>Scanner</strong></summary>
<p>

#### `Scanner.mmm_scanNextCharacter`

```swift
/// Scans a single character unless at the end (or a null-terminator).
///
/// - Note: This is needed only before iOS 13, which has a corresponding shortcut.
func mmm_scanNextCharacter() -> Character?
```

#### `Scanner.mmm_scanString`

```swift
/// Scans the given strings if it follows next.
///
/// - Note: This is needed only before iOS 13, which has a corresponding shortcut.
func mmm_scanString(_ s: String) -> Bool
```

</p>
</details>

<details><summary><strong>NSDictionary</strong></summary>
<p>

#### `NSDictionary.mmm_extended`

```swift
/// A dictionary built from the receiver by adding values from another dictionary. The other 
/// dictionary can be nil. This is to make it more convenient to add stuff to literal 
/// dictionaries, such as Auto Layout metrics dictionaries or CoreText attribute dictionaries. 
func mmm_extended(with d: [AnyHashable : Any]) -> [AnyHashable : Any]
```

</p>
</details>

<details><summary><strong>NSMutableCharacterSet</strong></summary>
<p>

#### `NSMutableCharacterSet.mmm_addCharacters`

```swift
/// Convenience shortcut for `addCharactersInRange`. Adds a range of characters from first 
/// to last (including them both).
func mmm_addCharacters(from fist: unichar, to last: unichar)
```

</p>
</details>

<details><summary><strong>NSObject</strong></summary>
<p>

#### `NSObject.mmm_stripNSNull`

```swift
/// The receiver itself, or nil, if the receiver is [NSNull null].
func mmm_stripNSNull() -> Any
```

</p>
</details>

<details><summary><strong>NSString</strong></summary>
<p>

#### `NSString.mmm_string(bySubstitutingVariables:)`

```swift
/// Returns a string with variables in the form `${variable_name}` being replaced with values 
/// from the provided dictionary under the keys corresponding to "variable_name". This is handy
/// for translatable strings, where the order of arguments might change and we don't want to use
/// tricky syntax of `stringWithFormat:`.
///
/// Note that keys are currently case-sensitive and the implementation is not very efficient, 
/// i.e. it should not be used with very long text.
func mmm_string(bySubstitutingVariables vars: [AnyHashable : Any]) -> String
```

</p>
</details>

<details><summary><strong>NSDate</strong></summary>
<p>

#### `NSDate.mmm_date(withInternetTime:)`

```swift
/// NSDate from internet timestamps, ISO8601-like strings like "2016-10-22T10:23:28Z". 
/// We support "Internet profile" of ISO8601, as described in RFC3339, and also allow 
/// the timezone or field separators to be absent.
class func mmm_date(withInternetTime s: String) -> Date
```

</p>
</details>

<details><summary><strong>NSArray</strong></summary>
<p>

#### `NSArray.mmm_arrayOfSlices`

```swift
/// The original array cut into subarrays with each slice except perhaps the last one 
/// consisting of maxLength elements.
func mmm_arrayOfSlices(withMaxLength maxLength: Int) -> [Any]
```

#### `NSArray.mmm_forEachPair`

```swift
/// Performs the given block for each pair of the elements of the array from left to right,
/// like (a[0], [1]), then (a[1], [2]), etc, i.e. every element except for the first and 
/// the last will participate in two pairs.
func mmm_forEachPair(_ block: (Any, Any) -> Void)
```

</p>
</details>

<details><summary><strong>NSData</strong></summary>
<p>

#### `NSData.mmm_data(withHexEncodedString:)`

```swift
/// NSData object with a hex-encoded string. E.e. @"001213" will give NSData consisting of 
/// 3 bytes 0x00, 0x12, and 0x13. This is handy for unit tests where NSData objects are 
/// expected.
/// 
/// Note that we ignore any non-hex characters between individual bytes, so you can insert
/// spaces, for example.
class func mmm_data(withHexEncodedString string: String) -> Any
```

</p>
</details>

### Global Functions

All functions are summarized by function name, click on a function for more info.

<details><summary><strong>MMMTypeName()</strong></summary>
<p>

```swift
/// The name of the value's type suitable for logs or NSError domains: without the name of the module
/// and/or private contexts.
public func MMMTypeName(_ value: Any) -> String
```

</p>
</details>

<details><summary><strong>withParent()</strong></summary>
<p>

```swift
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
) -> ReturnType
```

</p>
</details>

<details><summary><strong>MMMLocalizedString()</strong></summary>
<p>

```swift
/// `NSLocalizedString()` without `comment` and with an optional dictionary of `${VAR}` substitutions
/// (see `mmm_stringBySubstitutingVariables`).
public func MMMLocalizedString(_ key: String, vars: [String: String]? = nil) -> String
```

</p>
</details>

<details><summary><strong>MMMIsSystemVersionGreaterOrEqual()</strong></summary>
<p>

```swift
/// `true`, if the current iOS version is greater or equal to the provided version string.
public func MMMIsSystemVersionGreaterOrEqual(_ version: String) -> Bool
```

</p>
</details>

<details><summary><strong>MMMPathRelativeToAppBundle()</strong></summary>
<p>

```swift
/// For a path in one of the known subfolders of the app's sandbox (such as Library or Caches) 
/// returns a relative path prefixed with tokens like <Library> or <Bundle>. Returns the path 
/// unchanged in case it does not seem to be in a known folder.
/// 
/// Simple comparison is performed, the path is not normalized beforehand, etc. 
/// This is used only for direct output to logs, i.e. it's human readable and the format should
/// not be relied upon.
public func MMMPathRelativeToAppBundle(_ path: String) -> String
```

</p>
</details>

<details><summary><strong>MMMCurlStringFromRequest()</strong></summary>
<p>

```swift
/// Roughly a curl-equivalent string for the given request. 
/// It's handy to dump all the outgoing requests this way.
public func MMMCurlStringFromRequest(_ request: URLRequest) -> String
```

</p>
</details>

<details><summary><strong>MMMStringForLoggingFromData()</strong></summary>
<p>

```swift
/// A string version of the given NSData object suitable for logging. Typically used with
/// network responses, when we get something we cannot even parse, then we log at least
/// the beginning of it.
/// 
/// We try to interpret it as a UTF-8 encoded string first, and if it's not possible, then
/// resort to a hex dump. The result will be shorter than `maxStringLength` characters 
/// (unless this parameter is unreasonably small) and an ellipsis will be added in case of
/// truncation.
public func MMMStringForLoggingFromData(_ data: Data, _ maxStringLength: Int) -> String
```

</p>
</details>

<details><summary><strong>MMMQueryStringFromParameters()</strong></summary>
<p>

```swift
/// Properly escaped URL query string from a dictionary of key-value pairs.
/// The keys are sorted alphabetically, so the same result is produced for the same dictionary.
public func MMMQueryStringFromParameters(_ parameters: [String : String]) -> String
```

</p>
</details>

<details><summary><strong>MMMQueryStringFromParametersEscape()</strong></summary>
<p>

```swift
/// The function that is used by MMMQueryStringFromParameters() to escape parameter
/// names or values.
public func MMMQueryStringFromParametersEscape(_ s: String) -> String
```

</p>
</details>

<details><summary><strong>MMMSeemsLikeEmail()</strong></summary>
<p>

```swift
/// `true`, if the given string might be an email address.
///
/// This is not a validation but a basic sanity check: only checking for the presence
/// of at least one '@' and at least one dot character.
public func MMMSeemsLikeEmail(_ email: String) -> Bool
```

</p>
</details>

## Ready for liftoff? 🚀

We're always looking for talent. Join one of the fastest-growing rocket ships in
the business. Head over to our [careers page](https://media.monks.com/careers)
for more info!
