import SwiftUI

// MARK: - TEACHING: Form View Pattern
/// LoginView demonstrates form handling in SwiftUI.
///
/// KEY CONCEPTS:
/// - @State for local form fields
/// - @FocusState for keyboard management
/// - Form validation patterns
/// - Async action handling
///
/// REACT COMPARISON:
/// - @State is like useState()
/// - @FocusState is like useRef() for focus management
/// - Unlike React, SwiftUI forms don't need event handlers for every keystroke
struct LoginView: View {

    // MARK: - Environment

    @EnvironmentObject var authService: AuthService

    // MARK: - Local State

    /// TEACHING: @State for Local View State
    /// @State creates a source of truth for value types within this view.
    /// When @State changes, the view re-renders.
    ///
    /// IMPORTANT: @State should be private (owned by this view only).
    /// If you need to share state, use @Binding, @ObservedObject, or @EnvironmentObject.
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUpMode = false

    /// TEACHING: @FocusState for Keyboard Management
    /// Tracks which field is focused. Setting this to nil dismisses the keyboard.
    /// This is the SwiftUI way to handle "next field" and keyboard dismissal.
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case email
        case password
    }

    // MARK: - Computed Properties

    /// TEACHING: Form Validation as Computed Properties
    /// Validation logic lives in computed properties, not event handlers.
    /// This is automatically recalculated when @State changes.
    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6
    }

    private var buttonTitle: String {
        isSignUpMode ? "Create Account" : "Sign In"
    }

    // MARK: - View Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection

                    // Form fields
                    formSection

                    // Error message
                    if let error = authService.errorMessage {
                        errorBanner(message: error)
                    }

                    // Submit button
                    submitButton

                    // Toggle sign up / sign in
                    toggleModeButton
                }
                .padding(24)
            }
            .navigationTitle(isSignUpMode ? "Create Account" : "Welcome Back")
            .navigationBarTitleDisplayMode(.large)
            // TEACHING: Dismiss keyboard when tapping outside fields
            .onTapGesture {
                focusedField = nil
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))

            Text("Swift Experiment")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Learning Swift with AWS Amplify")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }

    /// TEACHING: Form Fields with SwiftUI
    /// SwiftUI's TextField binds directly to @State.
    /// No onChange handlers needed - two-way binding is automatic.
    private var formSection: some View {
        VStack(spacing: 16) {
            // Email field
            VStack(alignment: .leading, spacing: 6) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                TextField("you@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    // TEACHING: Submit handler moves to next field
                    .onSubmit {
                        focusedField = .password
                    }
            }

            // Password field
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                SecureField("Minimum 6 characters", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(isSignUpMode ? .newPassword : .password)
                    .focused($focusedField, equals: .password)
                    .onSubmit {
                        if isFormValid {
                            submitForm()
                        }
                    }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func errorBanner(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
        )
    }

    /// TEACHING: Button with Loading State
    /// The button is disabled while loading and shows the appropriate state.
    private var submitButton: some View {
        Button(action: submitForm) {
            Group {
                if authService.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isFormValid || authService.isLoading)
    }

    private var toggleModeButton: some View {
        Button {
            // TEACHING: withAnimation wraps state changes in animation
            withAnimation(.easeInOut(duration: 0.2)) {
                isSignUpMode.toggle()
                authService.errorMessage = nil
            }
        } label: {
            Text(isSignUpMode ? "Already have an account? Sign in" : "Don't have an account? Sign up")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
    }

    // MARK: - Actions

    /// TEACHING: Async Actions from UI
    /// Task { } creates an async context from synchronous code.
    /// This is needed because button actions can't be async directly.
    private func submitForm() {
        focusedField = nil  // Dismiss keyboard

        Task {
            if isSignUpMode {
                await authService.signUp(email: email, password: password)
            } else {
                await authService.signIn(email: email, password: password)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environmentObject(AuthService())
}
