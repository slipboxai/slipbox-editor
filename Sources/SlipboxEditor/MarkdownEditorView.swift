import SwiftUI
import WebKit

@available(iOS 26.0, macOS 26.0, *)
public struct MarkdownEditorView: View {
    @State private var model: MarkdownEditorModel
    @State private var scrollPosition = ScrollPosition()
    @State private var findNavigatorPresented = false

    public init(model: MarkdownEditorModel? = nil) {
        self._model = State(initialValue: model ?? MarkdownEditorModel())
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Modern toolbar
                MarkdownToolbar(
                    model: model,
                    findNavigatorPresented: $findNavigatorPresented
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.regularMaterial)

                Divider()

                // WebKit editor using new APIs
                WebView(model.webPage)
                    .webViewScrollPosition($scrollPosition)
                    .findNavigator(isPresented: $findNavigatorPresented)
                    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                    #if os(visionOS)
                        .webViewScrollInputBehavior(.enabled, for: .look)
                    #endif
            }
            .navigationTitle(model.webPage.title ?? "Untitled")
            #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
struct MarkdownToolbar: View {
    let model: MarkdownEditorModel
    @Binding var findNavigatorPresented: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Text formatting
            FormatGroup(model: model)

            Divider().frame(height: 20)

            // Headings
            HeadingGroup(model: model)

            Divider().frame(height: 20)

            // Lists and blocks
            BlockGroup(model: model)

            Spacer()

            // Utilities
            UtilityGroup(model: model, findNavigatorPresented: $findNavigatorPresented)
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 26.0, macOS 26.0, *)
struct FormatGroup: View {
    let model: MarkdownEditorModel

    var body: some View {
        HStack(spacing: 4) {
            ToolbarButton(
                icon: "bold",
                tooltip: "Bold (⌘B)"
            ) {
                Task { try? await model.toggleBold() }
            }

            ToolbarButton(
                icon: "italic",
                tooltip: "Italic (⌘I)"
            ) {
                Task { try? await model.toggleItalic() }
            }
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
struct HeadingGroup: View {
    let model: MarkdownEditorModel

    var body: some View {
        HStack(spacing: 4) {
            ToolbarButton(
                icon: "1.square",
                tooltip: "Heading 1"
            ) {
                Task { try? await model.insertHeading(1) }
            }

            ToolbarButton(
                icon: "2.square",
                tooltip: "Heading 2"
            ) {
                Task { try? await model.insertHeading(2) }
            }

            ToolbarButton(
                icon: "3.square",
                tooltip: "Heading 3"
            ) {
                Task { try? await model.insertHeading(3) }
            }
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
struct BlockGroup: View {
    let model: MarkdownEditorModel

    var body: some View {
        HStack(spacing: 4) {
            ToolbarButton(
                icon: "list.bullet",
                tooltip: "Bullet List"
            ) {
                Task { try? await model.insertList(false) }
            }

            ToolbarButton(
                icon: "list.number",
                tooltip: "Numbered List"
            ) {
                Task { try? await model.insertList(true) }
            }

            ToolbarButton(
                icon: "quote.bubble",
                tooltip: "Blockquote"
            ) {
                Task { try? await model.insertBlockquote() }
            }

            ToolbarButton(
                icon: "curlybraces",
                tooltip: "Code Block"
            ) {
                Task { try? await model.insertCodeBlock() }
            }
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
struct UtilityGroup: View {
    let model: MarkdownEditorModel
    @Binding var findNavigatorPresented: Bool

    var body: some View {
        HStack(spacing: 8) {
            ToolbarButton(
                icon: "magnifyingglass",
                tooltip: "Find in Page"
            ) {
                findNavigatorPresented.toggle()
            }

            Menu {
                Button("Export as HTML") {
                    Task {
                        let content = try? await model.getContent()
                        // Handle export
                    }
                }

                Button("Export as Markdown") {
                    Task {
                        let content = try? await model.getContent()
                        // Handle export
                    }
                }

                Button("Clear All") {
                    Task {
                        try? await model.setContent("")
                    }
                }
            } label: {
                ToolbarButton(
                    icon: "ellipsis.circle",
                    tooltip: "More Options"
                ) {}
            }
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
struct ToolbarButton: View {
    let icon: String
    let tooltip: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 28, height: 28)
                .background(Color.clear)
                .foregroundColor(.primary)
                .cornerRadius(6)
        }
        .help(tooltip)
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
@available(iOS 26.0, macOS 26.0, *)
#Preview {
    MarkdownEditorView()
}
