import SwiftUI
import Charts

/// Displays check-in history with a trend chart.
///
/// Architecture note: This view observes the CheckInStore to automatically
/// update when new check-ins are added. It uses Swift Charts (iOS 16+) to
/// visualize the readiness score trend over time. The view shows the last
/// 7 check-ins by default, sorted by date.
struct HistoryView: View {
    @ObservedObject var store: CheckInStore
    
    // Get the most recent 7 check-ins, sorted by date (oldest first for chart)
    // Architecture note: We reverse the array because charts typically display
    // time series with oldest data on the left, newest on the right.
    private var recentCheckIns: [DailyCheckIn] {
        store.recentCheckIns(count: 7).reversed()
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if recentCheckIns.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    /// Main content when check-ins exist.
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Chart section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Readiness Trend")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    // Swift Charts line chart
                    // Architecture note: Charts automatically handles date formatting,
                    // axis labels, and adapts to dark mode. We use LineMark to connect
                    // data points, and AreaMark to fill below the line for visual appeal.
                    Chart {
                        ForEach(recentCheckIns) { checkIn in
                            LineMark(
                                x: .value("Date", checkIn.date, unit: .day),
                                y: .value("Score", ReadinessCalculator.calculateScore(for: checkIn))
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.catmullRom)  // Smooth curve
                            
                            AreaMark(
                                x: .value("Date", checkIn.date, unit: .day),
                                y: .value("Score", ReadinessCalculator.calculateScore(for: checkIn))
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)
                        }
                    }
                    .frame(height: 200)
                    .chartYScale(domain: 0...100)  // Fixed scale for consistency
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month().day(), centered: true)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .padding()
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
                
                // List of check-ins
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Check-Ins")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(recentCheckIns.reversed()) { checkIn in
                        CheckInRowView(checkIn: checkIn)
                    }
                }
                
                Spacer()
                    .frame(height: 20)
            }
            .padding(.vertical)
        }
    }
    
    /// Empty state when no check-ins exist yet.
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Check-Ins Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Complete your first daily check-in to see your readiness history here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A single row in the history list displaying a check-in's details.
///
/// Architecture note: This is a small subview extracted for clarity.
/// It displays the date, score, and recommendation for a single check-in.
struct CheckInRowView: View {
    let checkIn: DailyCheckIn
    
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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(checkIn.formattedDate)
                    .font(.headline)
                
                Text(recommendation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(zoneColor)
                
                Text("score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
}

