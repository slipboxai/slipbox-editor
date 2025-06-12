import XCTest
@testable import SlipboxEditor

final class SlipboxEditorTests: XCTestCase {
    
    func testEditorCommandCreation() throws {
        let command = EditorCommand(action: .bold, data: nil)
        XCTAssertEqual(command.action, .bold)
        XCTAssertNil(command.data)
    }
    
    func testEditorCommandWithData() throws {
        let data = ["text": AnyCodable("Hello World")]
        let command = EditorCommand(action: .insertText, data: data)
        XCTAssertEqual(command.action, .insertText)
        XCTAssertNotNil(command.data)
    }
    
    func testAnyCodableEncoding() throws {
        let anyCodable = AnyCodable("test string")
        let encoder = JSONEncoder()
        let data = try encoder.encode(anyCodable)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        
        // We can't directly compare AnyCodable values, so we encode both and compare
        let originalData = try encoder.encode(anyCodable)
        let decodedData = try encoder.encode(decoded)
        XCTAssertEqual(originalData, decodedData)
    }
    
    func testEditorStateCreation() throws {
        let state = EditorState(
            html: "<p>Test content</p>",
            selection: NSRange(location: 0, length: 5),
            formats: ["bold": true]
        )
        
        XCTAssertEqual(state.html, "<p>Test content</p>")
        XCTAssertEqual(state.selection?.location, 0)
        XCTAssertEqual(state.selection?.length, 5)
        XCTAssertEqual(state.formats["bold"], true)
    }
    
    @MainActor
    func testEditorModelInitialization() throws {
        let model = WYSIWYGEditorModel()
        
        XCTAssertEqual(model.htmlContent, "")
        XCTAssertEqual(model.plainText, "")
        XCTAssertFalse(model.isReady)
        XCTAssertNil(model.selectedRange)
    }
    
    func testSlipboxEditorVersion() throws {
        XCTAssertEqual(SlipboxEditor.version, "1.0.0")
        XCTAssertEqual(SlipboxEditor.name, "SlipboxEditor")
        XCTAssertFalse(SlipboxEditor.description.isEmpty)
    }
}