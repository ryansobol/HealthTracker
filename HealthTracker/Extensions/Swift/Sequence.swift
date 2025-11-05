extension Sequence {
	/// Returns the first element of the sequence that satisfies the given predicate while
	/// accumulating state.
	///
	/// Use the `first(into:_:)` method to find an element in a sequence while maintaining and
	/// updating state as you search. This is useful when the decision to select an element depends
	/// on accumulated information from previously examined elements.
	///
	/// For example, you can use this method to find the first element where a cumulative sum
	/// exceeds a threshold:
	///
	/// ```swift
	/// let values = [10, 20, 30, 40, 50]
	/// let result = values.first(into: 0) { cumSum, value in
	///     cumSum += value
	///     return cumSum > 50
	/// }
	/// // result == 30 (cumSum becomes 10, 30, 60)
	/// ```
	///
	/// When `values.first(into:_:)` is called, the following steps occur:
	///
	/// 1. The `predicate` closure is called with the initial state—`0` in this case—and the first
	///    element `10`, updating the state to `10` and returning `false`.
	/// 2. The closure is called again with the updated state `10` and the next element `20`, updating
	///    the state to `30` and returning `false`.
	/// 3. The closure is called with state `30` and element `30`, updating the state to `60` and
	///    returning `true`, which causes the method to return `30`.
	///
	/// If no element satisfies the predicate, or if the sequence has no elements, the method returns
	/// `nil`.
	///
	/// - Parameters:
	///   - initialState: The value to use as the initial accumulating state.
	///   - predicate: A closure that receives the current accumulating state as an `inout`
	///     parameter and an element from the sequence. The closure updates the state as needed and
	///     returns a Boolean value indicating whether the element satisfies the search criteria.
	///
	/// - Returns: The first element of the sequence for which `predicate` returns `true`, or `nil`
	///   if no element satisfies the predicate.
	///
	/// - Complexity: O(*n*), where *n* is the length of the sequence.
	func first<State>(
		into initialState: State,
		_ predicate: (inout State, Self.Element) throws -> Bool,
	) rethrows -> Element? {
		var state = initialState

		for element in self {
			if try predicate(&state, element) {
				return element
			}
		}

		return nil
	}
}
