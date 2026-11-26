// TIPACK GUI: antarmuka. Semua pekerjaan dilakukan mesin TIPACK (setup.ps1/setup.sh) lewat perintah Tauri `run_engine`.
const T = window.__TAURI__;
const invoke = T ? T.core.invoke : async () => { throw new Error('Mode pratinjau: Tauri tidak tersedia'); };
const listen = T ? T.event.listen : async () => {};
const openUrl = T && T.opener ? T.opener.openUrl : u => window.open(u, '_blank');
const $ = (s, r = document) => r.querySelector(s), $$ = (s, r = document) => [...r.querySelectorAll(s)];
const esc = s => String(s ?? '').replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
const S = { os: 'win', cat: '', q: '', sel: new Set(), inst: new Set(), avail: null, cat_data: null, icons: {}, app: {}, findings: [] };
const COLORS = ['#7c3aed', '#db2777', '#2563eb', '#0891b2', '#16a34a', '#ea580c', '#9333ea', '#0d9488'];
const short = n => n.replace(/ \((?!gratis).*?\)/g, '');
const glyph = n => { const w = n.replace(/\(.*?\)/g, '').replace(/[^A-Za-z0-9+#. ]/g, ' ').trim().split(/\s+/); return ((w.length > 1 && w[0].length < 7) ? w[0][0] + w[1][0] : w[0].slice(0, 2)).toUpperCase(); };
function icon(k) {
  const m = S.icons[k]; if (m) return `<img src="icons/${m.slug}.svg" alt="">`;
  const col = COLORS[[...k].reduce((x, c) => x + c.charCodeAt(0), 0) % COLORS.length];
  return `<span class="mono" style="background:linear-gradient(140deg,${col},#1e1b2e)">${esc(glyph((S.app[k] || { name: k }).name))}</span>`;
}
function toast(t) { const e = $('#toast'); e.textContent = t; e.classList.add('on'); clearTimeout(toast.t); toast.t = setTimeout(() => e.classList.remove('on'), 2600); }

/* ---------------- navigasi ---------------- */
$$('#nav button').forEach(b => b.onclick = () => {
  $$('#nav button').forEach(x => x.classList.toggle('on', x === b));
  $$('.view').forEach(v => v.classList.toggle('on', v.id === 'v-' + b.dataset.view));
  $('#tray').style.display = ['apps', 'profiles', 'config'].includes(b.dataset.view) ? '' : 'none';
});

/* ---------------- event mesin ---------------- */
let runCtx = null;
listen('engine-event', ({ payload: e }) => {
  if (e.t === 'sys') { $('#sys').classList.add('ready'); $('#sys').innerHTML = `<span class="dot"></span><span>${esc(e.os)}<br>${esc(e.arch)}${e.pm ? ' · ' + esc(e.pm) : ''}${e.ram ? ' · RAM ' + e.ram + ' GB' : ''}</span>`; }
  if (e.t === 'scan') { S.inst = new Set(e.installed || []); S.avail = new Set(e.available || []); renderApps(); }
  if (e.t === 'doctor') S.findings.push(e);
  if (e.t === 'report') showReport(e);
  if (runCtx) runCtx(e);
});
listen('engine-log', ({ payload }) => { const l = $('#runLog'); if (l) { l.textContent += payload + '\n'; if (l.textContent.length > 60000) l.textContent = l.textContent.slice(-50000); l.scrollTop = l.scrollHeight; } });

async function engine(args) {
  try { return await invoke('run_engine', { args }); }
  catch (err) { toast(String(err)); return -1; }
}

/* ---------------- katalog ---------------- */
function renderApps() {
  if (!S.cat_data) return;
  const q = S.q.toLowerCase();
  const list = S.cat_data.apps.filter(a => a[S.os] && (!S.avail || S.avail.has(a.key)) && (!q || (a.name + ' ' + a.cat + ' ' + a.key + ' ' + a.tip).toLowerCase().includes(q)));
  const cnt = {}; list.forEach(a => cnt[a.cat] = (cnt[a.cat] || 0) + 1);
  if (S.cat && !cnt[S.cat]) S.cat = '';
  $('#cats').innerHTML = `<button data-c="" class="${S.cat ? '' : 'on'}">Semua<i>${list.length}</i></button>` + S.cat_data.categories.filter(c => cnt[c]).map(c => `<button data-c="${esc(c)}" class="${S.cat === c ? 'on' : ''}">${esc(c)}<i>${cnt[c]}</i></button>`).join('');
  $$('#cats button').forEach(b => b.onclick = () => { S.cat = b.dataset.c; renderApps(); });
  let html = '';
  for (const c of S.cat_data.categories) {
    const g = list.filter(a => a.cat === c && (!S.cat || S.cat === c)); if (!g.length) continue;
    html += `<div class="grp"><h4>${esc(c)}</h4><div class="grid">${g.map(a => { const inst = S.inst.has(a.key);
      return `<button class="app ${inst ? 'inst' : ''} ${S.sel.has(a.key) ? 'on' : ''}" data-k="${a.key}" title="${esc(a.tip)}">${a.rec ? '<span class="rec">REK</span>' : ''}${icon(a.key)}<span class="t"><b>${esc(short(a.name))}</b><small>${esc(a.tip)}</small></span>${inst ? '<span class="badge">✓ ada</span>' : '<span class="ck"></span>'}</button>`; }).join('')}</div></div>`;
  }
  $('#grid').innerHTML = html || '<p class="muted">Tidak ada aplikasi yang cocok.</p>';
  $('#appsSub').textContent = `${list.length} aplikasi tersedia untuk sistem ini · ${S.inst.size} sudah terpasang. Pilih lalu tekan Pasang.`;
  renderTray();
}
document.addEventListener('click', e => {
  const b = e.target.closest('.app[data-k]'); if (!b || b.classList.contains('inst')) return;
  const k = b.dataset.k; S.sel.has(k) ? S.sel.delete(k) : S.sel.add(k); b.classList.toggle('on', S.sel.has(k)); renderTray();
});
function renderTray() {
  const ks = [...S.sel].filter(k => S.app[k] && S.app[k][S.os]);
  $('#selN').textContent = ks.length;
  $('#chips').innerHTML = ks.slice(0, 12).map(k => `<span>${esc(short(S.app[k].name))}</span>`).join('') + (ks.length > 12 ? `<span>+${ks.length - 12}</span>` : '');
  $('#install').disabled = !ks.length;
}
let tq; $('#q').oninput = e => { clearTimeout(tq); tq = setTimeout(() => { S.q = e.target.value.trim(); renderApps(); }, 120); };
$('#clear').onclick = () => { S.sel.clear(); renderApps(); };

/* ---------------- instalasi ---------------- */
$('#install').onclick = async () => {
  const ks = [...S.sel].filter(k => S.app[k] && S.app[k][S.os] && !S.inst.has(k));
  if (!ks.length) return toast('Semua aplikasi pilihan sudah terpasang');
  const items = {}; let total = ks.length, done = 0;
  $('#runTitle').textContent = `Memasang ${total} aplikasi`; $('#runBar').style.width = '0%'; $('#runLog').textContent = ''; $('#runSum').textContent = '';
  $('#runItems').innerHTML = ks.map(k => `<div class="it" id="it-${k}">${icon(k)}${esc(short(S.app[k].name))}<span class="s">menunggu</span></div>`).join('');
  $('#runClose').hidden = true; $('#runStop').hidden = false; $('#run').hidden = false;
  $('#runNote').textContent = 'Menyiapkan & memindai…' + (S.os === 'win' ? '' : ' Masukkan password di dialog kalau diminta.');
  const label = { ok: '✓ berhasil', skip: '= sudah ada', fail: '✗ gagal', info: 'ⓘ manual' };
  runCtx = e => {
    if (e.t === 'start') { const el = $(`#it-${e.key} .s`); if (el) { el.className = 's run'; el.textContent = 'memasang…'; } $('#runNote').textContent = `${e.n} dari ${e.total} · ${e.name}`; }
    if (e.t === 'done') { done++; const el = $(`#it-${e.key} .s`); if (el) { el.className = 's ' + e.status; el.textContent = (label[e.status] || e.status) + (e.secs ? ` · ${e.secs}s` : '') + (e.msg && e.status === 'fail' ? ` (${e.msg})` : ''); } $('#runBar').style.width = Math.round(100 * done / total) + '%'; if (e.status === 'ok' || e.status === 'skip') S.inst.add(e.key); }
    if (e.t === 'summary') { $('#runSum').innerHTML = `<b style="color:var(--ok)">${e.ok} berhasil</b> · ${e.fail ? `<b style="color:var(--err)">${e.fail} gagal</b>` : '0 gagal'}${e.info ? ` · ${e.info} manual` : ''}`; }
  };
  const code = await engine(['--install', ks.join(',')]);
  runCtx = null; $('#runStop').hidden = true; $('#runClose').hidden = false; $('#runBar').style.width = '100%';
  $('#runNote').textContent = code === 0 ? 'Selesai. Buka terminal baru supaya PATH baru terbaca.' : code === 3 ? 'Ada yang gagal. Coba menu Doctor, atau Laporkan masalah.' : `Mesin berhenti (kode ${code}). Lihat log di bawah.`;
  ks.forEach(k => { if (S.inst.has(k)) S.sel.delete(k); });
};
$('#runStop').onclick = async () => { if (await invoke('stop_engine')) toast('Proses dihentikan'); };
$('#runClose').onclick = () => { $('#run').hidden = true; renderApps(); };

/* ---------------- profil ---------------- */
function renderProfiles() {
  $('#profs').innerHTML = S.cat_data.profiles.map(p => { const ks = S.cat_data.apps.filter(a => a.profiles.includes(p.key) && a[S.os]).map(a => a.key);
    return `<button class="prof" data-p="${p.key}"><small>${p.key} · ${ks.length} aplikasi</small><b>${esc(p.name)}</b><p>${esc(p.desc || '')}</p><div class="lg">${ks.filter(k => S.icons[k]).slice(0, 9).map(k => `<img src="icons/${S.icons[k].slug}.svg" alt="">`).join('')}</div></button>`; }).join('');
  $$('.prof').forEach(b => b.onclick = () => {
    const ks = S.cat_data.apps.filter(a => a.profiles.includes(b.dataset.p) && a[S.os] && !S.inst.has(a.key)).map(a => a.key);
    ks.forEach(k => S.sel.add(k)); renderApps(); toast(`${ks.length} aplikasi dicentang dari profil ${b.dataset.p}`); $('#nav [data-view=apps]').click();
  });
}

/* ---------------- konfigurasi ---------------- */
$('#cfgSave').onclick = async () => {
  if (!S.sel.size) return toast('Pilih aplikasi dulu di menu Pasang aplikasi');
  const cfg = JSON.stringify({ tipack: 1, name: 'Konfigurasi TIPACK', created: new Date().toISOString().slice(0, 10), apps: [...S.sel] }, null, 2);
  try { const p = await invoke('save_config', { content: cfg }); if (p) { $('#cfgInfo').textContent = 'Disimpan ke ' + p; $('#cfgPreview').textContent = cfg; } } catch (e) { toast(String(e)); }
};
$('#cfgOpen').onclick = async () => {
  try {
    const r = await invoke('open_config'); if (!r) return;
    const [path, text] = r; const cfg = JSON.parse(text);
    const keys = new Set(cfg.apps || []);
    (cfg.profiles || []).forEach(pk => S.cat_data.apps.filter(a => a.profiles.includes(pk)).forEach(a => keys.add(a.key)));
    let n = 0; keys.forEach(k => { if (S.app[k] && S.app[k][S.os] && !S.inst.has(k)) { S.sel.add(k); n++; } });
    $('#cfgInfo').textContent = `${path}: "${cfg.name || 'tanpa nama'}", ${keys.size} aplikasi (${n} belum terpasang dan sudah dicentang).`;
    $('#cfgPreview').textContent = JSON.stringify(cfg, null, 2); renderApps();
  } catch (e) { toast('File tidak valid: ' + e); }
};

/* ---------------- doctor ---------------- */
$('#docRun').onclick = async () => {
  S.findings = []; $('#docList').innerHTML = '<p class="muted">Memeriksa… (bisa 10-30 detik)</p>'; $('#docAct').hidden = true; $('#docRun').disabled = true;
  await engine(['--doctor']); $('#docRun').disabled = false;
  if (!S.findings.length) { $('#docList').innerHTML = '<div class="finding"><b style="color:var(--ok)">✓ Tidak ada masalah yang terdeteksi. Siap dipakai.</b></div>'; return; }
  $('#docList').innerHTML = S.findings.map(f => { const manual = /^Manual:/.test(f.fix);
    return `<label class="finding"><input type="checkbox" value="${esc(f.id)}" ${f.sev !== 'rendah' && !manual ? 'checked' : ''} ${manual ? 'disabled' : ''}><div><b>${esc(f.title)}</b><p>${esc(f.detail)}</p><small>${manual ? '' : 'Perbaikan: '}${esc(f.fix)}</small></div><span class="sev ${f.sev}">${f.sev}</span></label>`; }).join('');
  $('#docAct').hidden = false;
};
$('#docFix').onclick = async () => {
  const ids = $$('#docList input:checked').map(i => i.value); if (!ids.length) return toast('Centang minimal satu temuan');
  $('#docFix').disabled = true; const res = {};
  runCtx = e => { if (e.t === 'fixed') res[e.id] = e.ok; };
  await engine(['--doctor-fix', ids.join(',')]); runCtx = null; $('#docFix').disabled = false;
  ids.forEach(id => { const el = $(`#docList input[value="${id}"]`); if (el) el.closest('.finding').querySelector('small').innerHTML = res[id] ? '<b style="color:var(--ok)">✓ diperbaiki</b>' : '<b style="color:var(--err)">✗ belum bisa diperbaiki otomatis</b>'; });
  toast('Selesai. Jalankan Periksa sekarang lagi untuk memastikan.');
};

/* ---------------- laporan ---------------- */
$('#repRun').onclick = async () => { $('#repOut').innerHTML = '<p class="muted">Membuat laporan…</p>'; await engine(['--report']); };
function showReport(e) {
  $('#repOut').innerHTML = `<p>Laporan disimpan (sudah disensor):</p><pre class="code">${esc(e.file)}</pre><p class="muted">Form issue berisi info sistem dan 40 baris log terakhir. Untuk log lengkap, seret file di atas ke kotak komentar issue.</p><div class="row"><button class="btn pri" id="repOpen">Buka form GitHub Issue</button></div>`;
  $('#repOpen').onclick = () => openUrl(e.url);
}

/* ---------------- tune-up ---------------- */
function tuneCmd() { return S.os === 'win' ? 'irm https://tipack.kousozo.tech/install.ps1 | iex' : 'curl -fsSL https://tipack.kousozo.tech/install.sh | bash'; }
$('#tuneCopy').onclick = async () => { try { await navigator.clipboard.writeText(tuneCmd()); toast('Perintah disalin'); } catch { toast('Salin manual dari kotak di atas'); } };

/* ---------------- mulai ---------------- */
(async () => {
  try { const p = await invoke('platform'); S.os = p.os; $('#ver').textContent = 'v' + p.version + ' · ' + p.arch; } catch { S.os = /Mac/.test(navigator.platform) ? 'mac' : /Win/.test(navigator.platform) ? 'win' : 'linux'; }
  $('#tuneCmd').textContent = tuneCmd();
  try {
    const [c, i] = await Promise.all([fetch('data/catalog.json').then(r => r.json()), fetch('icons/icons.json').then(r => r.json()).catch(() => ({}))]);
    S.cat_data = c; S.icons = i; c.apps.forEach(a => S.app[a.key] = a);
    renderApps(); renderProfiles();
  } catch (e) { $('#grid').innerHTML = `<p class="muted">Katalog gagal dimuat: ${esc(e)}</p>`; }
  if (T) engine(['--scan-json']); else { $('#sys').innerHTML = '<span class="dot"></span><span>Mode pratinjau (tanpa Tauri)</span>'; }
})();
