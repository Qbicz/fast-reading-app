import Foundation

/// Swift wrapper for the Rust TextReader
class TextReader {
    private var handle: OpaquePointer?
    
    init?(text: String) {
        guard let cText = text.cString(using: .utf8) else {
            return nil
        }
        handle = text_reader_new(cText)
        if handle == nil {
            return nil
        }
    }
    
    deinit {
        if let handle = handle {
            text_reader_free(handle)
        }
    }
    
    var wordCount: Int {
        guard let handle = handle else { return 0 }
        return text_reader_get_word_count(handle)
    }
    
    var currentWord: String? {
        guard let handle = handle else { return nil }
        guard let cString = text_reader_get_current_word(handle) else {
            return nil
        }
        let word = String(cString: cString)
        free_string(cString)
        return word
    }
    
    var progress: Float {
        guard let handle = handle else { return 0.0 }
        return text_reader_get_progress(handle)
    }
    
    func nextWord() -> String? {
        guard let handle = handle else { return nil }
        guard let cString = text_reader_next_word(handle) else {
            return nil
        }
        let word = String(cString: cString)
        free_string(cString)
        return word
    }
    
    func previousWord() -> String? {
        guard let handle = handle else { return nil }
        guard let cString = text_reader_previous_word(handle) else {
            return nil
        }
        let word = String(cString: cString)
        free_string(cString)
        return word
    }
    
    func reset() {
        guard let handle = handle else { return }
        text_reader_reset(handle)
    }
}
