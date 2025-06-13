import SwiftUI
import WebKit

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Observable
public class MarkdownEditorModel {
    // MARK: - Observable Properties
    public var markdownContent: String = ""
    public var htmlContent: String = ""
    public var isReady: Bool = false
    public var selectedRange: NSRange?

    // MARK: - WebKit SwiftUI Components
    public let webPage: WebPage
    private let schemeHandler = MarkdownSchemeHandler()

    public init() {
        print("MarkdownEditorModel: Initializing...")

        // Create WebPage configuration with custom scheme handler
        var configuration = WebPage.Configuration()

        // Register custom scheme for local editor resources
        // Use a different scheme name that's less likely to conflict
        if let editorScheme = URLScheme("slipbox-editor") {
            print("MarkdownEditorModel: Successfully created URLScheme")
            configuration.urlSchemeHandlers[editorScheme] = schemeHandler
        } else {
            print("Warning: Failed to create URLScheme for slipbox-editor")
        }

        // Initialize WebPage with modern API
        print("MarkdownEditorModel: Creating WebPage...")
        self.webPage = WebPage(configuration: configuration)
        print("MarkdownEditorModel: WebPage created successfully")

        // TODO: Handle navigation policy and events if needed when WebPage API is updated

        // Delay loading to ensure WebView is ready
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms delay
            await MainActor.run {
                self.loadEditorContent()
            }
        }
    }

    private func loadEditorContent() {
        print("MarkdownEditorModel: Loading editor content...")

        Task {
            do {
                // Load HTML directly to avoid custom scheme issues
                let htmlContent = try MarkdownSchemeHandler.loadMarkdownEditorHTML()
                let htmlString = String(data: htmlContent, encoding: .utf8) ?? ""

                print("MarkdownEditorModel: Loading HTML directly (\(htmlContent.count) bytes)")

                await MainActor.run {
                    // Load HTML string directly instead of using custom scheme
                    // Use a file URL as base to allow relative resource loading
                    let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    webPage.load(html: htmlString, baseURL: baseURL)
                }

                // Set ready state after allowing WebView to load
                try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second delay
                await MainActor.run {
                    self.isReady = true
                    print("MarkdownEditorModel: Editor is ready")
                }
            } catch {
                print("MarkdownEditorModel: Error loading content - \(error)")

                // Fallback to a simple HTML page
                await MainActor.run {
                    let fallbackHTML = """
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="utf-8">
                            <title>SlipboxEditor</title>
                            <style>
                                body { 
                                    font-family: -apple-system, sans-serif; 
                                    padding: 20px; 
                                    background: #fff;
                                }
                                .editor { 
                                    width: 100%; 
                                    min-height: 400px; 
                                    border: none; 
                                    outline: none; 
                                    font-size: 16px;
                                }
                            </style>
                        </head>
                        <body>
                            <div class="editor" contenteditable="true" placeholder="Start writing...">
                                Welcome to SlipboxEditor! You can start typing here.
                            </div>
                        </body>
                        </html>
                        """
                    let baseURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    webPage.load(html: fallbackHTML, baseURL: baseURL)
                    self.isReady = true
                    print("MarkdownEditorModel: Loaded fallback editor")
                }
            }
        }
    }

    // MARK: - Content Management
    public func setContent(_ markdown: String) async throws {
        let script = "window.markdownEditor.setContent(\(markdown.jsonEscaped));"
        _ = try await webPage.callJavaScript(script)
        self.markdownContent = markdown
    }

    public func getContent() async throws -> String {
        let script = "window.markdownEditor.getContent()"
        let result = try await webPage.callJavaScript(script)
        return result as? String ?? ""
    }

    public func insertText(_ text: String) async throws {
        let script = "window.markdownEditor.insertText(\(text.jsonEscaped));"
        _ = try await webPage.callJavaScript(script)
    }

    // MARK: - Formatting Commands
    public func toggleBold() async throws {
        let script = "window.markdownEditor.toggleBold();"
        _ = try await webPage.callJavaScript(script)
    }

    public func toggleItalic() async throws {
        let script = "window.markdownEditor.toggleItalic();"
        _ = try await webPage.callJavaScript(script)
    }

    public func insertHeading(_ level: Int) async throws {
        let script = "window.markdownEditor.insertHeading(\(level));"
        _ = try await webPage.callJavaScript(script)
    }

    public func insertList(_ ordered: Bool = false) async throws {
        let script = "window.markdownEditor.insertList(\(ordered));"
        _ = try await webPage.callJavaScript(script)
    }

    public func insertBlockquote() async throws {
        let script = "window.markdownEditor.insertBlockquote();"
        _ = try await webPage.callJavaScript(script)
    }

    public func insertCodeBlock() async throws {
        let script = "window.markdownEditor.insertCodeBlock();"
        _ = try await webPage.callJavaScript(script)
    }
}

