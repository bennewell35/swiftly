import SwiftUI

// MARK: - TEACHING: List Views with CRUD Operations
/// NotesListView demonstrates list management with SwiftUI.
///
/// KEY CONCEPTS DEMONSTRATED:
/// - List with dynamic data
/// - Swipe actions
/// - Sheet presentation for editing
/// - Pull to refresh
/// - Search filtering
///
/// REACT COMPARISON:
/// - ForEach is like .map() in JSX
/// - .searchable is like a search input + filter logic combined
/// - .refreshable is like pull-to-refresh with async handler
struct NotesListView: View {

    // MARK: - Environment

    @EnvironmentObject var notesService: NotesService

    // MARK: - State

    /// Controls the new note sheet
    @State private var showNewNoteSheet = false

    /// Note being edited (nil = not editing)
    @State private var noteToEdit: Note?

    /// Search query for filtering
    @State private var searchQuery = ""

    // MARK: - Computed Properties

    /// TEACHING: Filtered Lists as Computed Properties
    /// Don't store filtered results in @State.
    /// Compute them from the source of truth + filter criteria.
    private var filteredNotes: [Note] {
        if searchQuery.isEmpty {
            return notesService.notes
        }
        let query = searchQuery.lowercased()
        return notesService.notes.filter {
            $0.title.lowercased().contains(query) ||
            $0.content.lowercased().contains(query)
        }
    }

    // MARK: - View Body

    var body: some View {
        NavigationStack {
            Group {
                if notesService.notes.isEmpty {
                    emptyStateView
                } else {
                    notesList
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewNoteSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // TEACHING: .searchable adds search functionality
            // SwiftUI handles the search bar UI automatically
            .searchable(text: $searchQuery, prompt: "Search notes")
            // TEACHING: .refreshable enables pull-to-refresh
            // The closure must be async - SwiftUI shows the spinner automatically
            .refreshable {
                await notesService.fetchNotes()
            }
            // Sheet for creating new note
            .sheet(isPresented: $showNewNoteSheet) {
                NoteEditorView(mode: .create)
            }
            // Sheet for editing existing note
            // TEACHING: sheet(item:) is better than sheet(isPresented:) when you need data
            .sheet(item: $noteToEdit) { note in
                NoteEditorView(mode: .edit(note))
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Notes",
            systemImage: "note.text",
            description: Text("Create your first note to get started.")
        )
    }

    private var notesList: some View {
        List {
            // TEACHING: ForEach with Identifiable
            // Because Note conforms to Identifiable, we don't need to specify id:
            ForEach(filteredNotes) { note in
                noteRow(note)
                    // TEACHING: Swipe Actions
                    // .swipeActions adds iOS-style swipe gestures
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteNote(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            noteToEdit = note
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// TEACHING: Extracted Row View
    /// For complex list rows, extract to a separate function or view.
    private func noteRow(_ note: Note) -> some View {
        Button {
            noteToEdit = note
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !note.content.isEmpty {
                    Text(note.contentPreview)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Text(note.formattedDate)
                    .font(.caption)
                    .foregroundColor(.tertiary)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Actions

    private func deleteNote(_ note: Note) {
        Task {
            await notesService.deleteNote(note)
        }
    }
}

// MARK: - Preview

#Preview("With Notes") {
    let service = NotesService()
    service.notes = Note.samples

    return NotesListView()
        .environmentObject(service)
}

#Preview("Empty") {
    NotesListView()
        .environmentObject(NotesService())
}
