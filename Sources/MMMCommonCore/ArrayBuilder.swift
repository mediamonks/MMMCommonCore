//
// MMMCommonCore. Part of MMMTemple.
// Copyright (C) 2016-2022 MediaMonks. All rights reserved.
//

import Foundation

/// A resultBuilder to help with constructing arrays. This can be useful when you want to create an array, in order, that
/// depends on a number of conditions.
///
/// **Example**
/// ```
/// // For example populating an array of widgets (inside your ViewModel).
///	self.widgets.build {
///		ProfileWidget(user: self.user)
///
///		if let avatar = userAvatar() {
///			AvatarWidget(avatar: avatar)
///		}
///
///		switch user.type {
///		case .admin:
///			AdminPanel(user: user)
///			DeveloperPanel(user: user)
///
///		case .developer:
///			DeveloperPanel(user: user)
///		}
///	}
/// ```
///
/// Now `widgets.didSet` only get's called once, allowing you to trigger changes once.
///
/// **Old example**
/// ```
///	var widgets: [AnyWidget] = [
///		ProfileWidget(user: self.user)
///	]
///
///	if let avatar = userAvatar() {
///		widgets.append(AvatarWidget(avatar: avatar))
///	}
///
///	switch user.type {
///	case .admin:
///		widgets.append(contentsOf: [
///			AdminPanel(user: user)
///			DeveloperPanel(user: user)
///		])
///
///	case .developer:
///		widgets.append(DeveloperPanel(user: user))
///	}
///
///	self.widgets = widgets
/// ```
@resultBuilder
public struct ArrayBuilder<T> {

	public static func buildBlock() -> [T] {
		return []
	}

	public static func buildBlock(_ component: T) -> [T] {
		return [component]
	}

	public static func buildBlock(_ components: T...) -> [T] {
		return components
	}

	public static func buildBlock(_ components: [T]) -> [T] {
		return components
	}

	public static func buildBlock(_ components: [T]...) -> [T] {
		return components.flatMap { $0 }
	}
	
	public static func buildArray(_ components: [T]) -> [T] {
		return components
	}
	
	// Support for if/else and switch statements.
	
	public static func buildOptional(_ component: [T]?) -> [T] {
		return component ?? []
	}

	public static func buildEither(first component: [T]) -> [T] {
		return component
	}

	public static func buildEither(second component: [T]) -> [T] {
		return component
	}
	
	// Helpers to allow flatMapping inside the ArrayBuilder.
	
	public static func buildBlock(
		_ components: [T],
		_ trailing: T...
	) -> [T] {
		return components + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ components: [T],
		_ trailing: T...
	) -> [T] {
		return [component1] + components + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ component2: T,
		_ components: [T],
		_ trailing: T...
	) -> [T] {
		return [component1, component2] + components + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ component2: T,
		_ component3: T,
		_ components: [T],
		_ trailing: T...
	) -> [T] {
		return [component1, component2, component3] + components + trailing
	}
	
	// Helpers to allow flatMapping inside of conditionals in the ArrayBuilder.
	
	public static func buildBlock(
		_ array1: [T],
		_ array2: [T],
		_ component: T,
		_ trailing: T...
	) -> [T] {
		return array1 + array2 + [component] + trailing
	}
	
    public static func buildBlock(
		_ array1: [T],
		_ component: T,
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return array1 + [component] + array2 + trailing
	}
	
    public static func buildBlock(
		_ component: T,
		_ array1: [T],
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return [component] + array1 + array2 + trailing
	}
    
    public static func buildBlock(
		_ array1: [T],
		_ component1: T,
		_ component2: T,
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return array1 + [component1, component2] + array2 + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ array1: [T],
		_ component2: T,
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return [component1] + array1 + [component2] + array2 + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ component2: T,
		_ array1: [T],
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return [component1, component2] + array1 + array2 + trailing
	}
    
    public static func buildBlock(
		_ array1: [T],
		_ component1: T,
		_ component2: T,
		_ component3: T,
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return array1 + [component1, component2, component3] + array2 + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ array1: [T],
		_ component2: T,
		_ component3: T,
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return [component1] + array1 + [component2, component3] + array2 + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ component2: T,
		_ array1: [T],
		_ component3: T,
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return [component1, component2] + array1 + [component3] + array2 + trailing
	}
	
    public static func buildBlock(
		_ component1: T,
		_ component2: T,
		_ component3: T,
		_ array1: [T],
		_ array2: [T],
		_ trailing: T...
	) -> [T] {
		return [component1, component2, component3] + array1 + array2 + trailing
	}
}

extension Array {
	
	/// Rebuild the array using the ``ArrayBuilder``.
	public mutating func build(@ArrayBuilder<Element> builder: () -> [Element]) {
		self = builder()
	}
	
	/// Rebuild the array using the ``ArrayBuilder``, returning a new array.
	public func building(@ArrayBuilder<Element> builder: () -> [Element]) -> [Element] {
		builder()
	}
	
	/// Append contents to the array using the ``ArrayBuilder``.
	public mutating func append(@ArrayBuilder<Element> builder: () -> [Element]) {
		self.append(contentsOf: builder())
	}
	
	/// Append contents to the array using the ``ArrayBuilder``, returning a new array.
	public func appending(@ArrayBuilder<Element> builder: () -> [Element]) -> [Element] {
		var result = self
		result.append(contentsOf: builder())
		return result
	}
}
