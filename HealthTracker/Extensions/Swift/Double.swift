import Foundation

extension Double {
	/// Decomposes this value into its scientific notation components.
	///
	/// Returns the exponent and mantissa such that `self = mantissa × 10^exponent`, where the
	/// mantissa is normalized to the range [1, 10).
	///
	/// ## Example:
	///   ```swift
	///   let (exp, mant) = 2577.0.scientificNotation()
	///   // exp = 3.0, mant = 2.577 (2577 = 2.577 × 10³)
	///
	///   let (exp2, mant2) = 0.343.scientificNotation()
	///   // exp2 = -1.0, mant2 = 3.43 (0.343 = 3.43 × 10⁻¹)
	///   ```
	///
	/// - Returns: A tuple containing:
	///   - `exponent`: The power of 10 (e.g., 3 for thousands, -1 for tenths)
	///   - `mantissa`: The coefficient in the range [1, 10)
	var scientificNotation: (exponent: Double, mantissa: Double) {
		let exponent = floor(log10(self))
		let mantissa = self / pow(10, exponent)

		return (exponent, mantissa)
	}
}
