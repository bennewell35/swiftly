import SwiftUI

// MARK: - TEACHING: Form Editor with Mode Enum
/// NoteEditorView handles both creating and editing notes.
///
/// PATTERN: Mode Enum
/// Using an enum for mode (create vs edit) is cleaner than
/// optional parameters or separate views. It makes the possible
/// states explicit and the compiler enforces handling all cases.
///
/// SUPRAHUMAN EXPECTATION:
/// Production apps often have a single editor view that handles
/// both create and edit. The mode pattern is common and scalable.
struct NoteEditorView: View {

    // MARK: - Mode Enum

    /// TEACHING: Associated Values in Enums
    /// Swift enums can carry data. Here, .edit carries the note being edited.
    /// This is more powerful than JS/TS enums.
    enum Mode: Identifiable {
        case create
        case edit(Note)

        // Required for sheet(item:)
        var id: String {
            switch self {
            case .create:
                return "create"
            case .edit(let note):
                return note.id
            }
        }
    }

    // MARK: - Properties

    let mode: Mode

    // MARK: - Environment

    @EnvironmentObject var notesService: NotesService
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    /// TEACHING: Initializing @State from Props
    /// We need to initialize these from the mode.
    /// The proper way is using init() with State(initialValue:)
    @State private var title: String
    @State private var content: String
    @State private var showDiscardAlert = false

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title
        case content
    }

    // MARK: - Computed Properties

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var originalNote: Note? {
        if case .edit(let note) = mode { return note }
        return nil
    }

    private var navigationTitle: String {
        isEditing ? "Edit Note" : "New Note"
    }

    private var hasChanges: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedContent = content.trimmingCharacters(in: .whitespaces)

        if let original = originalNote {
            return trimmedTitle != original.title || trimmedContent != original.content
        } else {
            return !trimmedTitle.isEmpty || !trimmedContent.isEmpty
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Initializer

    /// TEACHING: Custom Init for @State Initialization
    /// When @State needs to be initialized from parameters, use this pattern.
    /// State(initialValue:) creates the State wrapper with an initial value.
    ///
    /// COMMON MISTAKE:
    /// Trying to assign to _title in the body or using onAppear.
    /// That causes infinite loops or lost edits.
    init(mode: Mode) {
        self.mode = mode

        // Initialize state based on mode
        switch mode {
        case .create:
            _title = State(initialValue: "")
            _content = State(initialValue: "")
        case .edit(let note):
            _title = State(initialValue: note.title)
            _content = State(initialValue: note.content)
        }
    }

    // MARK: - View Body

    var body: some View {
        NavigationStack {
            Form {
                // Title section
                Section {
                    TextField("Note title", text: $title)
                        .font(.headline)
                        .focused($focusedField, equals: .title)
                        .onSubmit {
                            focusedField = .content
                        }
                } header: {
                    Text("Title")
                }

                // Content section
                // TEACHING: TextEditor for Multiline Input
                // TextField is single-line only. Use TextEditor for multiline.
                Section {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .focused($focusedField, equals: .content)
                } header: {
                    Text("Content")
                } footer: {
                    Text("Add details, thoughts, or anything you want to remember.")
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        handleCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSave()
                    }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
                }
            }
            // TEACHING: Keyboard Toolbar
            // Add buttons above the keyboard for better UX
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            // Discard confirmation
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("You have unsaved changes that will be lost.")
            }
            // Auto-focus title on appear
            .onAppear {
                if !isEditing {
                    focusedField = .title
                }
            }
            // TEACHING: Interactive Dismiss Prevention
            // Prevent accidental dismissal when there are unsaved changes
            .interactiveDismissDisabled(hasChanges)
        }
    }

    // MARK: - Actions

    private func handleCancel() {
        if hasChanges {
            showDiscardAlert = true
        } else {
            dismiss()
        }
    }

    private func handleSave() {
        Task {
            if let original = originalNote {
                await notesService.updateNote(original, title: title, content: content)
            } else {
                await notesService.createNote(title: title, content: content)
            }
            dismiss()
        }
    }
}

// MARK: - Previews

#Preview("Create") {
    NoteEditorView(mode: .create)
        .environmentObject(NotesService())
}

#Preview("Edit") {
    NoteEditorView(mode: .edit(Note.sample))
        .environmentObject(NotesService())
}