// MARK: - Custom Scheme Handler
@available(iOS 26.0, macOS 26.0, *)
class MarkdownSchemeHandler: URLSchemeHandler {
    func reply(for request: URLRequest) -> AsyncThrowingStream<URLSchemeTaskResult, Error> {
        AsyncThrowingStream { @Sendable continuation in
            Task {
                print(
                    "MarkdownSchemeHandler: Processing request for \(request.url?.absoluteString ?? "nil")"
                )

                guard let url = request.url else {
                    print("MarkdownSchemeHandler: No URL in request")
                    continuation.finish(throwing: MarkdownEditorError.contentLoadFailed)
                    return
                }

                // Handle different resource requests
                if url.path.contains("index.html") || url.path.isEmpty || url.path == "/" {
                    do {
                        let htmlContent = try MarkdownSchemeHandler.loadMarkdownEditorHTML()

                        let response = HTTPURLResponse(
                            url: url,
                            statusCode: 200,
                            httpVersion: "HTTP/1.1",
                            headerFields: [
                                "Content-Type": "text/html; charset=utf-8",
                                "Content-Length": "\(htmlContent.count)",
                                "Cache-Control": "no-cache",
                            ]
                        )!

                        print(
                            "MarkdownSchemeHandler: Yielding response for HTML (\(htmlContent.count) bytes)"
                        )
                        continuation.yield(.response(response))
                        continuation.yield(.data(htmlContent))
                        continuation.finish()
                    } catch {
                        print("MarkdownSchemeHandler: Error loading HTML - \(error)")
                        continuation.finish(throwing: error)
                    }
                } else {
                    // For any other resources, return 404
                    print("MarkdownSchemeHandler: Unknown resource: \(url.path)")
                    let response = HTTPURLResponse(
                        url: url,
                        statusCode: 404,
                        httpVersion: "HTTP/1.1",
                        headerFields: ["Content-Type": "text/plain"]
                    )!
                    let notFoundData = "Not Found".data(using: .utf8)!

                    continuation.yield(.response(response))
                    continuation.yield(.data(notFoundData))
                    continuation.finish()
                }
            }
        }
    }

    static func loadMarkdownEditorHTML() throws -> Data {
        let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Markdown Editor</title>
                <style>
                    /* Modern editor styles inspired by Notion */
                    * { box-sizing: border-box; }
                    
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
                        margin: 0;
                        padding: 20px;
                        background: #fff;
                        line-height: 1.6;
                        color: #37352f;
                    }
                    
                    .editor-container {
                        max-width: 900px;
                        margin: 0 auto;
                        min-height: 100vh;
                    }
                    
                    .editor {
                        outline: none;
                        border: none;
                        width: 100%;
                        min-height: 500px;
                        font-size: 16px;
                        line-height: 1.6;
                        white-space: pre-wrap;
                        word-wrap: break-word;
                    }
                    
