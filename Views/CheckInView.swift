import SwiftUI

/// The main check-in screen where users input their daily metrics.
///
/// Architecture note: This view manages local state (@State) for the 5 input fields.
/// We use Double for sliders because SwiftUI's Slider works with Double, then convert
/// to Int when creating the DailyCheckIn model. The view observes CheckInStore via
/// @ObservedObject to add new check-ins.
///
/// State management:
/// - @State: Local to this view, resets when view is dismissed
/// - @ObservedObject: References the shared CheckInStore for persistence
struct CheckInView: View {
    @ObservedObject var store: CheckInStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // Local state for form inputs
    // Architecture note: We use optionals to track if a field has been set.
    // This allows us to disable the submit button until all fields are filled.
    @State private var sleepQuality: Double?
    @State private var stressLevel: Double?
    @State private var muscleSoreness: Double?
    @State private var motivation: Double?
    @State private var timeAvailable: Double?
    
    // Computed property to check if form is valid
    // Architecture note: This is a computed property, not stored state,
    // so it automatically updates when any of the @State values change.
    private var isFormValid: Bool {
        sleepQuality != nil &&
        stressLevel != nil &&
        muscleSoreness != nil &&
        motivation != nil &&
        timeAvailable != nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background that adapts to light/dark mode
                AppColors.background(for: colorScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section with glassmorphism
                        VStack(spacing: 8) {
                            Text("Rate Your Day")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Adjust each slider to reflect how you're feeling today")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        
                        // Glassmorphic card container
                        VStack(spacing: 24) {
                            // Sleep Quality (1-5)
                            if let value = sleepQuality {
                                LabeledSlider(
                                    label: "Sleep Quality",
                                    value: Binding(
                                        get: { value },
                                        set: { sleepQuality = $0 }
                                    ),
                                    range: 1...5,
                                    step: 1.0
                                )
                            } else {
                                Button(action: { sleepQuality = 3 }) {
                                    HStack {
                                        Text("Sleep Quality")
                                            .font(.headline)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Text("Tap to set")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(.vertical, 12)
                                }
                            }
                            
                            Divider()
                                .background(AppColors.textSecondary.opacity(0.3))
                            
                            // Stress Level (1-5)
                            if let value = stressLevel {
                                LabeledSlider(
                                    label: "Stress Level",
                                    value: Binding(
                                        get: { value },
                                        set: { stressLevel = $0 }
                                    ),
                                    range: 1...5,
                                    step: 1.0
                                )
                            } else {
                                Button(action: { stressLevel = 3 }) {
                                    HStack {
                                        Text("Stress Level")
                                            .font(.headline)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Text("Tap to set")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(.vertical, 12)
                                }
                            }
                            
                            Divider()
                                .background(AppColors.textSecondary.opacity(0.3))
                            
                            // Muscle Soreness (1-5)
                            if let value = muscleSoreness {
                                LabeledSlider(
                                    label: "Muscle Soreness",
                                    value: Binding(
                                        get: { value },
                                        set: { muscleSoreness = $0 }
                                    ),
                                    range: 1...5,
                                    step: 1.0
                                )
                            } else {
                                Button(action: { muscleSoreness = 3 }) {
                                    HStack {
                                        Text("Muscle Soreness")
                                            .font(.headline)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Text("Tap to set")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(.vertical, 12)
                                }
                            }
                            
                            Divider()
                                .background(AppColors.textSecondary.opacity(0.3))
                            
                            // Motivation (1-5)
                            if let value = motivation {
                                LabeledSlider(
                                    label: "Motivation",
                                    value: Binding(
                                        get: { value },
                                        set: { motivation = $0 }
                                    ),
                                    range: 1...5,
                                    step: 1.0
                                )
                            } else {
                                Button(action: { motivation = 3 }) {
                                    HStack {
                                        Text("Motivation")
                                            .font(.headline)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Text("Tap to set")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(.vertical, 12)
                                }
                            }
                            
                            Divider()
                                .background(AppColors.textSecondary.opacity(0.3))
                            
                            // Time Available (0-120 minutes)
                            if let value = timeAvailable {
                                LabeledSlider(
                                    label: "Time Available",
                                    value: Binding(
                                        get: { value },
                                        set: { timeAvailable = $0 }
                                    ),
                                    range: 0...120,
                                    step: 5.0,
                                    valueFormatter: { "\($0) min" }
                                )
                            } else {
                                Button(action: { timeAvailable = 30 }) {
                                    HStack {
                                        Text("Time Available")
                                            .font(.headline)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Text("Tap to set")
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(.vertical, 12)
                                }
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(AppColors.glassMaterial(for: colorScheme))
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal)
                        
                        // Submit button with glassmorphism
                        Button(action: submitCheckIn) {
                            Text("Submit Check-In")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [AppColors.primary, AppColors.primaryDark],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .shadow(color: AppColors.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                                )
                        }
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.glassMaterial(for: colorScheme), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    /// Creates and saves a new check-in, then navigates to the result screen.
    ///
    /// Architecture note: This method converts the local Double state values
    /// to Int as required by the DailyCheckIn model, then adds it to the store.
    /// Haptic feedback provides tactile confirmation of the action.
    private func submitCheckIn() {
        guard let sleep = sleepQuality,
              let stress = stressLevel,
              let soreness = muscleSoreness,
              let motiv = motivation,
              let time = timeAvailable else {
            return
        }
        
        // Create check-in with current values
        let checkIn = DailyCheckIn(
            sleepQuality: Int(sleep),
            stressLevel: Int(stress),
            muscleSoreness: Int(soreness),
            motivation: Int(motiv),
            timeAvailable: Int(time)
        )
        
        // Save to store (this will persist automatically)
        store.addCheckIn(checkIn)
        
        // Provide haptic feedback
        // FIX: Call prepare() before impactOccurred() to avoid Taptic Engine latency
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Dismiss this view (will show result in parent navigation)
        dismiss()
    }
}

