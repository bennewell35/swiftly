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

    init() {
        // Check current authentication status on app launch
        checkSession()
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
    func checkSession() {
        Task {
            isLoading = true
            defer { isLoading = false }  // TEACHING: defer runs when scope exits

            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                isAuthenticated = session.isSignedIn
                if isAuthenticated {
                    let user = try await Amplify.Auth.getCurrentUser()
                    currentUser = user
                } else {
                    isAuthenticated = false
                    currentUser = nil
                }
            } catch {
                print("[Auth] Session check failed: \(error)")
                isAuthenticated = false
                currentUser = nil
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

        // Amplify Auth sign in
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
            errorMessage = error.errorDescription ?? "Sign in failed"
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
        }
    }

    /// Sign up a new user.
    ///
    /// AMPLIFY SIGN UP FLOW:
    /// 1. Create user in Cognito user pool
    /// 2. Cognito sends verification email/SMS
    /// 3. User confirms with verification code (call confirmSignUp)
    /// 4. User can then sign in
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Input validation
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            return
        }

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
            case .confirmUser(let details):
                // User needs to confirm with verification code
                errorMessage = nil  // Clear any previous errors
                // Note: The UI should handle showing the confirmation screen
                // This method doesn't throw, so the caller knows to proceed to confirmation
            case .done:
                // Auto-confirmed (unlikely in production, but possible)
                // Proceed to sign in
                await signIn(email: email, password: password)
            }
        } catch let error as AuthError {
            errorMessage = error.errorDescription ?? "Sign up failed"
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
        }
    }

    /// Confirm sign up with verification code.
    ///
    /// AMPLIFY CONFIRMATION FLOW:
    /// 1. User receives verification code via email/SMS
    /// 2. User enters code in UI
    /// 3. This method confirms the user account
    /// 4. User can then sign in
    func confirmSignUp(email: String, confirmationCode: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Input validation
        guard !email.isEmpty, !confirmationCode.isEmpty else {
            errorMessage = "Email and confirmation code are required"
            return
        }

        do {
            let result = try await Amplify.Auth.confirmSignUp(
                for: email,
                confirmationCode: confirmationCode
            )
            if result.isSignUpComplete {
                // Confirmation successful, user can now sign in
                errorMessage = nil
            } else {
                errorMessage = "Confirmation incomplete"
            }
        } catch let error as AuthError {
            errorMessage = error.errorDescription ?? "Confirmation failed"
        } catch {
            errorMessage = "Confirmation failed: \(error.localizedDescription)"
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

        do {
            _ = try await Amplify.Auth.signOut()
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
