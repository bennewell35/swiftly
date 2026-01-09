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
        VStack(alignment: .leading, spacing: 12) {
            // Label row with current value - professional styling
            HStack {
                Text(label)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(valueFormatter(Int(value)))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(AppColors.primary.opacity(0.15))
                    )
            }
            
            // Slider with professional styling
            Slider(value: $value, in: range, step: step)
                .tint(AppColors.primary)
                .accentColor(AppColors.primary)
        }
        .padding(.vertical, 8)
    }
}