                    .editor:empty:before {
                        content: attr(data-placeholder);
                        color: #9b9a97;
                        pointer-events: none;
                    }
                    
                    /* Markdown-rendered content styles */
                    .preview h1 {
                        font-size: 2.5em;
                        font-weight: 700;
                        margin: 1em 0 0.5em;
                        color: #2d2d2d;
                    }
                    
                    .preview h2 {
                        font-size: 2em;
                        font-weight: 600;
                        margin: 1em 0 0.5em;
                        color: #2d2d2d;
                    }
                    
                    .preview h3 {
                        font-size: 1.5em;
                        font-weight: 600;
                        margin: 1em 0 0.5em;
                        color: #2d2d2d;
                    }
                    
                    .preview p {
                        margin: 0.75em 0;
                    }
                    
                    .preview ul, .preview ol {
                        margin: 0.75em 0;
                        padding-left: 1.5em;
                    }
                    
                    .preview li {
                        margin: 0.25em 0;
                    }
                    
                    .preview blockquote {
                        border-left: 4px solid #e5e5e5;
                        margin: 1em 0;
                        padding-left: 1em;
                        color: #666;
                        font-style: italic;
                    }
                    
                    .preview code {
                        background: #f1f1f0;
                        padding: 2px 4px;
                        border-radius: 3px;
                        font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
                        font-size: 0.9em;
                    }
                    
                    .preview pre {
                        background: #f8f8f7;
                        border: 1px solid #e5e5e5;
                        border-radius: 6px;
                        padding: 1em;
                        margin: 1em 0;
                        overflow-x: auto;
                        font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
                        font-size: 0.9em;
                    }
                    
                    .preview pre code {
                        background: none;
                        padding: 0;
                    }
                    
                    /* Command palette styles */
                    .command-palette {
                        position: absolute;
                        background: white;
                        border: 1px solid #e5e5e5;
                        border-radius: 8px;
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                        max-width: 300px;
                        z-index: 1000;
                        display: none;
                    }
                    
                    .command-item {
                        padding: 8px 12px;
                        cursor: pointer;
                        border-bottom: 1px solid #f1f1f1;
                        font-size: 14px;
                    }
                    
                    .command-item:hover {
                        background: #f8f8f7;
                    }
                    
                    .command-item:last-child {
                        border-bottom: none;
                    }
                    
                    .command-icon {
                        display: inline-block;
                        width: 20px;
                        margin-right: 8px;
                        font-weight: bold;
                    }
                </style>
            </head>
            <body>
                <div class="editor-container">
                    <div class="editor" 
                         contenteditable="true" 
                         data-placeholder="Start writing..."
                         id="editor"></div>
                    
                    <div class="command-palette" id="commandPalette">
                        <div class="command-item" data-command="heading1">
                            <span class="command-icon">H1</span>Heading 1
                        </div>
                        <div class="command-item" data-command="heading2">
                            <span class="command-icon">H2</span>Heading 2
                        </div>
                        <div class="command-item" data-command="heading3">
                            <span class="command-icon">H3</span>Heading 3
                        </div>
                        <div class="command-item" data-command="bullet">
                            <span class="command-icon">•</span>Bullet List
                        </div>
                        <div class="command-item" data-command="numbered">
                            <span class="command-icon">1.</span>Numbered List
                        </div>
                        <div class="command-item" data-command="quote">
                            <span class="command-icon">"</span>Blockquote
                        </div>
                        <div class="command-item" data-command="code">
                            <span class="command-icon">{}</span>Code Block
                        </div>
                    </div>
                </div>
                
