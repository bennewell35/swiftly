import SwiftUI

// MARK: - TEACHING: Tab-Based Navigation
/// DashboardView is the main authenticated screen using TabView.
///
/// NAVIGATION HIERARCHY:
/// - TabView for top-level sections
/// - NavigationStack within each tab for hierarchical navigation
///
/// KEY CONCEPT: Each tab has its OWN navigation stack.
/// Switching tabs preserves the navigation state of each tab.
///
/// SUPRAHUMAN EXPECTATION:
/// Production apps typically use this pattern for main navigation.
/// TabView + NavigationStack is the standard iOS navigation model.
struct DashboardView: View {

    // MARK: - Environment

    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var notesService: NotesService

    // MARK: - State

    /// TEACHING: Tab Selection State
    /// Storing the selected tab in @State allows programmatic tab switching.
    @State private var selectedTab = 0

    /// Controls the logout confirmation alert
    @State private var showLogoutConfirmation = false

    // MARK: - View Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            homeTab
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Notes Tab
            NotesListView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(1)

            // Settings Tab
            settingsTab
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .tint(.blue)
        // TEACHING: .task is the SwiftUI way to run async code on view appear
        // It automatically cancels when the view disappears
        .task {
            await notesService.fetchNotes()
        }
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome header
                    welcomeCard

                    // Quick stats
                    statsSection

                    // Recent notes
                    recentNotesSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(authService.currentUser?.username ?? "User")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)

            HStack(spacing: 16) {
                statCard(title: "Notes", value: "\(notesService.notes.count)", icon: "note.text", color: .blue)
                statCard(title: "This Week", value: "\(notesThisWeek)", icon: "calendar", color: .purple)
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 5)
        )
    }

    /// TEACHING: Computed Properties for Derived Data
    /// Don't store derived data in @State - compute it from the source of truth.
    private var notesThisWeek: Int {
        let weekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        return notesService.notes.filter { $0.createdAt >= weekAgo }.count
    }

    private var recentNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Notes")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    selectedTab = 1  // Switch to Notes tab
                }
                .font(.subheadline)
            }

            if notesService.notes.isEmpty {
                emptyNotesCard
            } else {
                // Show last 3 notes
                ForEach(notesService.notes.prefix(3)) { note in
                    NoteRowView(note: note)
                }
            }
        }
    }

    private var emptyNotesCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No notes yet")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Create your first note") {
                selectedTab = 1
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 5)
        )
    }

    // MARK: - Settings Tab

    private var settingsTab: some View {
        NavigationStack {
            List {
                // Account section
                Section("Account") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(authService.currentUser?.username ?? "User")
                                .font(.headline)
                            Text("Signed in")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // App info section
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "Experiment")
                    Link("View on GitHub", destination: URL(string: "https://github.com")!)
                }

                // Sign out section
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            // TEACHING: Confirmation Dialogs
            // Use confirmationDialog for destructive actions.
            // This is better UX than immediate action.
            .confirmationDialog(
                "Are you sure you want to sign out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authService.signOut()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

// MARK: - Note Row View

/// A compact note display for lists.
struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)

            Text(note.contentPreview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(note.formattedDate)
                .font(.caption)
                .foregroundColor(.tertiary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 5)
        )
    }
}

// MARK: - Preview

#Preview {
    let auth = AuthService()
    auth.isAuthenticated = true
    auth.currentUser = MockAuthUser(username: "demo@example.com")

    let notes = NotesService()
    notes.notes = Note.samples

    return DashboardView()
        .environmentObject(auth)
        .environmentObject(notes)
}
