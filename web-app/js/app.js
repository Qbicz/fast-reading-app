import { TextReader } from './reader.js';
import { extractFromURL, extractFromFile, extractHTMLText } from './extractor.js';

// ── State ───────────────────────────────────────────────────────────

let reader = null;
let timer = null;
let wpm = 300;
let isPlaying = false;

// ── DOM refs ────────────────────────────────────────────────────────

const $ = id => document.getElementById(id);

const inputScreen  = $('input-screen');
const readScreen   = $('read-screen');
const textInput    = $('text-input');
const urlInput     = $('url-input');
const fileInput    = $('file-input');
const wpmSlider    = $('wpm-slider');
const wpmLabel     = $('wpm-label');
const btnStart     = $('btn-start');
const btnUrl       = $('btn-url');
const btnFile      = $('btn-file');
const wordEl       = $('word');
const progressBar  = $('progress-bar');
const progressText = $('progress-text');
const btnPrev      = $('btn-prev');
const btnPlay      = $('btn-play');
const btnNext      = $('btn-next');
const btnStop      = $('btn-stop');
const btnRestart   = $('btn-restart');
const rWpmSlider   = $('read-wpm-slider');
const rWpmLabel    = $('read-wpm-label');
const loadingEl    = $('loading');
const toastEl      = $('toast');
const seekBar      = $('seek-bar');

// ── Helpers ─────────────────────────────────────────────────────────

function showScreen(screen) {
    inputScreen.classList.toggle('hidden', screen !== 'input');
    readScreen.classList.toggle('hidden', screen !== 'read');
}

function showLoading(show) {
    loadingEl.classList.toggle('hidden', !show);
}

function showToast(msg, duration = 4000) {
    toastEl.textContent = msg;
    toastEl.classList.add('visible');
    setTimeout(() => toastEl.classList.remove('visible'), duration);
}

function updateWpmDisplay() {
    wpmLabel.textContent = `${wpm} WPM`;
    rWpmLabel.textContent = `${wpm} WPM`;
    wpmSlider.value = wpm;
    rWpmSlider.value = wpm;
}

// ── Reading engine ──────────────────────────────────────────────────

function startReading(text) {
    const clean = text.trim();
    if (!clean) {
        showToast('No readable text found.');
        return;
    }

    reader = new TextReader(clean);
    if (reader.wordCount === 0) {
        showToast('No words found in the content.');
        reader = null;
        return;
    }

    isPlaying = false;
    updateUI();
    showScreen('read');
    wordEl.focus();
}

function updateUI() {
    if (!reader) return;
    const w = reader.currentWord();
    wordEl.textContent = w || '—';
    wordEl.classList.toggle('finished', w === null);

    const pct = reader.progress * 100;
    progressBar.style.width = `${pct}%`;
    progressBar.classList.toggle('complete', pct >= 100);

    const idx = Math.min(reader.currentIndex + 1, reader.wordCount);
    progressText.textContent = `${idx} / ${reader.wordCount}`;

    seekBar.max = reader.wordCount - 1;
    seekBar.value = reader.currentIndex;

    btnPrev.disabled = reader.currentIndex === 0;
    btnNext.disabled = reader.progress >= 1.0;
    btnPlay.innerHTML = isPlaying
        ? '<svg viewBox="0 0 24 24"><rect x="6" y="4" width="4" height="16" rx="1"/><rect x="14" y="4" width="4" height="16" rx="1"/></svg>'
        : '<svg viewBox="0 0 24 24"><polygon points="5,3 19,12 5,21"/></svg>';
    btnPlay.setAttribute('aria-label', isPlaying ? 'Pause' : 'Play');
}

function advance() {
    if (!reader) return;
    const w = reader.nextWord();
    if (w === null) {
        stopAutoPlay();
        isPlaying = false;
    }
    updateUI();
}

function goBack() {
    if (!reader) return;
    reader.previousWord();
    updateUI();
}

function startAutoPlay() {
    stopAutoPlay();
    isPlaying = true;
    const interval = 60000 / wpm;
    timer = setInterval(advance, interval);
    updateUI();
}

function stopAutoPlay() {
    clearInterval(timer);
    timer = null;
}

