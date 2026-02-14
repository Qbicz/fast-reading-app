import Foundation

/// Swift wrapper around the Rust `TextReader` FFI.
final class RustTextReader {
    private var handle: OpaquePointer?

    init?(text: String) {
        guard let cText = text.cString(using: .utf8) else { return nil }
        handle = text_reader_new(cText)
        guard handle != nil else { return nil }
    }

    deinit {
        if let h = handle { text_reader_free(h) }
    }

    var wordCount: Int {
        guard let h = handle else { return 0 }
        return text_reader_get_word_count(h)
    }

    var currentWord: String? {
        guard let h = handle else { return nil }
        guard let ptr = text_reader_get_current_word(h) else { return nil }
        let word = String(cString: ptr)
        free_rust_string(ptr)
        return word
    }

    var currentIndex: Int {
        guard let h = handle else { return 0 }
        return text_reader_get_current_index(h)
    }

    var progress: Float {
        guard let h = handle else { return 0 }
        return text_reader_get_progress(h)
    }

    func nextWord() -> String? {
        guard let h = handle else { return nil }
        guard let ptr = text_reader_next_word(h) else { return nil }
        let word = String(cString: ptr)
        free_rust_string(ptr)
        return word
    }

    func previousWord() -> String? {
        guard let h = handle else { return nil }
        guard let ptr = text_reader_previous_word(h) else { return nil }
        let word = String(cString: ptr)
        free_rust_string(ptr)
        return word
    }

    func reset() {
        guard let h = handle else { return }
        text_reader_reset(h)
    }

    func seek(to index: Int) {
        guard let h = handle else { return }
        text_reader_seek(h, index)
    }
}

// MARK: - Content extraction helpers

enum ContentType {
    case plainText
    case html
    case pdf
    case unknown
}

/// Determine content type from HTTP response and URL.
func detectContentType(from response: URLResponse?, url: URL) -> ContentType {
    if let mimeType = response?.mimeType?.lowercased() {
        if mimeType.contains("pdf") { return .pdf }
        if mimeType.contains("html") { return .html }
        if mimeType.contains("text/plain") { return .plainText }
    }

    let ext = url.pathExtension.lowercased()
    switch ext {
    case "pdf": return .pdf
    case "html", "htm": return .html
    case "txt", "text", "md": return .plainText
    default: break
    }

    return .unknown
}

/// Use Rust to extract readable text from HTML data.
func extractHTMLText(from data: Data) -> String? {
    return data.withUnsafeBytes { rawBuffer -> String? in
        guard let base = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
        guard let ptr = extract_html_text(base, data.count) else { return nil }
        let text = String(cString: ptr)
        free_rust_string(ptr)
        return text
    }
}

/// Use Rust to extract readable text from PDF data.
func extractPDFText(from data: Data) -> String? {
    return data.withUnsafeBytes { rawBuffer -> String? in
        guard let base = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
        guard let ptr = extract_pdf_text(base, data.count) else { return nil }
        let text = String(cString: ptr)
        free_rust_string(ptr)
        return text
    }
}
