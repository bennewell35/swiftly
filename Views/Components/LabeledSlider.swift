import SwiftUI

/// A reusable slider component with a label and value display.
///
/// Architecture note: This is a reusable component that encapsulates
/// common slider UI patterns. Using @Binding allows the parent view to
/// read and write the value, maintaining a single source of truth.
///
/// - Parameters:
///   - label: The text label shown above the slider
///   - value: Binding to the slider's value (1-5 for most inputs, or 0-120 for time)
///   - range: The valid range for the slider
///   - step: The increment step for the slider
///   - valueFormatter: Optional function to format the displayed value (e.g., "5 min" vs "5")
struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let valueFormatter: (Int) -> String
    
    init(
        label: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double = 1.0,
        valueFormatter: @escaping (Int) -> String = { "\($0)" }
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.valueFormatter = valueFormatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label row with current value
            HStack {
                Text(label)
                    .font(.headline)
                Spacer()
                Text(valueFormatter(Int(value)))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Slider with step control
            Slider(value: $value, in: range, step: step)
                .tint(.blue)  // System blue adapts to dark mode
        }
        .padding(.vertical, 4)
    }
}

