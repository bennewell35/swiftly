import Foundation
import Amplify
import AWSCognitoAuthPlugin

// MARK: - TEACHING: ObservableObject Protocol
/// ObservableObject is the SwiftUI pattern for creating observable state containers.
///
/// KEY CONCEPT: @Published
/// When a @Published property changes, ALL views observing this object re-render.
/// This is automatic - no need to call setState() or forceUpdate().
///
/// REACT COMPARISON:
/// - ObservableObject is like a Redux store or React Context
/// - @Published is like state that triggers re-renders
/// - @EnvironmentObject is like useSelector() or useContext()
///
/// THREAD SAFETY:
/// @MainActor ensures all property updates happen on the main thread.
/// This is CRITICAL - UI updates from background threads crash the app.
@MainActor
class AuthService: ObservableObject {

    // MARK: - TEACHING: Published Properties
    /// @Published automatically notifies SwiftUI when these values change.
    /// Any view using @EnvironmentObject will re-render when these change.

    /// Current authentication state
    @Published var isAuthenticated = false

    /// Current user information (nil if not logged in)
    @Published var currentUser: AuthUser?

    /// Loading state for async operations
    @Published var isLoading = false

    /// Error message to display to user
    @Published var errorMessage: String?

    // MARK: - TEACHING: Mock Mode
    /// In development without AWS config, we use mock authentication.
    /// This allows testing the full UI flow without backend setup.
    private var useMockAuth = true

    init() {
        // Check if we have real Amplify configuration
        checkAuthStatus()
    }

    // MARK: - Public API

    /// Check current authentication status on app launch.
    ///
    /// TEACHING: Task { } and async/await
    /// - Task creates a new asynchronous context
    /// - async/await is Swift's way to handle promises (like JS async/await)
    /// - Unlike JS, Swift async functions are type-safe and cancellable
    ///
    /// COMMON MISTAKE FROM JS:
    /// You can't call async functions directly in init() or body.
    /// You must wrap them in Task { } or use .task { } modifier on views.
    func checkAuthStatus() {
        Task {
            isLoading = true
            defer { isLoading = false }  // TEACHING: defer runs when scope exits

            if useMockAuth {
                // Mock: Check if we have a stored session
                isAuthenticated = UserDefaults.standard.bool(forKey: "mockIsAuthenticated")
                if isAuthenticated {
                    currentUser = MockAuthUser(username: "demo@example.com")
                }
                return
            }

            // Real Amplify Auth
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                isAuthenticated = session.isSignedIn
                if isAuthenticated {
                    let user = try await Amplify.Auth.getCurrentUser()
                    currentUser = user
                }
            } catch {
                print("[Auth] Session check failed: \(error)")
                isAuthenticated = false
            }
        }
    }

    /// Sign in with email and password.
    ///
    /// TEACHING: Error Handling in Swift
    /// Swift uses do-try-catch, similar to try-catch in JS.
    /// The key difference: Swift errors are typed and the compiler
    /// forces you to handle them (no silent failures).
    ///
    /// AMPLIFY AUTH FLOW:
    /// 1. User enters credentials
    /// 2. Cognito validates against user pool
    /// 3. Returns JWT tokens (id, access, refresh)
    /// 4. Tokens are stored securely in Keychain
    /// 5. Automatic refresh when tokens expire
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Input validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            return
        }

        if useMockAuth {
            // Mock authentication for development
            try? await Task.sleep(nanoseconds: 500_000_000)  // Simulate network delay
            if password.count >= 6 {
                isAuthenticated = true
                currentUser = MockAuthUser(username: email)
                UserDefaults.standard.set(true, forKey: "mockIsAuthenticated")
            } else {
                errorMessage = "Invalid credentials (mock: password must be 6+ chars)"
            }
            return
        }

        // Real Amplify Auth
        do {
            let result = try await Amplify.Auth.signIn(username: email, password: password)
            if result.isSignedIn {
                isAuthenticated = true
                let user = try await Amplify.Auth.getCurrentUser()
                currentUser = user
            } else {
                // Handle MFA or additional steps
                errorMessage = "Additional verification required"
            }
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
    }

    /// Sign up a new user.
    ///
    /// AMPLIFY SIGN UP FLOW:
    /// 1. Create user in Cognito user pool
    /// 2. Cognito sends verification email/SMS
    /// 3. User confirms with verification code
    /// 4. User can then sign in
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        if useMockAuth {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if password.count >= 8 {
                errorMessage = nil
                // In mock mode, auto-confirm and sign in
                isAuthenticated = true
                currentUser = MockAuthUser(username: email)
                UserDefaults.standard.set(true, forKey: "mockIsAuthenticated")
            } else {
                errorMessage = "Password must be at least 8 characters"
            }
            return
        }

        // Real Amplify Auth
        do {
            let options = AuthSignUpRequest.Options(
                userAttributes: [AuthUserAttribute(.email, value: email)]
            )
            let result = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            switch result.nextStep {
            case .confirmUser:
                errorMessage = "Please check your email for verification code"
            case .done:
                // Auto-confirmed, proceed to sign in
                await signIn(email: email, password: password)
            }
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
    }

    /// Sign out the current user.
    ///
    /// TEACHING: Global vs Local Sign Out
    /// - Local: Clears tokens on this device only
    /// - Global: Invalidates all sessions across all devices
    func signOut() async {
        isLoading = true
        defer { isLoading = false }

        if useMockAuth {
            isAuthenticated = false
            currentUser = nil
            UserDefaults.standard.set(false, forKey: "mockIsAuthenticated")
            return
        }

        do {
            _ = await Amplify.Auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            print("[Auth] Sign out failed: \(error)")
            // Still clear local state even if API fails
            isAuthenticated = false
            currentUser = nil
        }
    }
}

// MARK: - Mock Auth User
/// Mock implementation for development without AWS backend.
struct MockAuthUser: AuthUser {
    let username: String
    var userId: String { username }
}
