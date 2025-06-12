import SwiftUI
import WebKit

@MainActor
public class WYSIWYGEditorModel: ObservableObject {
    @Published public var htmlContent: String = ""
    @Published public var plainText: String = ""
    @Published public var isReady: Bool = false
    @Published public var selectedRange: NSRange?

    public let page: WebPage

    public init() {
        self.page = WebPage()
        loadEditorHTML()
        observePage()
    }

    private func loadEditorHTML() {
        // Load bundled Quill HTML
        if let url = Bundle.module.url(
            forResource: "editor", withExtension: "html", subdirectory: "SlipboxEditor/Resources")
        {
            if let html = try? String(contentsOf: url) {
                page.load(html: html, baseURL: url.deletingLastPathComponent())
            }
        }
    }

    private func observePage() {
        // Observe content changes from JS bridge
        // You may need to set up a polling or JS callback mechanism
    }

    public func executeCommand(_ command: EditorCommand) async throws {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(command)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        let js = "window.editorBridge.executeCommand(\(jsonString))"
        _ = try await page.callJavaScript(js)
    }

    public func setContent(_ html: String) async throws {
        let command = EditorCommand(
            action: .setContent,
            data: ["html": AnyCodable(html)]
        )
        try await executeCommand(command)
    }

    public func getContent() async throws {
        let command = EditorCommand(action: .getContent, data: nil)
        try await executeCommand(command)
    }
}

// MARK: - Editor State Persistence
public struct EditorState: Codable {
    public let html: String
    public let selection: NSRange?
    public let formats: [String: Bool]
    public init(html: String, selection: NSRange?, formats: [String: Bool]) {
        self.html = html
        self.selection = selection
        self.formats = formats
    }
}

extension WYSIWYGEditorModel {
    public func saveState() -> EditorState {
        EditorState(
            html: htmlContent,
            selection: selectedRange,
            formats: [:]
        )
    }
    public func restoreState(_ state: EditorState) async throws {
        try await setContent(state.html)
    }
}
