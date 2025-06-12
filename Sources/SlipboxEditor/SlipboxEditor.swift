// SlipboxEditor - Modern Markdown Editor for iOS 26+ and macOS 26+
// 
// This package provides a Notion-like markdown editing experience using the latest
// WebKit SwiftUI APIs available in iOS 26 and macOS 26. Features include live markdown
// shortcuts, command palette, and seamless platform integration.

import Foundation
import SwiftUI
import WebKit

// MARK: - Public Interface

/// The main markdown editor view for iOS 26+ and macOS 26+
@available(iOS 26.0, macOS 26.0, *)
public struct SlipboxEditorView: View {
    private let model: MarkdownEditorModel
    
    public init(model: MarkdownEditorModel? = nil) {
        self.model = model ?? MarkdownEditorModel()
    }
    
    public var body: some View {
        MarkdownEditorView(model: model)
    }
}

/// The markdown editor model for programmatic control
@available(iOS 26.0, macOS 26.0, *)
public typealias SlipboxEditorModel = MarkdownEditorModel

// MARK: - Version Information
public struct SlipboxEditor {
    public static let version = "2.0.0"
    public static let name = "SlipboxEditor"
    public static let description = "Modern markdown editor with Notion-like experience for iOS 26+ and macOS 26+"
    
    /// Supported platforms
    public static let supportedPlatforms = ["iOS 26+", "macOS 26+", "visionOS 26+"]
    
    /// Key features
    public static let features = [
        "Notion-like markdown editing",
        "Live markdown shortcuts",
        "Command palette with slash commands",
        "WebKit SwiftUI native integration",
        "Find-in-page support",
        "Keyboard shortcuts (⌘B, ⌘I, ⌘K)",
        "Cross-platform (iOS/macOS)",
        "Modern Observable patterns",
        "Export to HTML/Markdown",
        "Clean, distraction-free interface"
    ]
    
    /// Check if the current platform supports SlipboxEditor
    public static var isSupported: Bool {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return true
        }
        return false
    }
}