                <script>
                    // Modern markdown editor implementation
                    window.markdownEditor = {
                        editor: null,
                        commandPalette: null,
                        
                        initialize(config) {
                            this.editor = document.getElementById('editor');
                            this.commandPalette = document.getElementById('commandPalette');
                            this.setupEventListeners();
                            this.setupKeyboardShortcuts();
                        },
                        
                        setupEventListeners() {
                            // Content change notifications
                            this.editor.addEventListener('input', () => {
                                this.notifyContentChange();
                            });
                            
                            // Command palette handling
                            this.editor.addEventListener('keydown', (e) => {
                                if (e.key === '/' && this.getLineStart() === '') {
                                    e.preventDefault();
                                    this.showCommandPalette();
                                } else if (e.key === 'Escape') {
                                    this.hideCommandPalette();
                                }
                            });
                            
                            // Command selection
                            this.commandPalette.addEventListener('click', (e) => {
                                const item = e.target.closest('.command-item');
                                if (item) {
                                    this.executeCommand(item.dataset.command);
                                    this.hideCommandPalette();
                                }
                            });
                            
                            // Auto-markdown shortcuts
                            this.editor.addEventListener('input', (e) => {
                                this.handleAutoMarkdown(e);
                            });
                        },
                        
                        setupKeyboardShortcuts() {
                            this.editor.addEventListener('keydown', (e) => {
                                if (e.metaKey || e.ctrlKey) {
                                    switch (e.key) {
                                        case 'b':
                                            e.preventDefault();
                                            this.toggleBold();
                                            break;
                                        case 'i':
                                            e.preventDefault();
                                            this.toggleItalic();
                                            break;
                                        case 'k':
                                            e.preventDefault();
                                            this.insertLink();
                                            break;
                                    }
                                }
                            });
                        },
                        
                        getLineStart() {
                            const selection = window.getSelection();
                            const range = selection.getRangeAt(0);
                            const line = range.startContainer.textContent || '';
                            const lineStart = line.substring(0, range.startOffset);
                            return lineStart.split('\\n').pop() || '';
                        },
                        
                        showCommandPalette() {
                            const selection = window.getSelection();
                            const range = selection.getRangeAt(0);
                            const rect = range.getBoundingClientRect();
                            
                            this.commandPalette.style.display = 'block';
                            this.commandPalette.style.left = rect.left + 'px';
                            this.commandPalette.style.top = (rect.bottom + 5) + 'px';
                        },
                        
                        hideCommandPalette() {
                            this.commandPalette.style.display = 'none';
                        },
                        
                        executeCommand(command) {
                            // Remove the '/' that triggered the palette
                            this.deletePreviousChar();
                            
                            switch (command) {
                                case 'heading1':
                                    this.insertText('# ');
                                    break;
                                case 'heading2':
                                    this.insertText('## ');
                                    break;
                                case 'heading3':
                                    this.insertText('### ');
                                    break;
                                case 'bullet':
                                    this.insertText('- ');
                                    break;
                                case 'numbered':
                                    this.insertText('1. ');
                                    break;
                                case 'quote':
                                    this.insertText('> ');
                                    break;
                                case 'code':
                                    this.insertText('```\\n\\n```');
                                    this.moveCursorUp(1);
                                    break;
                            }
                        },
                        
                        handleAutoMarkdown(e) {
                            const text = this.getLineStart();
                            
                            // Auto-convert markdown shortcuts
                            if (e.data === ' ') {
                                if (text === '#') {
                                    this.replaceCurrentLine('# ');
                                } else if (text === '##') {
                                    this.replaceCurrentLine('## ');
                                } else if (text === '###') {
                                    this.replaceCurrentLine('### ');
                                } else if (text === '-') {
                                    this.replaceCurrentLine('- ');
                                } else if (text === '>') {
                                    this.replaceCurrentLine('> ');
                                }
                            }
                        },
                        
                        // Core editing functions
                        setContent(content) {
                            this.editor.textContent = content;
                            this.notifyContentChange();
                        },
                        
                        getContent() {
                            return this.editor.textContent || '';
                        },
                        
                        insertText(text) {
                            const selection = window.getSelection();
                            if (selection.rangeCount > 0) {
                                const range = selection.getRangeAt(0);
                                range.deleteContents();
                                range.insertNode(document.createTextNode(text));
                                range.collapse(false);
                                selection.removeAllRanges();
                                selection.addRange(range);
                            }
                            this.notifyContentChange();
                        },
                        
                        toggleBold() {
                            this.wrapSelection('**', '**');
                        },
                        
                        toggleItalic() {
                            this.wrapSelection('*', '*');
                        },
                        
                        insertLink() {
                            const url = prompt('Enter URL:');
                            if (url) {
                                this.wrapSelection('[', `](${url})`);
                            }
                        },
                        
                        wrapSelection(before, after) {
                            const selection = window.getSelection();
                            if (selection.rangeCount > 0) {
                                const range = selection.getRangeAt(0);
                                const selectedText = range.toString();
                                range.deleteContents();
                                range.insertNode(document.createTextNode(before + selectedText + after));
                            }
                            this.notifyContentChange();
                        },
                        
                        replaceCurrentLine(replacement) {
                            const selection = window.getSelection();
                            const range = selection.getRangeAt(0);
                            
                            // Find line boundaries
                            const container = range.startContainer;
                            const offset = range.startOffset;
                            const text = container.textContent || '';
                            
                            const lineStart = text.lastIndexOf('\\n', offset - 1) + 1;
                            const lineEnd = text.indexOf('\\n', offset);
                            
                            // Replace line content
                            const newRange = document.createRange();
                            newRange.setStart(container, lineStart);
                            newRange.setEnd(container, lineEnd === -1 ? text.length : lineEnd);
                            newRange.deleteContents();
                            newRange.insertNode(document.createTextNode(replacement));
                            
                            // Position cursor at end
                            newRange.collapse(false);
                            selection.removeAllRanges();
                            selection.addRange(newRange);
                            
                            this.notifyContentChange();
                        },
                        
                        deletePreviousChar() {
                            const selection = window.getSelection();
                            if (selection.rangeCount > 0) {
                                const range = selection.getRangeAt(0);
                                range.setStart(range.startContainer, range.startOffset - 1);
                                range.deleteContents();
                            }
                        },
                        
                        moveCursorUp(lines) {
                            // Simple implementation - would need more sophisticated cursor positioning
                            const selection = window.getSelection();
                            const range = selection.getRangeAt(0);
                            range.setStart(range.startContainer, Math.max(0, range.startOffset - lines));
                            range.collapse(true);
                            selection.removeAllRanges();
                            selection.addRange(range);
                        },
                        
                        notifyContentChange() {
                            // Notify native side of changes
                            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.editorBridge) {
                                window.webkit.messageHandlers.editorBridge.postMessage({
                                    type: 'contentChanged',
                                    markdown: this.getContent(),
                                    timestamp: Date.now()
                                });
                            }
                        }
                    };
                    
                    // Auto-initialize when DOM is ready
                    document.addEventListener('DOMContentLoaded', () => {
                        window.markdownEditor.initialize({});
                    });
                </script>
            </body>
            </html>
            """
        return html.data(using: .utf8) ?? Data()
    }
}

// MARK: - Errors
public enum MarkdownEditorError: Error {
    case notReady
    case contentLoadFailed
    case invalidCommand
}

// MARK: - String Extensions
extension String {
    var jsonEscaped: String {
        // Properly escape string for JSON by encoding it as a JSON string
        do {
            let data = try JSONSerialization.data(withJSONObject: [self])
            if let jsonString = String(data: data, encoding: .utf8) {
                // Extract just the string part (remove array brackets)
                let trimmed = jsonString.dropFirst().dropLast()  // Remove [ and ]
                return String(trimmed)
            }
        } catch {
            print("Error escaping JSON: \(error)")
        }

        // Fallback: manual escaping
        return "\""
            + self.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t") + "\""
    }
}
