/* TIPACK perf.js — sistem optimisasi animasi
   1. Mode LITE otomatis untuk device lemah (hemat data, RAM/CPU kecil, reduced motion, atau FPS terukur rendah)
   2. Animasi CSS & loop JS berhenti saat elemennya tidak terlihat di layar
   3. Semua animasi berhenti saat tab tidak aktif
   Override manual: ?perf=lite / ?perf=full  (tersimpan di localStorage), atau tombol di footer. */
(function () {
  const html = document.documentElement;
  const KEY = 'tipack-perf';
  const q = new URLSearchParams(location.search).get('perf');
  if (q === 'lite' || q === 'full') localStorage.setItem(KEY, q);
  if (q === 'auto') localStorage.removeItem(KEY);
  const saved = localStorage.getItem(KEY);

  const nav = navigator;
  const reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const saveData = !!(nav.connection && nav.connection.saveData);
  const veryWeak = (nav.deviceMemory && nav.deviceMemory <= 2) || (nav.hardwareConcurrency && nav.hardwareConcurrency <= 2);
  const suspect = (nav.deviceMemory && nav.deviceMemory <= 4) || (nav.hardwareConcurrency && nav.hardwareConcurrency <= 4);
  const weakHW = saveData || veryWeak;

  const PERF = window.PERF = {
    lite: saved ? saved === 'lite' : !!(reduced || weakHW),
    forced: !!saved,
    reduced,
    hidden: document.hidden,
    fps: null,
    _listeners: [],
    onChange(fn) { this._listeners.push(fn); },
    setLite(v, persist) {
      this.lite = v; html.classList.toggle('perf-lite', v);
      if (persist) localStorage.setItem(KEY, v ? 'lite' : 'full');
      this._listeners.forEach(f => f(v));
    },
    /* Elemen yang sedang terlihat di layar (diisi oleh observer di bawah) */
    isVisible(el) { return el && el.__vis !== false && !this.hidden; },
    /* Jalankan fn tiap frame hanya saat el terlihat & mode penuh */
    loop(el, fn) {
      let last = performance.now();
      const tick = t => {
        if (!PERF.hidden && el.__vis !== false && !PERF.lite) fn(t, Math.min(64, t - last));
        last = t; requestAnimationFrame(tick);
      };
      requestAnimationFrame(tick);
    }
  };
  html.classList.toggle('perf-lite', PERF.lite);
  if (reduced) html.classList.add('perf-reduced');

  /* --- pause saat tidak terlihat: semua elemen [data-anim] --- */
  const io = new IntersectionObserver(es => es.forEach(e => {
    e.target.__vis = e.isIntersecting;
    e.target.classList.toggle('anim-off', !e.isIntersecting);
  }), { rootMargin: '120px 0px' });
  const watch = () => document.querySelectorAll('[data-anim]').forEach(el => { if (!el.__watched) { el.__watched = 1; el.__vis = false; el.classList.add('anim-off'); io.observe(el); } });
  PERF.watch = watch;
  document.addEventListener('DOMContentLoaded', watch);

  /* --- pause saat tab tidak aktif --- */
  document.addEventListener('visibilitychange', () => { PERF.hidden = document.hidden; html.classList.toggle('tab-hidden', document.hidden); });

  /* --- probe FPS: 90 frame setelah halaman siap; kalau berat, turun ke lite --- */
  if (!saved && !PERF.lite) {
    addEventListener('load', () => setTimeout(() => {
      let n = 0, slow = 0, prev = performance.now();
      const probe = t => {
        const dt = t - prev; prev = t;
        if (n > 5 && dt > 28) slow++;          // frame lebih lambat dari ~35fps
        if (++n < 95) return requestAnimationFrame(probe);
        PERF.fps = Math.round(1000 / ((t - start) / n));
        if (slow > (suspect ? 18 : 30) && !document.hidden) PERF.setLite(true, false);
      };
      const start = performance.now();
      requestAnimationFrame(probe);
    }, 600));
  }

  /* --- throttle helper untuk pointermove --- */
  PERF.raf = fn => { let pend = false, ev; return e => { ev = e; if (!pend) { pend = true; requestAnimationFrame(() => { pend = false; fn(ev); }); } }; };
})();
