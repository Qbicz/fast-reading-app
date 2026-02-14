/// Extract readable text from raw PDF bytes.
///
/// Uses the `pdf_extract` crate to pull all text content from every page
/// of the PDF.
pub fn extract_text_from_pdf(data: &[u8]) -> Result<String, String> {
    pdf_extract::extract_text_from_mem(data).map_err(|e| format!("PDF extraction error: {e}"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn rejects_invalid_pdf() {
        let result = extract_text_from_pdf(b"this is not a pdf");
        assert!(result.is_err());
    }
}
