import { TextReader } from './reader.js';
import { extractFromURL, extractFromFile } from './extractor.js';

// ── State ───────────────────────────────────────────────────────────

let reader = null;
let timer = null;
let wpm = 300;
let isPlaying = false;
let readingStartTime = null;
let totalPauseTime = 0;
let lastPauseStart = null;

// ── DOM refs ────────────────────────────────────────────────────────

const $ = id => document.getElementById(id);

const inputScreen   = $('input-screen');
const readScreen    = $('read-screen');
const doneScreen    = $('done-screen');
const textInput     = $('text-input');
const urlInput      = $('url-input');
const fileInput     = $('file-input');
const wpmSlider     = $('wpm-slider');
const wpmLabel      = $('wpm-label');
const btnStart      = $('btn-start');
const btnUrl        = $('btn-url');
const btnFile       = $('btn-file');
const wordEl        = $('word');
const wordPre       = $('word-pre');
const wordFocus     = $('word-focus');
const wordPost      = $('word-post');
const progressBar   = $('progress-bar');
const progressText  = $('progress-text');
const btnPrev       = $('btn-prev');
const btnPlay       = $('btn-play');
const btnNext       = $('btn-next');
const btnStop       = $('btn-stop');
const btnRestart    = $('btn-restart');
const rWpmSlider    = $('read-wpm-slider');
const rWpmLabel     = $('read-wpm-label');
const loadingEl     = $('loading');
const toastEl       = $('toast');
const seekBar       = $('seek-bar');
const estTimeEl     = $('est-time');
const dropZone      = $('drop-zone');
const statWords     = $('stat-words');
const statTime      = $('stat-time');
const statSpeed     = $('stat-speed');
const btnDoneBack   = $('btn-done-back');
const btnDoneReread = $('btn-done-reread');

// ── Helpers ─────────────────────────────────────────────────────────

function showScreen(screen) {
    inputScreen.classList.toggle('hidden', screen !== 'input');
    readScreen.classList.toggle('hidden', screen !== 'read');
    doneScreen.classList.toggle('hidden', screen !== 'done');
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
    updateEstTime();
}

function updateEstTime() {
    const text = textInput.value.trim();
    const words = text ? text.split(/\s+/).filter(w => w.length > 0).length : 0;
    if (words === 0) {
        estTimeEl.textContent = '';
        return;
    }
    const seconds = Math.round((words / wpm) * 60);
    estTimeEl.textContent = `~${words} words · ${formatTime(seconds)} at ${wpm} WPM`;
}

function formatTime(totalSeconds) {
    if (totalSeconds < 60) return `${totalSeconds}s`;
    const m = Math.floor(totalSeconds / 60);
    const s = totalSeconds % 60;
    return s > 0 ? `${m}m ${s}s` : `${m}m`;
}

// ── ORP (Optimal Recognition Point) ────────────────────────────────
// The focus letter is positioned ~30% into the word for faster recognition.

function orpIndex(word) {
    const len = word.length;
    if (len <= 1) return 0;
    if (len <= 5) return 1;
    if (len <= 9) return 2;
    if (len <= 13) return 3;
    return 4;
}

function renderWord(word) {
    if (!word) {
        wordPre.textContent = '';
        wordFocus.textContent = '';
        wordPost.textContent = '';
        wordEl.classList.add('finished');
        return;
    }
    wordEl.classList.remove('finished');
    const i = orpIndex(word);
    wordPre.textContent = word.slice(0, i);
    wordFocus.textContent = word[i];
    wordPost.textContent = word.slice(i + 1);
}

// ── Reading engine ──────────────────────────────────────────────────

function startReading(text, fromURL = false) {
    const clean = text.trim();
    if (!clean) {
        showToast(fromURL
            ? 'No readable text found. This site may render content with JavaScript, which cannot be extracted. Try saving the page and opening it with the File button.'
            : 'No readable text found.');
        return;
    }

    reader = new TextReader(clean);
    if (reader.wordCount === 0) {
        showToast('No words found in the content.');
        reader = null;
        return;
    }

    isPlaying = false;
    readingStartTime = Date.now();
    totalPauseTime = 0;
    lastPauseStart = Date.now(); // starts paused
    updateUI();
    showScreen('read');
    wordEl.focus();
}

function updateUI() {
    if (!reader) return;
    const w = reader.currentWord();
    renderWord(w);

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
        showDoneScreen();
        return;
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
    // Track pause time
    if (lastPauseStart) {
        totalPauseTime += Date.now() - lastPauseStart;
        lastPauseStart = null;
    }
    isPlaying = true;
    const interval = 60000 / wpm;
    timer = setInterval(advance, interval);
    updateUI();
}

