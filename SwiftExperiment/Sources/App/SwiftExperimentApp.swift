import SwiftUI
import Amplify

// MARK: - TEACHING: App Entry Point
/// @main marks this as the application entry point.
/// In SwiftUI, the App protocol replaces UIApplicationDelegate.
///
/// KEY SWIFT CONCEPT: Property Wrappers
/// - @main: Compiler directive that generates the entry point
/// - @StateObject: Creates and OWNS a reference type (class) for the view's lifetime
/// - @EnvironmentObject: Reads a shared object from the environment (doesn't own it)
///
/// REACT/JS MENTAL MODEL COMPARISON:
/// - @StateObject is like creating a context provider at the root
/// - @EnvironmentObject is like useContext() in child components
/// - Unlike React, SwiftUI automatically re-renders when @Published properties change
@main
struct SwiftExperimentApp: App {
    // TEACHING: @StateObject ensures AuthService lives for the entire app lifetime.
    // This is the OWNER of the object. Only one view should use @StateObject for a given object.
    // All child views should use @EnvironmentObject to ACCESS (not own) this same instance.
    @StateObject private var authService = AuthService()
    @StateObject private var notesService = NotesService()

    init() {
        // TEACHING: Configure Amplify on app launch
        // This is similar to initializing Firebase or other SDKs in React Native
        configureAmplify()
    }

    var body: some Scene {
        WindowGroup {
            // TEACHING: ContentView is wrapped and given access to services
            // .environmentObject() injects these into the SwiftUI environment
            // Any descendant view can then access them with @EnvironmentObject
            RootView()
                .environmentObject(authService)
                .environmentObject(notesService)
        }
    }

    /// Configure AWS Amplify with local configuration.
    ///
    /// AMPLIFY EXPLANATION:
    /// - Amplify Auth uses Amazon Cognito for user authentication
    /// - Cognito provides: Sign up, Sign in, Password reset, MFA, Social login
    /// - This mirrors SupraHuman's production auth flow
    ///
    /// WHY AMPLIFY AUTH:
    /// 1. Enterprise-grade security (Cognito is HIPAA compliant)
    /// 2. Handles token refresh automatically
    /// 3. Supports federated identity (Google, Apple, Facebook)
    /// 4. Built-in user management console in AWS
    private func configureAmplify() {
        do {
            // TEACHING: In production, this reads from amplifyconfiguration.json
            // For this experiment, we'll check if config exists and configure accordingly
            try Amplify.configure()
            print("[Amplify] Successfully configured")
        } catch {
            // TEACHING: Fail gracefully in development
            // In production, you might show an alert or retry
            print("[Amplify] Configuration failed: \(error)")
            print("[Amplify] Running in mock mode for development")
        }
    }
}
