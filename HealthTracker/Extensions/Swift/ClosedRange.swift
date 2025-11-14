import Foundation

extension ClosedRange where Bound == Double {
	/// Creates a closed range with "nice" bounds suitable for chart axes.
	///
	/// This method automatically calculates appropriate axis bounds and tick spacing based on the
	/// provided data range. It uses the "nice numbers" algorithm to produce human-readable tick
	/// intervals (1, 2, 5, 10, 20, 50, etc.) and rounds the bounds to multiples of these intervals.
	///
	/// ## Example:
	///
	///   ```swift
	///   let range = ClosedRange.forChartAxis(min: 162.9, max: 173.5)
	///   // Result: 160.0...175.0
	///   ```
	///
	/// - Parameters:
	///   - min: The minimum data value to be displayed on the axis
	///   - max: The maximum data value to be displayed on the axis
	///
	/// - Returns: A closed range with "nice" bounds extending slightly beyond min and max
	static func forChartAxis(min: Bound, max: Bound) -> ClosedRange<Bound> {
		let range = max - min
		let roughSpacing = range / 4.0
		let (exponent, mantissa) = roughSpacing.scientificNotation

		let niceFraction = switch mantissa {
		case ...1: 1.0
		case ...2: 2.0
		case ...5: 5.0
		default: 10.0
		}

		let tickSpacing = niceFraction * pow(10, exponent)
		let niceMin = floor(min / tickSpacing) * tickSpacing
		let niceMax = ceil(max / tickSpacing) * tickSpacing

		return niceMin ... niceMax
	}
}
