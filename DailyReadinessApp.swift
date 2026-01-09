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
    @Environment(\.colorScheme) var colorScheme
    @State private var showCheckIn = false
    @State private var showResult = false
    @State private var todaysCheckIn: DailyCheckIn?
    
    var body: some View {
        ZStack {
            // Professional background for entire app
            AppColors.background(for: colorScheme)
                .ignoresSafeArea()
            
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
            .tint(AppColors.primary)
        }
        .sheet(isPresented: $showCheckIn) {
            CheckInView(store: store)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground {
                    // Override default white sheet background with professional gradient
                    AppColors.background(for: colorScheme)
                        .ignoresSafeArea(.all)
                }
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
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primary)
                            }
                        }
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground {
                    // Override default white sheet background with professional gradient
                    AppColors.background(for: colorScheme)
                        .ignoresSafeArea(.all)
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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background(for: colorScheme)
                    .ignoresSafeArea()
                
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
            }
            .navigationTitle("Daily Readiness")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.glassMaterial(for: colorScheme), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !hasCheckInToday {
                        Button(action: { showCheckIn = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
        }
    }
}

/// Card displaying today's readiness result with glassmorphism.
struct TodayResultCard: View {
    let checkIn: DailyCheckIn
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
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
        Button(action: onTap) {
            VStack(spacing: 24) {
                Text("Today's Readiness")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .tracking(1.0)
                    .textCase(.uppercase)
                
                Text("\(score)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [zoneColor, zoneColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: zoneColor.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text(recommendation)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Tap to view details")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 48)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppColors.glassMaterial(for: colorScheme))
                    .shadow(color: .black.opacity(0.1), radius: 30, x: 0, y: 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [zoneColor.opacity(0.4), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

/// Prompt to complete today's check-in with glassmorphism.
struct EmptyCheckInPrompt: View {
    let onTap: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColors.primary.opacity(0.3), radius: 15, x: 0, y: 8)
            
            VStack(spacing: 12) {
                Text("Ready to Check In?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Answer 5 quick questions to get your daily readiness score and training recommendation.")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal)
            
            Button(action: onTap) {
                Text("Start Check-In")
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
            .padding(.horizontal)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(AppColors.glassMaterial(for: colorScheme))
                .shadow(color: .black.opacity(0.1), radius: 30, x: 0, y: 15)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
        )
    }
}

