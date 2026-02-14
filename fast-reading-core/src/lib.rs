use std::ffi::{c_char, CStr, CString};

mod text_reader;
mod html_extractor;
mod pdf_extractor;

pub use text_reader::TextReader;
pub use html_extractor::extract_text_from_html;
pub use pdf_extractor::extract_text_from_pdf;

// ---------------------------------------------------------------------------
// Opaque FFI handle
// ---------------------------------------------------------------------------

#[repr(C)]
pub struct TextReaderHandle {
    _private: [u8; 0],
}

// ---------------------------------------------------------------------------
// TextReader FFI
// ---------------------------------------------------------------------------

/// Create a new TextReader from a plain-text string.
#[no_mangle]
pub extern "C" fn text_reader_new(text: *const c_char) -> *mut TextReaderHandle {
    if text.is_null() {
        return std::ptr::null_mut();
    }
    let c_str = unsafe { CStr::from_ptr(text) };
    let text_str = match c_str.to_str() {
        Ok(s) => s.to_string(),
        Err(_) => return std::ptr::null_mut(),
    };
    let reader = Box::new(TextReader::new(text_str));
    Box::into_raw(reader) as *mut TextReaderHandle
}

/// Free a TextReader.
#[no_mangle]
pub extern "C" fn text_reader_free(handle: *mut TextReaderHandle) {
    if !handle.is_null() {
        unsafe {
            let _ = Box::from_raw(handle as *mut TextReader);
        }
    }
}

/// Total number of words.
#[no_mangle]
pub extern "C" fn text_reader_get_word_count(handle: *const TextReaderHandle) -> usize {
    if handle.is_null() {
        return 0;
    }
    let reader = unsafe { &*(handle as *const TextReader) };
    reader.word_count()
}

/// Current word as a C string (caller must free with `free_rust_string`).
#[no_mangle]
pub extern "C" fn text_reader_get_current_word(handle: *const TextReaderHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let reader = unsafe { &*(handle as *const TextReader) };
    match reader.current_word() {
        Some(w) => CString::new(w).map(|c| c.into_raw()).unwrap_or(std::ptr::null_mut()),
        None => std::ptr::null_mut(),
    }
}

/// Advance to next word, returning it (caller must free with `free_rust_string`).
#[no_mangle]
pub extern "C" fn text_reader_next_word(handle: *mut TextReaderHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let reader = unsafe { &mut *(handle as *mut TextReader) };
    match reader.next_word() {
        Some(w) => CString::new(w).map(|c| c.into_raw()).unwrap_or(std::ptr::null_mut()),
        None => std::ptr::null_mut(),
    }
}

/// Go back one word, returning it (caller must free with `free_rust_string`).
#[no_mangle]
pub extern "C" fn text_reader_previous_word(handle: *mut TextReaderHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let reader = unsafe { &mut *(handle as *mut TextReader) };
    match reader.previous_word() {
        Some(w) => CString::new(w).map(|c| c.into_raw()).unwrap_or(std::ptr::null_mut()),
        None => std::ptr::null_mut(),
    }
}

/// Reset reading position to the beginning.
#[no_mangle]
pub extern "C" fn text_reader_reset(handle: *mut TextReaderHandle) {
    if !handle.is_null() {
        let reader = unsafe { &mut *(handle as *mut TextReader) };
        reader.reset();
    }
}

/// Jump to a specific word index.
#[no_mangle]
pub extern "C" fn text_reader_seek(handle: *mut TextReaderHandle, index: usize) {
    if !handle.is_null() {
        let reader = unsafe { &mut *(handle as *mut TextReader) };
        reader.seek(index);
    }
}

/// Reading progress as a float in [0.0, 1.0].
#[no_mangle]
pub extern "C" fn text_reader_get_progress(handle: *const TextReaderHandle) -> f32 {
    if handle.is_null() {
        return 0.0;
    }
    let reader = unsafe { &*(handle as *const TextReader) };
    reader.progress()
}

/// Current word index.
#[no_mangle]
pub extern "C" fn text_reader_get_current_index(handle: *const TextReaderHandle) -> usize {
    if handle.is_null() {
        return 0;
    }
    let reader = unsafe { &*(handle as *const TextReader) };
    reader.current_index()
}

