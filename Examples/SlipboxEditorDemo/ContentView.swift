import SlipboxEditor
import SwiftUI

@main
struct SlipboxEditorDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
            .defaultSize(width: 1000, height: 700)
        #endif
    }
}

struct ContentView: View {
    @StateObject private var editorModel = SlipboxEditorModel()
    @State private var showingHTMLSource = false
    @State private var showingSettings = false
    @State private var savedStates: [SavedDocument] = []

    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            editorDetailView
        }
        .navigationTitle("SlipboxEditor Demo")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Save") {
                    saveCurrentDocument()
                }
                .disabled(!editorModel.isReady || editorModel.plainText.isEmpty)

                Button("HTML") {
                    showingHTMLSource = true
                }
                .disabled(!editorModel.isReady)

                Button("Settings") {
                    showingSettings = true
                }
            }
        }
        .sheet(isPresented: $showingHTMLSource) {
            HTMLSourceView(html: editorModel.htmlContent)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            loadSavedDocuments()
        }
    }

    private var sidebarView: some View {
        VStack {
            List {
                Section("Documents") {
                    ForEach(savedStates) { doc in
                        DocumentRowView(document: doc) {
                            loadDocument(doc)
                        }
                    }
                    .onDelete(perform: deleteDocuments)
                }
            }

            Spacer()

            Button("New Document") {
                createNewDocument()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }

    private var editorDetailView: some View {
        VStack(spacing: 0) {
            EditorStatusBar(model: editorModel)
            Divider()
            SlipboxEditorView()
                .environmentObject(editorModel)
        }
    }

    private func createNewDocument() {
        Task {
            try? await editorModel.setContent("")
        }
    }

    private func saveCurrentDocument() {
        let title = extractTitle(from: editorModel.plainText)
        let preview = extractPreview(from: editorModel.plainText)

        let document = SavedDocument(
            title: title,
            content: editorModel.htmlContent,
            preview: preview,
            date: Date()
        )

        savedStates.append(document)
        saveToDisk()
    }

    private func loadDocument(_ document: SavedDocument) {
        Task {
            try? await editorModel.setContent(document.content)
        }
    }

    private func deleteDocuments(offsets: IndexSet) {
        savedStates.remove(atOffsets: offsets)
        saveToDisk()
    }

    private func extractTitle(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return firstLine.isEmpty ? "Untitled Document" : String(firstLine.prefix(50))
    }

    private func extractPreview(from text: String) -> String {
        let preview = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(preview.prefix(100))
    }

    private func loadSavedDocuments() {
        // In a real app, load from persistent storage
        // For demo purposes, we'll start with some sample documents
        if savedStates.isEmpty {
            savedStates = [
                SavedDocument(
                    title: "Welcome to SlipboxEditor",
                    content:
                        "<h1>Welcome to SlipboxEditor</h1><p>This is a powerful rich text editor built with <strong>Swift 6.1</strong> and JavaScript interoperability.</p><p><strong>Features:</strong></p><ul><li>Rich text formatting</li><li>Image support</li><li>Cross-platform compatibility</li><li>Offline-first design</li></ul><p>Try the formatting buttons in the toolbar above, or use keyboard shortcuts like <strong>⌘B</strong> for bold, <strong>⌘I</strong> for italic, and <strong>⌘U</strong> for underline.</p>",
                    preview:
                        "This is a powerful rich text editor built with Swift 6.1 and JavaScript interoperability...",
                    date: Date().addingTimeInterval(-86400)
                ),
                SavedDocument(
                    title: "Getting Started Guide",
                    content:
                        "<h2>Getting Started with SlipboxEditor</h2><p>Welcome to the demo! Here's what you can do:</p><ol><li><strong>Edit this text</strong> - Click anywhere and start typing</li><li><strong>Use the toolbar</strong> - Try the formatting buttons above</li><li><strong>Create new documents</strong> - Use the sidebar to manage multiple documents</li><li><strong>View HTML source</strong> - Click the HTML button to see the generated markup</li></ol><blockquote>💡 <em>Tip: This editor works completely offline and provides type-safe communication between Swift and JavaScript!</em></blockquote><h3>Advanced Features</h3><p>Try inserting images, creating lists, and using the various formatting options. The editor supports:</p><ul><li>Headers (H1, H2, H3)</li><li>Bold, italic, underline, strikethrough</li><li>Bulleted and numbered lists</li><li>Blockquotes and code blocks</li><li>Image insertion</li><li>Undo/redo with ⌘Z/⌘⇧Z</li></ul>",
                    preview:
                        "Welcome to the demo! Here's what you can do: Edit this text, use the toolbar, create new documents...",
                    date: Date().addingTimeInterval(-3600)
                ),
            ]
        }
    }

    private func saveToDisk() {
        // In a real app, persist to disk/Core Data/CloudKit
        print("Saving \(savedStates.count) documents")
    }
}

struct DocumentRowView: View {
    let document: SavedDocument
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text(document.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(document.preview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text(document.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct EditorStatusBar: View {
    @ObservedObject var model: SlipboxEditorModel

    var body: some View {
        HStack {
            if model.isReady {
                HStack(spacing: 16) {
                    Label("Ready", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)

                    Text("Characters: \(model.plainText.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let range = model.selectedRange, range.length > 0 {
                        Text("Selected: \(range.length)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading editor...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Quick actions
            HStack(spacing: 8) {
                Button("Undo") {
                    Task {
                        try? await model.executeCommand(
                            SlipboxEditorCommand(action: .undo, data: nil))
                    }
                }
                .disabled(!model.isReady)
                .buttonStyle(.borderless)

                Button("Redo") {
                    Task {
                        try? await model.executeCommand(
                            SlipboxEditorCommand(action: .redo, data: nil))
                    }
                }
                .disabled(!model.isReady)
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        #if os(macOS)
            .background(Color(NSColor.controlBackgroundColor))
        #else
            .background(Color(UIColor.systemBackground))
        #endif
    }
}

struct HTMLSourceView: View {
    let html: String
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    var body: some View {
        NavigationView {
            ScrollView {
                Text(html.isEmpty ? "No content" : html)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .navigationTitle("HTML Source")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(copied ? "Copied!" : "Copy") {
                        copyToClipboard()
                    }
                    .disabled(html.isEmpty)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    private func copyToClipboard() {
        #if os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(html, forType: .string)
        #else
            UIPasteboard.general.string = html
        #endif

        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("About SlipboxEditor") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Version: \(SlipboxEditor.version)")
                        Text("Built with Swift 6.1+")
                        Text("JavaScript Interoperability")
                        Text("Powered by Quill.js")
                    }
                    .font(.caption)
                }

                Section("Features") {
                    Label("Rich Text Editing", systemImage: "textformat")
                    Label("Cross-Platform Support", systemImage: "laptopcomputer.and.iphone")
                    Label("Offline Capability", systemImage: "wifi.slash")
                    Label("Type-Safe Communication", systemImage: "checkmark.shield")
                }

                Section("Keyboard Shortcuts") {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Bold")
                            Spacer()
                            Text("⌘B")
                                .font(.caption.monospaced())
                        }
                        HStack {
                            Text("Italic")
                            Spacer()
                            Text("⌘I")
                                .font(.caption.monospaced())
                        }
                        HStack {
                            Text("Underline")
                            Spacer()
                            Text("⌘U")
                                .font(.caption.monospaced())
                        }
                        HStack {
                            Text("Undo")
                            Spacer()
                            Text("⌘Z")
                                .font(.caption.monospaced())
                        }
                        HStack {
                            Text("Redo")
                            Spacer()
                            Text("⌘⇧Z")
                                .font(.caption.monospaced())
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}

struct SavedDocument: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let preview: String
    let date: Date

    init(title: String, content: String, preview: String, date: Date) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.preview = preview
        self.date = date
    }
}

#Preview {
    ContentView()
}