function stopAutoPlay() {
    clearInterval(timer);
    timer = null;
    if (isPlaying && !lastPauseStart) {
        lastPauseStart = Date.now();
    }
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
    readingStartTime = null;
    showScreen('input');
}

function restartReading() {
    if (!reader) return;
    stopAutoPlay();
    isPlaying = false;
    reader.reset();
    readingStartTime = Date.now();
    totalPauseTime = 0;
    lastPauseStart = Date.now();
    updateUI();
}

function setWpm(value) {
    wpm = Math.max(60, Math.min(1500, value));
    updateWpmDisplay();
    if (isPlaying) startAutoPlay();
}

// ── Done screen ─────────────────────────────────────────────────────

function showDoneScreen() {
    if (!reader) return;
    // Calculate stats
    const elapsed = Date.now() - readingStartTime;
    if (lastPauseStart) totalPauseTime += Date.now() - lastPauseStart;
    const activeMs = Math.max(elapsed - totalPauseTime, 1000);
    const activeMin = activeMs / 60000;
    const effectiveWpm = Math.round(reader.wordCount / activeMin);

    statWords.textContent = reader.wordCount.toLocaleString();
    statTime.textContent = formatTime(Math.round(activeMs / 1000));
    statSpeed.textContent = `${effectiveWpm} WPM`;

    showScreen('done');
}

function reread() {
    if (!reader) { showScreen('input'); return; }
    reader.reset();
    isPlaying = false;
    readingStartTime = Date.now();
    totalPauseTime = 0;
    lastPauseStart = Date.now();
    updateUI();
    showScreen('read');
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
        startReading(text, true);
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
btnDoneBack.addEventListener('click', stopReading);
btnDoneReread.addEventListener('click', reread);

// Install modal
const installModal = $('install-modal');
$('btn-install').addEventListener('click', () => installModal.classList.remove('hidden'));
$('btn-install-close').addEventListener('click', () => installModal.classList.add('hidden'));
installModal.addEventListener('click', e => {
    if (e.target === installModal) installModal.classList.add('hidden');
});

wpmSlider.addEventListener('input', e => setWpm(+e.target.value));
rWpmSlider.addEventListener('input', e => setWpm(+e.target.value));

textInput.addEventListener('input', updateEstTime);

seekBar.addEventListener('input', e => {
    if (!reader) return;
    const wasPlaying = isPlaying;
    if (isPlaying) { stopAutoPlay(); isPlaying = false; }
    reader.seek(+e.target.value);
    updateUI();
    if (wasPlaying) startAutoPlay();
});

// Enter key in URL input
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

// ── Tap to advance (mobile) ────────────────────────────────────────

let touchStartX = 0;
let touchStartY = 0;
const SWIPE_THRESHOLD = 50;

wordEl.addEventListener('touchstart', e => {
    touchStartX = e.changedTouches[0].clientX;
    touchStartY = e.changedTouches[0].clientY;
}, { passive: true });

wordEl.addEventListener('touchend', e => {
    const dx = e.changedTouches[0].clientX - touchStartX;
    const dy = e.changedTouches[0].clientY - touchStartY;

    if (Math.abs(dx) > SWIPE_THRESHOLD && Math.abs(dx) > Math.abs(dy)) {
        // Horizontal swipe
        if (dx > 0) goBack();      // swipe right = previous
        else advance();             // swipe left = next
    } else if (Math.abs(dx) < 10 && Math.abs(dy) < 10) {
        // Tap = toggle play/pause
        togglePlay();
    }
}, { passive: true });

// ── Drag and drop ──────────────────────────────────────────────────

['dragenter', 'dragover'].forEach(evt => {
    document.addEventListener(evt, e => {
        e.preventDefault();
        if (!inputScreen.classList.contains('hidden')) {
            dropZone.classList.remove('hidden');
        }
    });
});

['dragleave', 'drop'].forEach(evt => {
    document.addEventListener(evt, e => {
        e.preventDefault();
        dropZone.classList.add('hidden');
    });
});

document.addEventListener('drop', e => {
    e.preventDefault();
    dropZone.classList.add('hidden');
    const file = e.dataTransfer?.files?.[0];
    if (file) loadFromFile(file);
});

// ── Theme toggle ───────────────────────────────────────────────────

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

    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('sw.js').catch(() => {});
    }

    showScreen('input');
}

init();
