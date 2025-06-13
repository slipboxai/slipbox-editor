import Foundation
import SlipboxEditor
import SwiftUI

@available(iOS 26.0, macOS 26.0, *)
public struct ContentView: View {
    @State private var editorModel = SlipboxEditorModel()
    @State private var showingMarkdownSource = false
    @State private var showingSettings = false
    @State private var savedDocuments: [SavedDocument] = []

    public init() {}

    public var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            editorDetailView
        }
        .navigationTitle("SlipboxEditor 2.0 Demo")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Save") {
                    saveCurrentDocument()
                }
                .disabled(!editorModel.isReady || editorModel.markdownContent.isEmpty)

                Button("Markdown") {
                    showingMarkdownSource = true
                }
                .disabled(!editorModel.isReady)

                Button("Settings") {
                    showingSettings = true
                }
            }
        }
        .sheet(isPresented: $showingMarkdownSource) {
            MarkdownSourceView(markdown: editorModel.markdownContent)
        }
        .sheet(isPresented: $showingSettings) {
            ModernSettingsView()
        }
        .onAppear {
            loadSampleDocuments()
        }
    }

    private var sidebarView: some View {
        VStack {
            List {
                Section("Documents") {
                    ForEach(savedDocuments) { doc in
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
            ModernStatusBar(model: editorModel)
            Divider()
            SlipboxEditorView(model: editorModel)
        }
    }

    private func createNewDocument() {
        Task {
            try? await editorModel.setContent("")
        }
    }

    private func saveCurrentDocument() {
        let title = extractTitle(from: editorModel.markdownContent)
        let preview = extractPreview(from: editorModel.markdownContent)

        let document = SavedDocument(
            title: title,
            content: editorModel.markdownContent,
            preview: preview,
            date: Date()
        )

        savedDocuments.append(document)
        saveToDisk()
    }

    private func loadDocument(_ document: SavedDocument) {
        Task {
            try? await editorModel.setContent(document.content)
        }
    }

    private func deleteDocuments(offsets: IndexSet) {
        savedDocuments.remove(atOffsets: offsets)
        saveToDisk()
    }

    private func extractTitle(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let firstLine = lines.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // Remove markdown heading syntax
        let cleanedLine = firstLine.replacingOccurrences(
            of: "^#+\\s*", with: "", options: .regularExpression)

        return cleanedLine.isEmpty ? "Untitled Document" : String(cleanedLine.prefix(50))
    }

    private func extractPreview(from text: String) -> String {
        // Remove markdown syntax for preview
        let cleanText =
            text
            .replacingOccurrences(of: "^#+\\s*", with: "", options: .regularExpression)
            .replacingOccurrences(
                of: "\\*\\*([^*]+)\\*\\*", with: "$1", options: .regularExpression
            )
            .replacingOccurrences(of: "\\*([^*]+)\\*", with: "$1", options: .regularExpression)
            .replacingOccurrences(of: "^>\\s*", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return String(cleanText.prefix(100))
    }

    private func loadSampleDocuments() {
        // Load sample documents for demo
        if savedDocuments.isEmpty {
            savedDocuments = [
                SavedDocument(
                    title: "Welcome to SlipboxEditor 2.0",
                    content: """
                        # Welcome to SlipboxEditor 2.0

                        This is a **modern markdown editor** built with iOS 26 and macOS 26's latest WebKit SwiftUI APIs.

                        ## Features

                        - **Live markdown shortcuts**: Type `# ` for headings, `- ` for lists
                        - **Command palette**: Type `/` to see available blocks
                        - **Keyboard shortcuts**: ⌘B for bold, ⌘I for italic, ⌘K for links
                        - **Native integration**: Uses WebKit SwiftUI for perfect platform integration

                        ## Try it out!

                        Start typing to see the markdown shortcuts in action. Try:

                        1. Type `# ` at the beginning of a line for a heading
                        2. Type `- ` for a bullet list
                        3. Type `/` to open the command palette
                        4. Use ⌘B to make text **bold**

                        > This editor provides a clean, Notion-like writing experience with the power of markdown.

                        Happy writing! ✨
                        """,
                    preview:
                        "This is a modern markdown editor built with iOS 26 and macOS 26's latest WebKit SwiftUI APIs...",
                    date: Date().addingTimeInterval(-86400)
                ),
                SavedDocument(
                    title: "Markdown Syntax Guide",
                    content: """
                        # Markdown Syntax Guide

                        ## Headers

                        Use `#` for headers:

                        ```
                        # H1
                        ## H2
                        ### H3
                        ```

                        ## Text Formatting

                        - **Bold text**: `**text**` or `__text__`
                        - *Italic text*: `*text*` or `_text_`
                        - `Inline code`: \\`code\\`

                        ## Lists

                        ### Unordered
                        - Item 1
                        - Item 2
                        - Item 3

                        ### Ordered
                        1. First item
                        2. Second item
                        3. Third item

                        ## Blockquotes

                        > This is a blockquote
                        > It can span multiple lines

                        ## Code Blocks

                        ```swift
                        func hello() {
                            print("Hello, World!")
                        }
                        ```

                        ## Links

                        [Link text](https://example.com)
                        """,
                    preview:
                        "A comprehensive guide to markdown syntax supported by SlipboxEditor...",
                    date: Date().addingTimeInterval(-3600)
                ),
            ]
        }
    }

    private func saveToDisk() {
        // In a real app, persist to disk/Core Data/CloudKit
        print("Saving \(savedDocuments.count) documents")
    }
}

public struct DocumentRowView: View {
    let document: SavedDocument
    let onTap: () -> Void

    public init(document: SavedDocument, onTap: @escaping () -> Void) {
        self.document = document
        self.onTap = onTap
    }

    public var body: some View {
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

@available(iOS 26.0, macOS 26.0, *)
public struct ModernStatusBar: View {
    let model: SlipboxEditorModel

    public init(model: SlipboxEditorModel) {
        self.model = model
    }

    public var body: some View {
        HStack {
            if model.isReady {
                HStack(spacing: 16) {
                    Label("Ready", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)

                    Text("Characters: \(model.markdownContent.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Lines: \(model.markdownContent.components(separatedBy: .newlines).count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
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

            // Tips
            Text("💡 Type / for commands, ⌘B for bold")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

public struct MarkdownSourceView: View {
    let markdown: String
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    public init(markdown: String) {
        self.markdown = markdown
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                Text(markdown.isEmpty ? "No content" : markdown)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .navigationTitle("Markdown Source")
            #if !os(macOS)
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
                    .disabled(markdown.isEmpty)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 500)
    }

    private func copyToClipboard() {
        #if os(macOS)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(markdown, forType: .string)
        #else
            UIPasteboard.general.string = markdown
        #endif

        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}

public struct ModernSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("About SlipboxEditor 2.0") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Version: \(SlipboxEditor.version)")
                        Text("Built for iOS 26+ and macOS 26+")
                        Text("WebKit SwiftUI Native")
                        Text("Notion-like Markdown Editor")
                    }
                    .font(.caption)
                }

                Section("Features") {
                    ForEach(SlipboxEditor.features, id: \.self) { feature in
                        Label(feature, systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }

                Section("Markdown Shortcuts") {
                    VStack(alignment: .leading, spacing: 4) {
                        ShortcutRow("Heading 1", "# + space")
                        ShortcutRow("Heading 2", "## + space")
                        ShortcutRow("Heading 3", "### + space")
                        ShortcutRow("Bullet List", "- + space")
                        ShortcutRow("Numbered List", "1. + space")
                        ShortcutRow("Blockquote", "> + space")
                        ShortcutRow("Command Palette", "/")
                    }
                }

                Section("Keyboard Shortcuts") {
                    VStack(alignment: .leading, spacing: 4) {
                        ShortcutRow("Bold", "⌘B")
                        ShortcutRow("Italic", "⌘I")
                        ShortcutRow("Link", "⌘K")
                        ShortcutRow("Find", "⌘F")
                    }
                }
            }
            .navigationTitle("Settings")
            #if !os(macOS)
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

public struct ShortcutRow: View {
    let name: String
    let shortcut: String

    public init(_ name: String, _ shortcut: String) {
        self.name = name
        self.shortcut = shortcut
    }

    public var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(shortcut)
                .font(.caption.monospaced())
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray)
                .cornerRadius(4)
        }
    }
}

public struct UnsupportedView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Unsupported Platform")
                .font(.title)
                .fontWeight(.bold)

            Text("SlipboxEditor 2.0 requires iOS 26+ or macOS 26+")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Text("This demo uses the latest WebKit SwiftUI APIs")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

public struct SavedDocument: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let content: String
    public let preview: String
    public let date: Date

    public init(title: String, content: String, preview: String, date: Date) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.preview = preview
        self.date = date
    }
}

#Preview {
    if SlipboxEditor.isSupported {
        ContentView()
    } else {
        UnsupportedView()
    }
}
