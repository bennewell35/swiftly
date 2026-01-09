import SwiftUI

/// The main app entry point for Daily Readiness.
///
/// Architecture note: This is where the app's lifecycle begins. We use @StateObject
/// to create a single instance of CheckInStore that persists for the app's lifetime.
/// This ensures all views share the same data store, maintaining consistency.
///
/// Navigation structure:
/// - TabView for main navigation (Check-In and History tabs)
/// - NavigationStack for hierarchical navigation within each tab
/// - Sheet presentation for the check-in form
@main
struct DailyReadinessApp: App {
    // Architecture note: @StateObject creates and owns the CheckInStore instance.
    // This is different from @ObservedObject, which is for references to objects
    // created elsewhere. Since this is the root, we create the store here and pass
    // it down to child views via environment or direct injection.
    @StateObject private var store = CheckInStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                // Architecture note: .environmentObject makes the store available
                // to all child views via @EnvironmentObject, avoiding prop drilling.
        }
    }
}

/// Main tab-based navigation structure.
///
/// Architecture note: We use a TabView to provide bottom tab navigation between
/// the main sections. This is a common iOS pattern. The Check-In tab shows either
/// the check-in form or the result, depending on whether a check-in exists today.
struct MainTabView: View {
    @EnvironmentObject var store: CheckInStore
    @State private var showCheckIn = false
    @State private var showResult = false
    @State private var todaysCheckIn: DailyCheckIn?
    
    var body: some View {
        TabView {
            // Check-In Tab
            CheckInHomeView(
                showCheckIn: $showCheckIn,
                showResult: $showResult,
                todaysCheckIn: $todaysCheckIn
            )
            .tabItem {
                Label("Check-In", systemImage: "checkmark.circle.fill")
            }
            
            // History Tab
            HistoryView(store: store)
                .tabItem {
                    Label("History", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .sheet(isPresented: $showCheckIn) {
            CheckInView(store: store)
                .onDisappear {
                    // When check-in sheet dismisses, check if we should show result
                    if let today = store.checkIns.first, today.isToday {
                        todaysCheckIn = today
                        showResult = true
                    }
                }
        }
        .sheet(isPresented: $showResult) {
            if let checkIn = todaysCheckIn {
                NavigationStack {
                    ResultView(checkIn: checkIn)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showResult = false
                                }
                            }
                        }
                }
            }
        }
        .onAppear {
            // Check if there's a check-in for today on app launch
            if let today = store.checkIns.first, today.isToday {
                todaysCheckIn = today
            }
        }
    }
}

/// Home view for the Check-In tab.
///
/// Architecture note: This view decides whether to show the check-in form button
/// or the today's result, based on whether a check-in exists for today.
struct CheckInHomeView: View {
    @EnvironmentObject var store: CheckInStore
    @Binding var showCheckIn: Bool
    @Binding var showResult: Bool
    @Binding var todaysCheckIn: DailyCheckIn?
    
    private var hasCheckInToday: Bool {
        store.hasCheckInForToday()
    }
    
    private var todaysResult: DailyCheckIn? {
        store.checkIns.first { $0.isToday }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    if hasCheckInToday, let checkIn = todaysResult {
                        // Show today's result
                        TodayResultCard(checkIn: checkIn) {
                            showResult = true
                            todaysCheckIn = checkIn
                        }
                    } else {
                        // Show prompt to check in
                        EmptyCheckInPrompt {
                            showCheckIn = true
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Daily Readiness")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !hasCheckInToday {
                        Button(action: { showCheckIn = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
        }
    }
}

/// Card displaying today's readiness result.
struct TodayResultCard: View {
    let checkIn: DailyCheckIn
    let onTap: () -> Void
    
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
            .opacity(0.2)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 24) {
                Text("Today's Readiness")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(score)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(recommendation)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Tap to view details")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(zoneColor)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Prompt to complete today's check-in.
struct EmptyCheckInPrompt: View {
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Ready to Check In?")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Answer 5 quick questions to get your daily readiness score and training recommendation.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onTap) {
                Text("Start Check-In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.blue)
                    )
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