// ---------------------------------------------------------------------------
// Content extraction FFI
// ---------------------------------------------------------------------------

/// Extract readable text from HTML bytes.
/// Returns a C string (caller must free with `free_rust_string`).
#[no_mangle]
pub extern "C" fn extract_html_text(
    data: *const u8,
    len: usize,
) -> *mut c_char {
    if data.is_null() || len == 0 {
        return std::ptr::null_mut();
    }
    let slice = unsafe { std::slice::from_raw_parts(data, len) };
    let html = match std::str::from_utf8(slice) {
        Ok(s) => s,
        Err(_) => return std::ptr::null_mut(),
    };
    let text = extract_text_from_html(html);
    CString::new(text).map(|c| c.into_raw()).unwrap_or(std::ptr::null_mut())
}

/// Extract readable text from PDF bytes.
/// Returns a C string (caller must free with `free_rust_string`).
#[no_mangle]
pub extern "C" fn extract_pdf_text(
    data: *const u8,
    len: usize,
) -> *mut c_char {
    if data.is_null() || len == 0 {
        return std::ptr::null_mut();
    }
    let slice = unsafe { std::slice::from_raw_parts(data, len) };
    match extract_text_from_pdf(slice) {
        Ok(text) => CString::new(text).map(|c| c.into_raw()).unwrap_or(std::ptr::null_mut()),
        Err(_) => std::ptr::null_mut(),
    }
}

/// Free a C string returned by any function in this library.
#[no_mangle]
pub extern "C" fn free_rust_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_reader_basic() {
        let mut r = TextReader::new("Hello world from Rust".into());
        assert_eq!(r.word_count(), 4);
        assert_eq!(r.current_word(), Some("Hello"));
        assert_eq!(r.next_word(), Some("world"));
        assert_eq!(r.next_word(), Some("from"));
        assert_eq!(r.next_word(), Some("Rust"));
        assert_eq!(r.next_word(), None);
    }

    #[test]
    fn test_reader_navigation() {
        let mut r = TextReader::new("A B C D E".into());
        assert_eq!(r.current_word(), Some("A"));
        r.next_word();
        r.next_word();
        assert_eq!(r.current_word(), Some("C"));
        r.previous_word();
        assert_eq!(r.current_word(), Some("B"));
        r.reset();
        assert_eq!(r.current_word(), Some("A"));
    }

    #[test]
    fn test_reader_seek() {
        let mut r = TextReader::new("one two three four five".into());
        r.seek(3);
        assert_eq!(r.current_word(), Some("four"));
        r.seek(100);
        assert_eq!(r.current_index(), 4); // clamped to last index
    }

    #[test]
    fn test_reader_progress() {
        let mut r = TextReader::new("A B C D".into());
        assert!((r.progress() - 0.0).abs() < f32::EPSILON);
        r.next_word();
        assert!((r.progress() - 0.25).abs() < f32::EPSILON);
        r.next_word();
        assert!((r.progress() - 0.5).abs() < f32::EPSILON);
        r.next_word();
        assert!((r.progress() - 0.75).abs() < f32::EPSILON);
        r.next_word(); // past end
        assert!((r.progress() - 1.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_reader_empty() {
        let r = TextReader::new("".into());
        assert_eq!(r.word_count(), 0);
        assert_eq!(r.current_word(), None);
        assert!((r.progress() - 0.0).abs() < f32::EPSILON);
    }

    #[test]
    fn test_html_extraction() {
        let html = "<html><body><h1>Title</h1><p>Hello world</p></body></html>";
        let text = extract_text_from_html(html);
        assert!(text.contains("Title"));
        assert!(text.contains("Hello world"));
        assert!(!text.contains("<h1>"));
    }

    #[test]
    fn test_html_script_removal() {
        let html = "<html><body><script>alert('x')</script><p>Content here</p></body></html>";
        let text = extract_text_from_html(html);
        assert!(text.contains("Content here"));
        assert!(!text.contains("alert"));
    }
}
