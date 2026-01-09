import SwiftUI

/// Displays the readiness score and recommendation after a check-in.
///
/// Architecture note: This view is a presentation view that receives a check-in
/// as a parameter. It uses the ReadinessCalculator to compute score and zone,
/// keeping business logic separate from presentation. The view uses a ZStack
/// with a colored background that adapts to the readiness zone.
struct ResultView: View {
    let checkIn: DailyCheckIn
    @Environment(\.colorScheme) var colorScheme
    
    // Compute score and zone from the check-in
    // Architecture note: These are computed properties that call the calculator.
    // They're not stored as @State because they're derived from the checkIn,
    // which doesn't change once the view is created.
    private var score: Int {
        ReadinessCalculator.calculateScore(for: checkIn)
    }
    
    private var zone: ReadinessZone {
        ReadinessCalculator.zone(for: score)
    }
    
    private var recommendation: String {
        ReadinessCalculator.recommendation(for: zone)
    }
    
    private var zoneColor: Color {
        ReadinessCalculator.color(for: zone)
    }
    
    var body: some View {
        ZStack {
            // Professional gradient background
            AppColors.background(for: colorScheme)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Large score display with glassmorphism
                    VStack(spacing: 12) {
                        Text("\(score)")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [zoneColor, zoneColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: zoneColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("Readiness Score")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(0.5)
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(AppColors.glassMaterial(for: colorScheme))
                            .shadow(color: .black.opacity(0.1), radius: 30, x: 0, y: 15)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [zoneColor.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .padding(.horizontal)
                    
                    // Recommendation card with enhanced glassmorphism
                    VStack(spacing: 20) {
                        Text(recommendation)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .tracking(0.3)
                        
                        // Explanation text based on zone
                        Text(explanation)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 8)
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(AppColors.glassMaterial(for: colorScheme))
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(zoneColor.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Date information with subtle styling
                    VStack(spacing: 6) {
                        Text("Check-In Date")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .tracking(1.0)
                            .textCase(.uppercase)
                        
                        Text(checkIn.formattedDate)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(
                        Capsule()
                            .fill(AppColors.glassMaterial(for: colorScheme))
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationTitle("Your Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.glassMaterial(for: colorScheme), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    /// Returns explanation text based on the readiness zone.
    private var explanation: String {
        switch zone {
        case .trainHard:
            return "You're feeling great! This is an ideal day for intense training or challenging workouts."
        case .trainModerate:
            return "You're in good shape. A moderate workout would be appropriate today - listen to your body."
        case .recovery:
            return "Your body is signaling that recovery is needed. Consider rest, light stretching, or a gentle walk."
        }
    }
}

