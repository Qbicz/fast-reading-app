/**
 * Content extraction utilities.
 *
 * - HTML: uses the browser's built-in DOMParser (best quality, zero dependencies).
 * - PDF:  uses Mozilla's pdf.js loaded on demand from CDN.
 * - Text: passthrough.
 */

const PDFJS_CDN = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379';

// ── Content-type detection ──────────────────────────────────────────

export function detectContentType(contentTypeHeader, url) {
    const mime = (contentTypeHeader || '').toLowerCase();
    if (mime.includes('pdf')) return 'pdf';
    if (mime.includes('html')) return 'html';
    if (mime.includes('text/plain')) return 'text';

    const ext = new URL(url, 'https://x').pathname.split('.').pop()?.toLowerCase() || '';
    if (ext === 'pdf') return 'pdf';
    if (['html', 'htm'].includes(ext)) return 'html';
    if (['txt', 'text', 'md', 'csv'].includes(ext)) return 'text';

    return 'unknown'; // will be treated as HTML
}

// ── HTML extraction ─────────────────────────────────────────────────

export function extractHTMLText(html) {
    const doc = new DOMParser().parseFromString(html, 'text/html');

    // Remove non-content elements
    const remove = [
        'script', 'style', 'noscript', 'iframe', 'svg',
        'nav', 'footer', 'header', 'aside',
        '[role="navigation"]', '[role="banner"]', '[role="contentinfo"]',
        '[aria-hidden="true"]',
    ];
    remove.forEach(sel => {
        doc.querySelectorAll(sel).forEach(el => el.remove());
    });

    // Prefer main content regions
    const main = doc.querySelector(
        'main, article, [role="main"], .post-content, .article-body, ' +
        '.entry-content, .content, #content, #article'
    );
    const source = main || doc.body;
    if (!source) return '';

    // Get text, collapse whitespace
    return source.textContent
        .replace(/[\t ]+/g, ' ')
        .replace(/\n{3,}/g, '\n\n')
        .trim();
}

// ── PDF extraction ──────────────────────────────────────────────────

let pdfjsLib = null;

async function loadPdfJs() {
    if (pdfjsLib) return pdfjsLib;
    pdfjsLib = await import(`${PDFJS_CDN}/pdf.min.mjs`);
    pdfjsLib.GlobalWorkerOptions.workerSrc = `${PDFJS_CDN}/pdf.worker.min.mjs`;
    return pdfjsLib;
}

export async function extractPDFText(arrayBuffer) {
    const lib = await loadPdfJs();
    const pdf = await lib.getDocument({ data: arrayBuffer }).promise;
    const pages = [];

    for (let i = 1; i <= pdf.numPages; i++) {
        const page = await pdf.getPage(i);
        const content = await page.getTextContent();
        const text = content.items.map(item => item.str).join(' ');
        if (text.trim()) pages.push(text.trim());
    }

    return pages.join('\n\n');
}

// ── Fetch with CORS fallback ────────────────────────────────────────

const CORS_PROXIES = [
    url => `https://corsproxy.io/?${encodeURIComponent(url)}`,
    url => `https://api.allorigins.win/raw?url=${encodeURIComponent(url)}`,
];

export async function fetchWithCORSFallback(url) {
    // Try direct fetch first
    try {
        const res = await fetch(url);
        if (res.ok) return res;
    } catch (_) {
        // Likely CORS — try proxies
    }

    for (const proxy of CORS_PROXIES) {
        try {
            const res = await fetch(proxy(url));
            if (res.ok) return res;
        } catch (_) {
            continue;
        }
    }

    throw new Error(
        'Could not fetch the URL. The website may block external access. ' +
        'Try downloading the page/PDF and opening it with the File button instead.'
    );
}

// ── High-level extraction from URL ──────────────────────────────────

export async function extractFromURL(url) {
    const response = await fetchWithCORSFallback(url);
    const ct = detectContentType(response.headers.get('content-type'), url);

    if (ct === 'pdf') {
        const buf = await response.arrayBuffer();
        return await extractPDFText(buf);
    }

    const text = await response.text();
    if (ct === 'text') return text;

    // html or unknown — parse as HTML
    return extractHTMLText(text);
}

// ── Extraction from File ────────────────────────────────────────────

export async function extractFromFile(file) {
    const name = file.name.toLowerCase();

    if (name.endsWith('.pdf')) {
        const buf = await file.arrayBuffer();
        return await extractPDFText(buf);
    }

    // Treat everything else as text
    return await file.text();
}
