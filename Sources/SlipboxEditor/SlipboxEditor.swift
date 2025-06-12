// SlipboxEditor - A Swift Package for WYSIWYG editing with JavaScript interoperability
// 
// This package provides a native Swift interface for embedding rich text editors
// in iOS and macOS applications using WKWebView and JavaScriptCore.

import Foundation

// MARK: - Public Interface

/// The main editor view that can be embedded in SwiftUI applications
public typealias SlipboxEditorView = WYSIWYGEditorView

/// The editor model for programmatic control
public typealias SlipboxEditorModel = WYSIWYGEditorModel

/// Editor commands for controlling the editor
public typealias SlipboxEditorCommand = EditorCommand

/// Editor state for persistence
public typealias SlipboxEditorState = EditorState

// MARK: - Version Information
public struct SlipboxEditor {
    public static let version = "1.0.0"
    public static let name = "SlipboxEditor"
    public static let description = "A Swift Package for WYSIWYG editing with JavaScript interoperability"
}