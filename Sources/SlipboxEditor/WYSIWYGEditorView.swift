import SwiftUI
import WebKit

#if os(macOS)
    import AppKit
    typealias PlatformImage = NSImage
#else
    import UIKit
    typealias PlatformImage = UIImage
#endif

// MARK: - SwiftUI View
public struct WYSIWYGEditorView: View {
    @StateObject private var model = WYSIWYGEditorModel()
    @State private var showingImagePicker = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            EditorToolbar(model: model, showingImagePicker: $showingImagePicker)
                .padding(.horizontal)
                .padding(.vertical, 8)
                #if os(macOS)
                    .background(Color(NSColor.controlBackgroundColor))
                #else
                    .background(Color(UIColor.systemBackground))
                #endif

            Divider()

            // Editor
            WebView(model.page)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image in
                Task {
                    await insertImage(image)
                }
            }
        }
    }

    private func insertImage(_ image: PlatformImage) async {
        #if os(macOS)
            guard let tiffData = image.tiffRepresentation,
                let bitmap = NSBitmapImageRep(data: tiffData),
                let jpegData = bitmap.representation(using: .jpeg, properties: [:])
            else {
                return
            }
        #else
            guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
                return
            }
        #endif

        let base64 = jpegData.base64EncodedString()
        let dataURL = "data:image/jpeg;base64,\(base64)"

        let command = EditorCommand(
            action: .insertImage,
            data: ["src": AnyCodable(dataURL)]
        )

        try? await model.executeCommand(command)
    }
}

// MARK: - Toolbar
struct EditorToolbar: View {
    @ObservedObject var model: WYSIWYGEditorModel
    @Binding var showingImagePicker: Bool

    var body: some View {
        HStack(spacing: 16) {
            FormatButtonGroup(model: model)

            Divider()
                .frame(height: 20)

            HeadingButtonGroup(model: model)

            Divider()
                .frame(height: 20)

            ListButtonGroup(model: model)

            Spacer()

            Button(action: { showingImagePicker = true }) {
                Label("Insert Image", systemImage: "photo")
            }
            .disabled(!model.isReady)
        }
    }
}

struct FormatButtonGroup: View {
    @ObservedObject var model: WYSIWYGEditorModel

    var body: some View {
        HStack(spacing: 4) {
            FormatButton(model: model, action: .bold, icon: "bold")
            FormatButton(model: model, action: .italic, icon: "italic")
            FormatButton(model: model, action: .underline, icon: "underline")
            FormatButton(model: model, action: .strike, icon: "strikethrough")
        }
    }
}

struct HeadingButtonGroup: View {
    @ObservedObject var model: WYSIWYGEditorModel

    var body: some View {
        HStack(spacing: 4) {
            FormatButton(model: model, action: .heading1, icon: "textformat.size.larger")
            FormatButton(model: model, action: .heading2, icon: "textformat.size")
            FormatButton(model: model, action: .heading3, icon: "textformat.size.smaller")
        }
    }
}

struct ListButtonGroup: View {
    @ObservedObject var model: WYSIWYGEditorModel

    var body: some View {
        HStack(spacing: 4) {
            FormatButton(model: model, action: .insertList, icon: "list.bullet")
            FormatButton(model: model, action: .insertOrderedList, icon: "list.number")
            FormatButton(model: model, action: .blockquote, icon: "quote.bubble")
        }
    }
}

struct FormatButton: View {
    @ObservedObject var model: WYSIWYGEditorModel
    let action: EditorCommand.Action
    let icon: String

    var body: some View {
        Button(action: {
            Task {
                try? await model.executeCommand(EditorCommand(action: action, data: nil))
            }
        }) {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
        }
        .buttonStyle(.plain)
        .disabled(!model.isReady)
    }
}

// MARK: - Image Picker
struct ImagePicker: View {
    let onImageSelected: (PlatformImage) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Image Picker")
                .font(.headline)
                .padding()

            Text("Image picker implementation would go here")
                .foregroundColor(.secondary)
                .padding()

            Button("Cancel") {
                dismiss()
            }
            .padding()
        }
        .frame(minWidth: 300, minHeight: 200)
    }
}
