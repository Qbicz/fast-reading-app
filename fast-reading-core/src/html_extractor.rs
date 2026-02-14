use html2text::from_read;

/// Extract readable text from an HTML string.
///
/// Strips tags, scripts, styles and converts to plain text suitable for
/// word-by-word reading. Uses a column width of 200 to avoid aggressive
/// line-wrapping.
pub fn extract_text_from_html(html: &str) -> String {
    let bytes = html.as_bytes();
    let text = from_read(bytes, 200);

    // Clean up: collapse multiple blank lines and trim.
    let mut result = String::with_capacity(text.len());
    let mut prev_blank = false;
    for line in text.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() {
            if !prev_blank {
                result.push('\n');
                prev_blank = true;
            }
        } else {
            if prev_blank && !result.is_empty() {
                result.push('\n');
            }
            result.push_str(trimmed);
            result.push('\n');
            prev_blank = false;
        }
    }
    result.trim().to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn basic_extraction() {
        let html = "<p>Hello <b>world</b></p>";
        let text = extract_text_from_html(html);
        assert!(text.contains("Hello"));
        assert!(text.contains("world"));
    }

    #[test]
    fn strips_scripts_and_styles() {
        let html = r#"
            <html>
            <head><style>body{color:red}</style></head>
            <body>
                <script>var x=1;</script>
                <p>Readable content</p>
            </body>
            </html>
        "#;
        let text = extract_text_from_html(html);
        assert!(text.contains("Readable content"));
        assert!(!text.contains("var x"));
        assert!(!text.contains("color:red"));
    }

    #[test]
    fn preserves_text_structure() {
        let html = "<h1>Title</h1><p>First paragraph.</p><p>Second paragraph.</p>";
        let text = extract_text_from_html(html);
        assert!(text.contains("Title"));
        assert!(text.contains("First paragraph."));
        assert!(text.contains("Second paragraph."));
    }
}
