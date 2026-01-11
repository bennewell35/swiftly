import XCTest
@testable import SwiftExperiment

// TEACHING: XCTest Framework
// XCTest is Swift's built-in testing framework.
// Tests are methods that start with "test" in classes that inherit XCTestCase.

final class NoteTests: XCTestCase {

    // MARK: - Model Tests

    /// Test that Note initializes with default values correctly
    func testNoteInitialization() {
        let note = Note(title: "Test Note", content: "Test content")

        XCTAssertFalse(note.id.isEmpty, "ID should not be empty")
        XCTAssertEqual(note.title, "Test Note")
        XCTAssertEqual(note.content, "Test content")
        XCTAssertNotNil(note.createdAt)
        XCTAssertNotNil(note.updatedAt)
    }

    /// Test that Note is Equatable
    func testNoteEquatable() {
        let id = "test-id"
        let date = Date()

        let note1 = Note(id: id, title: "Test", content: "Content", createdAt: date, updatedAt: date)
        let note2 = Note(id: id, title: "Test", content: "Content", createdAt: date, updatedAt: date)
        let note3 = Note(id: "different-id", title: "Test", content: "Content", createdAt: date, updatedAt: date)

        XCTAssertEqual(note1, note2, "Notes with same values should be equal")
        XCTAssertNotEqual(note1, note3, "Notes with different IDs should not be equal")
    }

    /// Test contentPreview computed property
    func testContentPreview() {
        // Empty content
        let emptyNote = Note(title: "Test", content: "")
        XCTAssertEqual(emptyNote.contentPreview, "No content")

        // Short content
        let shortNote = Note(title: "Test", content: "Short content")
        XCTAssertEqual(shortNote.contentPreview, "Short content")

        // Long content (should be truncated)
        let longContent = String(repeating: "a", count: 150)
        let longNote = Note(title: "Test", content: longContent)
        XCTAssertTrue(longNote.contentPreview.hasSuffix("..."))
        XCTAssertLessThanOrEqual(longNote.contentPreview.count, 103) // 100 + "..."
    }

    /// Test formattedDate computed property
    func testFormattedDate() {
        let note = Note(title: "Test", content: "")

        // Should return a non-empty formatted string
        XCTAssertFalse(note.formattedDate.isEmpty)
    }

    // MARK: - Codable Tests

    /// Test that Note can be encoded to and decoded from JSON
    func testNoteCodable() throws {
        let original = Note(
            id: "test-123",
            title: "Codable Test",
            content: "Testing JSON encoding",
            createdAt: Date(timeIntervalSince1970: 1704067200), // Jan 1, 2024
            updatedAt: Date(timeIntervalSince1970: 1704067200)
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Note.self, from: data)

        XCTAssertEqual(original.id, decoded.id)
        XCTAssertEqual(original.title, decoded.title)
        XCTAssertEqual(original.content, decoded.content)
    }

    // MARK: - Sample Data Tests

    /// Test that sample data is valid
    func testSampleData() {
        XCTAssertFalse(Note.samples.isEmpty, "Samples should not be empty")

        for sample in Note.samples {
            XCTAssertFalse(sample.title.isEmpty, "Sample title should not be empty")
            XCTAssertFalse(sample.id.isEmpty, "Sample ID should not be empty")
        }
    }
}
