#ifndef FAST_READING_CORE_H
#define FAST_READING_CORE_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Opaque handle for TextReader */
typedef struct TextReaderHandle TextReaderHandle;

/* --- TextReader lifecycle --- */
TextReaderHandle* text_reader_new(const char* text);
void              text_reader_free(TextReaderHandle* handle);

/* --- Word navigation --- */
size_t text_reader_get_word_count(const TextReaderHandle* handle);
char*  text_reader_get_current_word(const TextReaderHandle* handle);
char*  text_reader_next_word(TextReaderHandle* handle);
char*  text_reader_previous_word(TextReaderHandle* handle);
void   text_reader_reset(TextReaderHandle* handle);
void   text_reader_seek(TextReaderHandle* handle, size_t index);
float  text_reader_get_progress(const TextReaderHandle* handle);
size_t text_reader_get_current_index(const TextReaderHandle* handle);

/* --- Content extraction --- */
char* extract_html_text(const uint8_t* data, size_t len);
char* extract_pdf_text(const uint8_t* data, size_t len);

/* --- Memory --- */
void free_rust_string(char* s);

#ifdef __cplusplus
}
#endif

#endif /* FAST_READING_CORE_H */
