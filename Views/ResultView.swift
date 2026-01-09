import SwiftUI

/// Displays the readiness score and recommendation after a check-in.
///
/// Architecture note: This view is a presentation view that receives a check-in
/// as a parameter. It uses the ReadinessCalculator to compute score and zone,
/// keeping business logic separate from presentation. The view uses a ZStack
/// with a colored background that adapts to the readiness zone.
struct ResultView: View {
    let checkIn: DailyCheckIn
    
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
            .opacity(0.2)  // Subtle background color
    }
    
    var body: some View {
        ZStack {
            // Background color based on zone
            zoneColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Large score display
                    VStack(spacing: 8) {
                        Text("\(score)")
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Readiness Score")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    // Recommendation card
                    VStack(spacing: 16) {
                        Text(recommendation)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // Explanation text based on zone
                        Text(explanation)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    
                    // Date information
                    VStack(spacing: 4) {
                        Text("Check-In Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(checkIn.formattedDate)
                            .font(.headline)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .navigationTitle("Your Results")
        .navigationBarTitleDisplayMode(.inline)
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

