# SlipboxEditor

A Swift Package for WYSIWYG editing with JavaScript interoperability, built on top of WKWebView and Quill.js. Leverages Swift 6.2's enhanced JavaScript integration capabilities for seamless native-web communication.

## Features

- 📝 **Rich Text Editing**: Full WYSIWYG editor with formatting, lists, images, and more
- 🚀 **Native Performance**: Uses WKWebView and JavaScriptCore for optimal performance
- 📱 **Cross-Platform**: Works on both iOS and macOS
- 🔄 **Type-Safe Communication**: Structured Swift-JavaScript message passing
- 💾 **Offline Capable**: No network requests required once bundled
- 🎯 **Easy Integration**: Simple SwiftUI view component

## Requirements

- iOS 16.0+ / macOS 13.0+
- Swift 6.1+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add SlipboxEditor to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/slipboxai/slipbox-editor`
3. Select the version or branch
4. Add to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/slipbox-editor", from: "1.0.0")
]
```

## Quick Start

### Basic Usage

```swift
import SwiftUI
import SlipboxEditor

struct ContentView: View {
    var body: some View {
        SlipboxEditorView()
            .frame(minHeight: 400)
    }
}
```

### Advanced Usage with Model Access

```swift
import SwiftUI
import SlipboxEditor

struct ContentView: View {
    @StateObject private var editorModel = SlipboxEditorModel()
    
    var body: some View {
        VStack {
            // Custom toolbar
            HStack {
                Button("Bold") {
                    Task {
                        try? await editorModel.executeCommand(
                            SlipboxEditorCommand(action: .bold, data: nil)
                        )
                    }
                }
                .disabled(!editorModel.isReady)
                
                Button("Save") {
                    let state = editorModel.saveState()
                    // Save state to your storage
                }
                
                Spacer()
            }
            .padding()
            
            // Editor
            SlipboxEditorView()
                .environmentObject(editorModel)
        }
    }
}
```

## API Reference

### SlipboxEditorView

The main SwiftUI view component for the editor.

```swift
public struct SlipboxEditorView: View
```

### SlipboxEditorModel

The model class for programmatic control of the editor.

```swift
@MainActor
public class SlipboxEditorModel: ObservableObject {
    @Published public var htmlContent: String
    @Published public var plainText: String  
    @Published public var isReady: Bool
    @Published public var selectedRange: NSRange?
    
    public func executeCommand(_ command: SlipboxEditorCommand) async throws
    public func setContent(_ html: String) async throws
    public func getContent() async throws
    public func saveState() -> SlipboxEditorState
    public func restoreState(_ state: SlipboxEditorState) async throws
}
```

### SlipboxEditorCommand

Commands for controlling the editor programmatically.

```swift
public struct SlipboxEditorCommand: Codable {
    public enum Action: String, Codable {
        case bold, italic, underline, strike
        case insertText, insertImage, insertLink
        case setContent, getContent
        case format, align
        case undo, redo
        case insertList, insertOrderedList
        case heading1, heading2, heading3
        case blockquote, codeBlock
    }
    
    public let action: Action
    public let data: [String: AnyCodable]?
}
```

### Common Commands

```swift
// Text formatting
try await model.executeCommand(SlipboxEditorCommand(action: .bold, data: nil))
try await model.executeCommand(SlipboxEditorCommand(action: .italic, data: nil))

// Insert content
try await model.executeCommand(SlipboxEditorCommand(
    action: .insertText, 
    data: ["text": AnyCodable("Hello World")]
))

// Insert image
try await model.executeCommand(SlipboxEditorCommand(
    action: .insertImage,
    data: ["src": AnyCodable("data:image/jpeg;base64,...")]
))

// Set content
try await model.setContent("<p>Your HTML content here</p>")
```

## Architecture

SlipboxEditor uses a hybrid approach combining:

- **WKWebView** for rendering the editor UI
- **WKScriptMessageHandler** for Swift↔JavaScript communication  
- **JavaScriptCore** for direct JavaScript execution when needed
- **Quill.js** as the rich text editor engine

This architecture provides:
- Native performance without WebAssembly overhead
- Full platform integration with iOS/macOS APIs
- Type-safe communication between Swift and JavaScript
- Offline capability with bundled assets

## Customization

### Custom Toolbar

You can hide the default toolbar and create your own:

```swift
SlipboxEditorView()
    .toolbar(.hidden) // Hide default toolbar
    .overlay(alignment: .top) {
        MyCustomToolbar(model: editorModel)
    }
```

### Custom Styling

The editor supports custom CSS styling through JavaScript execution:

```swift
let customCSS = """
    .ql-editor { 
        font-family: 'SF Mono', monospace; 
        background: #f8f8f8; 
    }
"""

editorModel.evaluateCustomScript("document.head.insertAdjacentHTML('beforeend', '<style>\(customCSS)</style>')")
```

## Running the Example

Want to see SlipboxEditor in action? You can run the demo app directly:

### Option 1: Open in Xcode
1. Clone this repository
2. Open `Examples/Package.swift` in Xcode
3. Select the `SlipboxEditorDemo` scheme
4. Press ⌘R to run

### Option 2: Command Line
```bash
cd Examples/
swift run SlipboxEditorDemo
```

The demo app includes:
- 📝 **Document Management**: Create, save, and load multiple documents
- 🛠️ **Full Toolbar**: All formatting options with keyboard shortcuts
- 📄 **HTML Export**: View and copy the generated HTML source
- ⚙️ **Settings Panel**: Learn about features and shortcuts
- 💾 **Sample Content**: Pre-loaded documents to explore

## Examples

The `Examples/` directory contains:

- **SlipboxEditorDemo**: Complete demo application with document management
- Ready-to-run Xcode project showcasing all features

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built on top of [Quill.js](https://quilljs.com/) - An amazing rich text editor
- Inspired by the research on Swift 6.1+ JavaScript interoperability enhancements
- Thanks to the Swift community for feedback and contributions

## Support

If you encounter any issues or have questions:

1. Check the [documentation](https://github.com/yourusername/slipbox-editor/wiki)
2. Search [existing issues](https://github.com/yourusername/slipbox-editor/issues)
3. Create a [new issue](https://github.com/yourusername/slipbox-editor/issues/new) if needed

---

Made with ❤️ for the Swift community