function togglePlay() {
    if (isPlaying) {
        stopAutoPlay();
        isPlaying = false;
        updateUI();
    } else {
        startAutoPlay();
    }
}

function stopReading() {
    stopAutoPlay();
    isPlaying = false;
    reader = null;
    showScreen('input');
}

function restartReading() {
    if (!reader) return;
    stopAutoPlay();
    isPlaying = false;
    reader.reset();
    updateUI();
}

function setWpm(value) {
    wpm = Math.max(60, Math.min(1500, value));
    updateWpmDisplay();
    if (isPlaying) startAutoPlay(); // restart timer with new interval
}

// ── Content loading ─────────────────────────────────────────────────

async function loadFromText() {
    const text = textInput.value.trim();
    if (!text) {
        showToast('Please enter some text first.');
        return;
    }
    startReading(text);
}

async function loadFromURL() {
    let url = urlInput.value.trim();
    if (!url) {
        showToast('Please enter a URL.');
        return;
    }
    if (!/^https?:\/\//i.test(url)) url = 'https://' + url;

    showLoading(true);
    try {
        const text = await extractFromURL(url);
        startReading(text);
    } catch (err) {
        showToast(err.message || 'Failed to load URL.');
    } finally {
        showLoading(false);
    }
}

async function loadFromFile(file) {
    if (!file) return;
    showLoading(true);
    try {
        const text = await extractFromFile(file);
        startReading(text);
    } catch (err) {
        showToast(err.message || 'Failed to read file.');
    } finally {
        showLoading(false);
    }
}

// ── Event binding ───────────────────────────────────────────────────

btnStart.addEventListener('click', loadFromText);
btnUrl.addEventListener('click', loadFromURL);
btnFile.addEventListener('click', () => fileInput.click());
fileInput.addEventListener('change', () => {
    if (fileInput.files[0]) loadFromFile(fileInput.files[0]);
    fileInput.value = '';
});

btnPlay.addEventListener('click', togglePlay);
btnPrev.addEventListener('click', goBack);
btnNext.addEventListener('click', advance);
btnStop.addEventListener('click', stopReading);
btnRestart.addEventListener('click', restartReading);

wpmSlider.addEventListener('input', e => setWpm(+e.target.value));
rWpmSlider.addEventListener('input', e => setWpm(+e.target.value));

seekBar.addEventListener('input', e => {
    if (!reader) return;
    const wasPlaying = isPlaying;
    if (isPlaying) { stopAutoPlay(); isPlaying = false; }
    reader.seek(+e.target.value);
    updateUI();
    if (wasPlaying) startAutoPlay();
});

// Allow Enter key in URL input
urlInput.addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); loadFromURL(); }
});

// Keyboard shortcuts in reading view
document.addEventListener('keydown', e => {
    if (readScreen.classList.contains('hidden')) return;
    if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;

    switch (e.key) {
        case ' ':        e.preventDefault(); togglePlay(); break;
        case 'ArrowRight': e.preventDefault(); advance(); break;
        case 'ArrowLeft':  e.preventDefault(); goBack(); break;
        case 'ArrowUp':    e.preventDefault(); setWpm(wpm + 30); break;
        case 'ArrowDown':  e.preventDefault(); setWpm(wpm - 30); break;
        case 'Escape':     e.preventDefault(); stopReading(); break;
        case 'r':          e.preventDefault(); restartReading(); break;
    }
});

// Theme toggle
$('btn-theme').addEventListener('click', () => {
    const html = document.documentElement;
    const current = html.getAttribute('data-theme');
    const next = current === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
});

// ── Init ────────────────────────────────────────────────────────────

function init() {
    const saved = localStorage.getItem('theme');
    if (saved) {
        document.documentElement.setAttribute('data-theme', saved);
    } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.setAttribute('data-theme', 'dark');
    }

    const savedWpm = localStorage.getItem('wpm');
    if (savedWpm) wpm = +savedWpm;
    updateWpmDisplay();

    wpmSlider.addEventListener('change', () => localStorage.setItem('wpm', wpm));
    rWpmSlider.addEventListener('change', () => localStorage.setItem('wpm', wpm));

    // Register service worker
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('sw.js').catch(() => {});
    }

    showScreen('input');
}

init();
