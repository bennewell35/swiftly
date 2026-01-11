import SwiftUI

// MARK: - TEACHING: Root Navigation Controller
/// RootView controls the main navigation based on authentication state.
///
/// NAVIGATION PATTERN:
/// SwiftUI offers multiple navigation patterns:
/// 1. NavigationStack (iOS 16+) - for hierarchical navigation
/// 2. TabView - for tab-based navigation
/// 3. Sheets/Modals - for temporary overlays
/// 4. State-based switching - for auth flows (used here)
///
/// WHY STATE-BASED FOR AUTH:
/// Auth state is fundamentally different from navigation.
/// When you log out, you don't want to "go back" - you want
/// to completely switch contexts. State-based switching makes this clear.
///
/// REACT COMPARISON:
/// This is like having separate route trees for authenticated
/// and unauthenticated users in React Router.
struct RootView: View {

    // MARK: - Environment

    /// TEACHING: @EnvironmentObject reads from the environment.
    /// The object must have been injected by a parent with .environmentObject()
    /// This is SwiftUI's built-in dependency injection.
    @EnvironmentObject var authService: AuthService

    // MARK: - View Body

    /// TEACHING: View Body
    /// The body property is computed every time the view needs to re-render.
    /// SwiftUI calls this automatically when:
    /// - @State changes
    /// - @Published properties in @ObservedObject/@EnvironmentObject change
    /// - Parent view re-renders with new data
    ///
    /// IMPORTANT: body should be FAST and PURE.
    /// No side effects, no API calls, no heavy computation.
    var body: some View {
        Group {
            if authService.isLoading {
                // Show loading while checking auth status
                loadingView
            } else if authService.isAuthenticated {
                // User is logged in - show main app
                DashboardView()
                    .transition(.opacity)
            } else {
                // User is not logged in - show auth flow
                LoginView()
                    .transition(.opacity)
            }
        }
        // TEACHING: Animation modifier applies to all state changes in this view
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
        .animation(.easeInOut(duration: 0.2), value: authService.isLoading)
    }

    // MARK: - Subviews

    /// Loading spinner shown while checking auth.
    ///
    /// TEACHING: Extracting Subviews
    /// Complex views should be broken into smaller computed properties or separate structs.
    /// This improves readability and allows SwiftUI to optimize re-renders.
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - TEACHING: SwiftUI Previews
/// Previews let you design views without running the full app.
/// This is similar to Storybook in React.
///
/// COMMON MISTAKE:
/// Forgetting to inject required environment objects.
/// The preview will crash with a cryptic error.
#Preview("Authenticated") {
    let auth = AuthService()
    auth.isAuthenticated = true
    return RootView()
        .environmentObject(auth)
        .environmentObject(NotesService())
}

#Preview("Unauthenticated") {
    RootView()
        .environmentObject(AuthService())
        .environmentObject(NotesService())
}
