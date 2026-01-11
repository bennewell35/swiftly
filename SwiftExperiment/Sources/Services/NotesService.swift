import Foundation
import Amplify

// MARK: - TEACHING: Data Service Pattern
/// This service manages notes data with both local and remote persistence.
///
/// ARCHITECTURE PATTERN:
/// Services are responsible for:
/// 1. Data fetching (local and remote)
/// 2. Data persistence
/// 3. Business logic for data operations
/// 4. Error handling and state management
///
/// Views should NEVER directly access storage or APIs.
/// Always go through a service layer.
///
/// SUPRAHUMAN EXPECTATION:
/// In production codebases, you'll see this pattern everywhere.
/// Services are injectable, testable, and swappable.
@MainActor
class NotesService: ObservableObject {

    // MARK: - Published State

    /// All notes for the current user
    @Published var notes: [Note] = []

    /// Loading state for async operations
    @Published var isLoading = false

    /// Error message for display
    @Published var errorMessage: String?

    // MARK: - Private Storage

    /// UserDefaults key for local persistence
    private let storageKey = "experiment_notes"

    /// Whether to use mock API (no AWS backend)
    private var useMockAPI = true

    init() {
        loadLocalNotes()
    }

    // MARK: - TEACHING: CRUD Operations

    /// Fetch notes from the backend.
    ///
    /// AMPLIFY API EXPLANATION:
    /// Amplify API can work with either REST or GraphQL.
    /// For this example, we'd use GraphQL with AppSync for:
    /// - Real-time subscriptions
    /// - Offline support with DataStore
    /// - Automatic conflict resolution
    ///
    /// WHY GRAPHQL (via Amplify):
    /// 1. Type-safe queries generated from schema
    /// 2. Fetch only the fields you need
    /// 3. Subscriptions for real-time updates
    /// 4. Works offline with DataStore
    func fetchNotes() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        if useMockAPI {
            // Simulate network delay
            try? await Task.sleep(nanoseconds: 300_000_000)
            // Notes are already loaded from local storage
            return
        }

        // Real Amplify API call would look like:
        // let result = try await Amplify.API.query(request: .list(Note.self))
        // notes = result.get()

        // For now, just use local storage
        loadLocalNotes()
    }

    /// Create a new note.
    ///
    /// TEACHING: Optimistic Updates
    /// For better UX, we add the note locally first (optimistic),
    /// then sync to backend. If backend fails, we roll back.
    ///
    /// REACT COMPARISON:
    /// This is like React Query's optimistic updates or
    /// Redux Toolkit Query's optimistic mutations.
    func createNote(title: String, content: String) async {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Title is required"
            return
        }

        let note = Note(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            createdAt: Date(),
            updatedAt: Date()
        )

        // Optimistic update: Add to local state immediately
        notes.insert(note, at: 0)
        saveLocalNotes()

        if useMockAPI {
            // Mock success
            return
        }

        // Real API call would sync to backend
        // If it fails, we'd need to roll back the optimistic update
    }

    /// Update an existing note.
    ///
    /// TEACHING: Immutability in Swift
    /// Swift structs are value types (immutable by default).
    /// To "update" a note, we create a new note with changed values.
    /// This is safer than mutating objects in place.
    func updateNote(_ note: Note, title: String, content: String) async {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            errorMessage = "Note not found"
            return
        }

        let updatedNote = Note(
            id: note.id,
            title: title.trimmingCharacters(in: .whitespaces),
            content: content.trimmingCharacters(in: .whitespaces),
            createdAt: note.createdAt,
            updatedAt: Date()
        )

        notes[index] = updatedNote
        saveLocalNotes()
    }

    /// Delete a note.
    ///
    /// TEACHING: Array Operations in Swift
    /// - removeAll(where:) removes all elements matching a predicate
    /// - firstIndex(where:) finds the first matching index
    /// - These are similar to filter() and findIndex() in JS
    func deleteNote(_ note: Note) async {
        notes.removeAll { $0.id == note.id }
        saveLocalNotes()
    }

    // MARK: - Local Persistence

    /// Load notes from UserDefaults.
    ///
    /// TEACHING: Codable Protocol
    /// Swift's Codable protocol provides automatic JSON encoding/decoding.
    /// Just declare your struct as Codable, and you get free serialization.
    ///
    /// COMPARISON TO JS:
    /// No need for JSON.stringify() or JSON.parse().
    /// The compiler generates the encoding/decoding code.
    private func loadLocalNotes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            notes = []
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            notes = try decoder.decode([Note].self, from: data)
        } catch {
            print("[Notes] Failed to decode local notes: \(error)")
            notes = []
        }
    }

    /// Save notes to UserDefaults.
    private func saveLocalNotes() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(notes)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("[Notes] Failed to encode notes: \(error)")
        }
    }
}
