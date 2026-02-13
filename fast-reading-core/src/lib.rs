use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/// Core text parsing and processing functionality
pub struct TextReader {
    words: Vec<String>,
    current_index: usize,
}

impl TextReader {
    pub fn new(text: String) -> Self {
        let words = Self::parse_text(&text);
        TextReader {
            words,
            current_index: 0,
        }
    }

    fn parse_text(text: &str) -> Vec<String> {
        text.split_whitespace()
            .map(|s| s.to_string())
            .collect()
    }

    pub fn get_word_count(&self) -> usize {
        self.words.len()
    }

    pub fn get_current_word(&self) -> Option<&str> {
        self.words.get(self.current_index).map(|s| s.as_str())
    }

    pub fn next_word(&mut self) -> Option<&str> {
        if self.current_index < self.words.len() - 1 {
            self.current_index += 1;
            self.get_current_word()
        } else if self.current_index == self.words.len() - 1 {
            // At last word, mark as complete but don't advance
            self.current_index = self.words.len();
            None
        } else {
            // Already past the end
            None
        }
    }

    pub fn previous_word(&mut self) -> Option<&str> {
        if self.current_index > 0 {
            self.current_index -= 1;
        }
        self.get_current_word()
    }

    pub fn reset(&mut self) {
        self.current_index = 0;
    }

    pub fn get_progress(&self) -> f32 {
        if self.words.is_empty() {
            return 0.0;
        }
        // Cap progress at 1.0
        let progress = self.current_index as f32 / self.words.len() as f32;
        progress.min(1.0)
    }
}

// C FFI Interface for Swift

#[repr(C)]
pub struct TextReaderHandle {
    _private: [u8; 0],
}

/// Create a new text reader from text
/// Returns an opaque pointer that must be freed with text_reader_free
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

/// Free a text reader
#[no_mangle]
pub extern "C" fn text_reader_free(handle: *mut TextReaderHandle) {
    if !handle.is_null() {
        unsafe {
            let _ = Box::from_raw(handle as *mut TextReader);
        }
    }
}

/// Get the total word count
#[no_mangle]
pub extern "C" fn text_reader_get_word_count(handle: *const TextReaderHandle) -> usize {
    if handle.is_null() {
        return 0;
    }
    let reader = unsafe { &*(handle as *const TextReader) };
    reader.get_word_count()
}

/// Get the current word
/// Returns a C string that must be freed with free_string
#[no_mangle]
pub extern "C" fn text_reader_get_current_word(handle: *const TextReaderHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let reader = unsafe { &*(handle as *const TextReader) };
    
    match reader.get_current_word() {
        Some(word) => match CString::new(word) {
            Ok(c_string) => c_string.into_raw(),
            Err(_) => std::ptr::null_mut(),
        },
        None => std::ptr::null_mut(),
    }
}

/// Move to the next word
#[no_mangle]
pub extern "C" fn text_reader_next_word(handle: *mut TextReaderHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let reader = unsafe { &mut *(handle as *mut TextReader) };
    
    match reader.next_word() {
        Some(word) => match CString::new(word) {
            Ok(c_string) => c_string.into_raw(),
            Err(_) => std::ptr::null_mut(),
        },
        None => std::ptr::null_mut(),
    }
}

/// Move to the previous word
#[no_mangle]
pub extern "C" fn text_reader_previous_word(handle: *mut TextReaderHandle) -> *mut c_char {
    if handle.is_null() {
        return std::ptr::null_mut();
    }
    let reader = unsafe { &mut *(handle as *mut TextReader) };
    
    match reader.previous_word() {
        Some(word) => match CString::new(word) {
            Ok(c_string) => c_string.into_raw(),
            Err(_) => std::ptr::null_mut(),
        },
        None => std::ptr::null_mut(),
    }
}

/// Reset to the beginning
#[no_mangle]
pub extern "C" fn text_reader_reset(handle: *mut TextReaderHandle) {
    if !handle.is_null() {
        let reader = unsafe { &mut *(handle as *mut TextReader) };
        reader.reset();
    }
}

/// Get reading progress (0.0 to 1.0)
#[no_mangle]
pub extern "C" fn text_reader_get_progress(handle: *const TextReaderHandle) -> f32 {
    if handle.is_null() {
        return 0.0;
    }
    let reader = unsafe { &*(handle as *const TextReader) };
    reader.get_progress()
}

/// Free a string returned by this library
#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_text_reader_creation() {
        let reader = TextReader::new("Hello world from Rust".to_string());
        assert_eq!(reader.get_word_count(), 4);
    }

    #[test]
    fn test_word_navigation() {
        let mut reader = TextReader::new("One Two Three".to_string());
        assert_eq!(reader.get_current_word(), Some("One"));
        assert_eq!(reader.next_word(), Some("Two"));
        assert_eq!(reader.next_word(), Some("Three"));
        assert_eq!(reader.next_word(), None);
        // Verify multiple calls after end continue to return None
        assert_eq!(reader.next_word(), None);
        assert_eq!(reader.next_word(), None);
        assert_eq!(reader.previous_word(), Some("Three"));
        assert_eq!(reader.previous_word(), Some("Two"));
    }

    #[test]
    fn test_progress() {
        let mut reader = TextReader::new("A B C D".to_string());
        assert_eq!(reader.get_progress(), 0.0);
        reader.next_word();
        assert_eq!(reader.get_progress(), 0.25);
        reader.next_word();
        assert_eq!(reader.get_progress(), 0.5);
        reader.next_word();
        assert_eq!(reader.get_progress(), 0.75);
        reader.next_word();
        // Progress should be capped at 1.0
        assert_eq!(reader.get_progress(), 1.0);
        reader.next_word();
        assert_eq!(reader.get_progress(), 1.0);
    }

    #[test]
    fn test_reset() {
        let mut reader = TextReader::new("X Y Z".to_string());
        reader.next_word();
        reader.next_word();
        reader.reset();
        assert_eq!(reader.get_current_word(), Some("X"));
    }
}
