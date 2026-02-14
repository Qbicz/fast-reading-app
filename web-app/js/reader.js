/**
 * TextReader — word-by-word navigation engine.
 * Port of the Rust TextReader to JavaScript.
 */
export class TextReader {
    #words;
    #index;

    constructor(text) {
        this.#words = text.trim().split(/\s+/).filter(w => w.length > 0);
        this.#index = 0;
    }

    get wordCount() {
        return this.#words.length;
    }

    get currentIndex() {
        return this.#index;
    }

    get progress() {
        if (this.#words.length === 0) return 0;
        return Math.min(this.#index / this.#words.length, 1.0);
    }

    currentWord() {
        return this.#index < this.#words.length ? this.#words[this.#index] : null;
    }

    nextWord() {
        if (this.#words.length === 0) return null;
        if (this.#index < this.#words.length - 1) {
            this.#index++;
            return this.currentWord();
        }
        this.#index = this.#words.length;
        return null;
    }

    previousWord() {
        if (this.#index > 0) this.#index--;
        return this.currentWord();
    }

    seek(index) {
        if (this.#words.length === 0) {
            this.#index = 0;
            return;
        }
        this.#index = Math.min(Math.max(0, index), this.#words.length - 1);
    }

    reset() {
        this.#index = 0;
    }
}
