import OrderedCollections

extension OrderedDictionary {
	/// Returns a new dictionary containing the keys of this dictionary with the values transformed by
	/// the given closure.
	///
	/// This variant of `mapValues` provides access to both the key and value when computing a new
	/// transformed value for the key.
	///
	/// - Parameter transform: A closure that transforms a value. `transform` accepts each key-value
	///   pair of the dictionary as its parameters and returns a transformed value of the same or of a
	///   different type.
	///
	/// - Returns: A dictionary containing the keys and transformed values of this dictionary, in the
	///   same order.
	///
	/// - Complexity: O(`count`)
	func mapValues<T, E: Error>(_ transform: (Key, Value) throws(E) -> T) throws(E)
		-> OrderedDictionary<Key, T>
	{
		var result = OrderedDictionary<Key, T>(minimumCapacity: self.count)

		for (key, value) in self {
			result[key] = try transform(key, value)
		}

		return result
	}

	/// Returns the elements of the dictionary, sorted by key using the given predicate as the
	/// comparison between keys.
	///
	/// When you want to sort a dictionary whose keys don't conform to the `Comparable` protocol, pass
	/// a predicate to this method that returns `true` when the first key should be ordered before the
	/// second. The elements of the resulting dictionary are ordered according to the given predicate.
	///
	/// The predicate must be a *strict weak ordering* over the keys. That is, for any keys `a`, `b`,
	/// and `c`, the following conditions must hold:
	///
	/// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
	///
	/// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are both `true`, then
	///   `areInIncreasingOrder(a, c)` is also `true`. (Transitive comparability)
	///
	/// - Two keys are *incomparable* if neither is ordered before the other according to the
	///   predicate. If `a` and `b` are incomparable, and `b` and `c` are incomparable, then `a` and
	///   `c` are also incomparable. (Transitive incomparability)
	///
	/// The sorting algorithm is guaranteed to be stable. A stable sort preserves the relative order
	/// of elements for which `areInIncreasingOrder` does not establish an order.
	///
	/// - Parameter areInIncreasingOrder: A predicate that returns `true` if its first argument should
	///   be ordered before its second argument; otherwise, `false`.
	/// - Returns: A new ordered dictionary with the same key-value pairs, sorted by key according to
	///   the predicate.
	///
	/// - Complexity: O(*n* log *n*), where *n* is the number of key-value pairs in the dictionary.
	func sorted(by areInIncreasingOrder: (Key, Key) throws -> Bool) rethrows -> Self {
		let sortedElements = try self.sorted { try areInIncreasingOrder($0.key, $1.key) }

		return OrderedDictionary(uniqueKeysWithValues: sortedElements)
	}
}

extension OrderedDictionary where Key: Comparable {
	/// Returns the elements of the dictionary, sorted by key in ascending order.
	///
	/// This method sorts the dictionary's key-value pairs by comparing keys using the less-than
	/// operator (`<`).
	///
	/// - Returns: A new ordered dictionary with the same key-value pairs, sorted by key in ascending
	///   order.
	///
	/// - Complexity: O(*n* log *n*), where *n* is the number of key-value pairs in the dictionary.
	func sorted() -> Self {
		return self.sorted(by: { $0 < $1 })
	}
}

extension OrderedDictionary where Key: Comparable & Sendable {
	/// Returns the elements of the dictionary, sorted by key in ascending order.
	///
	/// This method sorts the dictionary's key-value pairs by comparing keys using the less-than
	/// operator (`<`). This variant is available when the key type conforms to both `Comparable` and
	/// `Sendable`, allowing the less-than operator to be used directly in concurrent contexts.
	///
	/// - Returns: A new ordered dictionary with the same key-value pairs, sorted by key in ascending
	///   order.
	///
	/// - Complexity: O(*n* log *n*), where *n* is the number of key-value pairs in the dictionary.
	func sorted() -> Self {
		return self.sorted(by: <)
	}
}
