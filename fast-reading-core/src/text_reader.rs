/// Core text reader that splits text into words and provides word-by-word navigation.
pub struct TextReader {
    words: Vec<String>,
    index: usize,
}

impl TextReader {
    /// Create a new reader from a text string.
    pub fn new(text: String) -> Self {
        let words: Vec<String> = text
            .split_whitespace()
            .map(|s| s.to_string())
            .collect();
        Self { words, index: 0 }
    }

    /// Total number of words.
    pub fn word_count(&self) -> usize {
        self.words.len()
    }

    /// The word at the current position, or `None` if empty or past end.
    pub fn current_word(&self) -> Option<&str> {
        self.words.get(self.index).map(|s| s.as_str())
    }

    /// Current position index.
    pub fn current_index(&self) -> usize {
        self.index
    }

    /// Advance to the next word and return it.
    /// Returns `None` when already at (or past) the last word.
    pub fn next_word(&mut self) -> Option<&str> {
        if self.words.is_empty() {
            return None;
        }
        if self.index < self.words.len() - 1 {
            self.index += 1;
            self.current_word()
        } else {
            // Mark as finished by moving index past end.
            self.index = self.words.len();
            None
        }
    }

    /// Go back one word and return it.
    /// Returns current word if already at the start.
    pub fn previous_word(&mut self) -> Option<&str> {
        if self.index > 0 {
            self.index -= 1;
        }
        self.current_word()
    }

    /// Jump to a specific word index (clamped to valid range).
    pub fn seek(&mut self, target: usize) {
        if self.words.is_empty() {
            self.index = 0;
        } else {
            self.index = target.min(self.words.len() - 1);
        }
    }

    /// Reset to the beginning.
    pub fn reset(&mut self) {
        self.index = 0;
    }

    /// Reading progress as a float in `[0.0, 1.0]`.
    pub fn progress(&self) -> f32 {
        if self.words.is_empty() {
            return 0.0;
        }
        (self.index as f32 / self.words.len() as f32).min(1.0)
    }
}
