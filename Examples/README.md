# SlipboxEditor Examples

This directory contains a complete demo application showcasing SlipboxEditor's capabilities.

## SlipboxEditorDemo

A full-featured demo application that demonstrates:

- 📝 **Rich Text Editing**: Complete WYSIWYG editor with toolbar
- 📂 **Document Management**: Create, save, and load multiple documents
- 🔍 **HTML Export**: View and copy generated HTML source code
- ⚙️ **Settings Panel**: Learn about features and keyboard shortcuts
- 📱 **Cross-Platform**: Works on both macOS and iOS
- 💾 **Sample Content**: Pre-loaded documents to explore

### Running the Demo

#### Option 1: Open in Xcode (Recommended)
1. Clone this repository
2. Open `Examples/Package.swift` in Xcode
3. Select the `SlipboxEditorDemo` scheme
4. Press ⌘R to run

#### Option 2: Command Line
```bash
cd Examples/
swift run SlipboxEditorDemo
```

### Features Demonstrated

#### Document Management
- **Sidebar Navigation**: Browse and select from saved documents
- **Create New**: Start fresh documents with the "New Document" button
- **Auto-Save**: Documents are automatically saved when you click "Save"
- **Preview**: See document titles and content previews

#### Rich Text Editing
- **Formatting Toolbar**: Bold, italic, underline, strikethrough
- **Headers**: H1, H2, H3 heading styles
- **Lists**: Bulleted and numbered lists
- **Blockquotes**: Styled quote blocks
- **Keyboard Shortcuts**: ⌘B (bold), ⌘I (italic), ⌘U (underline), ⌘Z (undo), ⌘⇧Z (redo)

#### Developer Tools
- **HTML Source View**: See the generated HTML markup
- **Copy HTML**: Export content for use in other applications
- **Live Character Count**: Monitor document length
- **Selection Tracking**: See current text selection range

#### Architecture Showcase
- **Swift 6.1+ Integration**: Demonstrates enhanced JavaScript interoperability
- **Type-Safe Communication**: Structured commands between Swift and JavaScript
- **Offline Operation**: No network requests required
- **Cross-Platform Code**: Shared implementation for iOS and macOS

### Code Structure

```
SlipboxEditorDemo/
├── Package.swift              # SPM configuration
└── SlipboxEditorDemo/
    └── ContentView.swift      # Complete demo app implementation
```

### Integration Example

The demo shows how to integrate SlipboxEditor in your own apps:

```swift
import SwiftUI
import SlipboxEditor

struct MyEditorView: View {
    @StateObject private var editorModel = SlipboxEditorModel()
    
    var body: some View {
        SlipboxEditorView()
            .environmentObject(editorModel)
            .onAppear {
                Task {
                    try? await editorModel.setContent("<p>Initial content</p>")
                }
            }
    }
}
```

### Customization Examples

The demo includes examples of:
- Custom toolbar implementation
- Document state management
- HTML content export
- Platform-specific UI adaptations
- Modal presentation patterns

### Requirements

- macOS 13.0+ or iOS 16.0+
- Swift 6.1+
- Xcode 16.0+

### Next Steps

After exploring the demo:

1. **Study the Source**: Review `ContentView.swift` to understand implementation patterns
2. **Try the API**: Experiment with different `SlipboxEditorCommand` actions
3. **Customize**: Modify the toolbar or add new features
4. **Integrate**: Use SlipboxEditor in your own projects

The demo serves as both a showcase and a reference implementation for building rich text editing experiences with Swift and JavaScript interoperability.