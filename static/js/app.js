const audio = document.getElementById('audioPlayer');
const playPauseBtn = document.getElementById('playPauseBtn');
const seekBar = document.getElementById('seekBar');
const volumeBar = document.getElementById('volumeBar');
const curTime = document.getElementById('curTime');
const durTime = document.getElementById('durTime');
const nowTitle = document.getElementById('nowTitle');
const nowArtist = document.getElementById('nowArtist');
const nowCover = document.getElementById('nowCover');
const playerBar = document.getElementById('playerBar');

let currentSong = null;
let currentUser = null;

// =========================================================
// HELPERS
// =========================================================
function fmtTime(sec) {
  sec = Math.floor(sec || 0);
  const m = Math.floor(sec / 60);
  const s = sec % 60;
  return `${m}:${s.toString().padStart(2, '0')}`;
}

function songRow(song, opts = {}) {
  const div = document.createElement('div');
  div.className = 'song-row';
  div.innerHTML = `
    <img src="${song.cover_url || 'https://picsum.photos/seed/default/100'}">
    <div>
      <div class="song-title">${song.title}</div>
      <div class="song-artist">${song.artist_name}</div>
    </div>
    <div class="song-plays">${song.play_count} plays</div>
    ${opts.showRemove
      ? `<button class="removeBtn" title="Remove from playlist">✕</button>`
      : `<button class="addBtn" title="Add to playlist">+</button>`}
  `;
  div.addEventListener('click', (e) => {
    if (e.target.closest('.addBtn') || e.target.closest('.removeBtn')) return;
    playSong(song);
  });

  if (opts.showRemove) {
    div.querySelector('.removeBtn').addEventListener('click', async (e) => {
      e.stopPropagation();
      await fetch(`/api/playlists/${opts.playlistId}/songs/${song.song_id}`, { method: 'DELETE', credentials: 'same-origin' });
      openPlaylist(opts.playlistId, opts.playlistName);
      loadPlaylists();
    });
  } else {
    div.querySelector('.addBtn').addEventListener('click', (e) => {
      e.stopPropagation();
      openAddToPlaylistMenu(song.song_id, e.currentTarget);
    });
  }
  return div;
}

function renderList(container, songs, opts = {}) {
  container.innerHTML = '';
  songs.forEach(s => container.appendChild(songRow(s, opts)));
}

// =========================================================
// PLAYBACK
// =========================================================
function playSong(song) {
  currentSong = song;
  audio.src = `/audio/${song.file_url.split('/').pop()}`;
  audio.play();
  playPauseBtn.textContent = '⏸';
  nowTitle.textContent = song.title;
  nowArtist.textContent = song.artist_name;
  nowCover.src = song.cover_url || '';

  fetch(`/api/play/${song.song_id}`, { method: 'POST', credentials: 'same-origin' });
  loadRecommendations(song.song_id);
}

playPauseBtn.addEventListener('click', () => {
  if (!currentSong) return;
  if (audio.paused) {
    audio.play();
    playPauseBtn.textContent = '⏸';
  } else {
    audio.pause();
    playPauseBtn.textContent = '▶';
  }
});

audio.addEventListener('timeupdate', () => {
  if (audio.duration) {
    seekBar.value = (audio.currentTime / audio.duration) * 100;
    curTime.textContent = fmtTime(audio.currentTime);
    durTime.textContent = fmtTime(audio.duration);
  }
});

seekBar.addEventListener('input', () => {
  if (audio.duration) audio.currentTime = (seekBar.value / 100) * audio.duration;
});

volumeBar.addEventListener('input', () => { audio.volume = volumeBar.value / 100; });
audio.volume = volumeBar.value / 100;

// =========================================================
// DATA LOADING - HOME
// =========================================================
async function loadAllSongs() {
  const res = await fetch('/api/songs', { credentials: 'same-origin' });
  const songs = await res.json();
  renderList(document.getElementById('songList'), songs);
}

async function loadRecommendations(songId) {
  const res = await fetch(`/api/songs/${songId}/recommendations`, { credentials: 'same-origin' });
  const songs = await res.json();
  renderList(document.getElementById('recList'), songs);
}

document.getElementById('searchBox').addEventListener('input', async (e) => {
  const q = e.target.value.trim();
  const container = document.getElementById('searchResults');
  if (!q) { container.innerHTML = ''; return; }
  const res = await fetch(`/api/search?q=${encodeURIComponent(q)}`, { credentials: 'same-origin' });
  const songs = await res.json();
  renderList(container, songs);
});

// =========================================================
// NAV / VIEW SWITCHING
// =========================================================
function switchView(viewName) {
  document.querySelectorAll('.view').forEach(v => v.classList.add('hidden'));
  document.getElementById(`view-${viewName}`).classList.remove('hidden');
  document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
  document.querySelector(`.nav-item[data-view="${viewName}"]`).classList.add('active');

  if (viewName === 'genres') loadGenreGrid();
  if (viewName === 'albums') loadAlbumGrid();
}

document.querySelectorAll('.nav-item').forEach(item => {
  item.addEventListener('click', () => switchView(item.dataset.view));
});

// =========================================================
// GENRES
// =========================================================
async function loadGenreGrid() {
  document.getElementById('genreDetail').classList.add('hidden');
  document.getElementById('genreGridWrap').classList.remove('hidden');
  const res = await fetch('/api/genres', { credentials: 'same-origin' });
  const genres = await res.json();
  const grid = document.getElementById('genreGrid');
  grid.innerHTML = '';
  genres.forEach(g => {
    const tile = document.createElement('div');
    tile.className = 'tile genre-tile';
    tile.textContent = g.genre_name;
    tile.addEventListener('click', () => openGenre(g.genre_id, g.genre_name));
    grid.appendChild(tile);
  });
}

async function openGenre(genreId, genreName) {
  document.getElementById('genreGridWrap').classList.add('hidden');
  const detail = document.getElementById('genreDetail');
  detail.classList.remove('hidden');
  document.getElementById('genreDetailTitle').textContent = genreName;
  const res = await fetch(`/api/genres/${genreId}/songs`, { credentials: 'same-origin' });
  const songs = await res.json();
  renderList(document.getElementById('genreSongs'), songs);
}

document.getElementById('backFromGenre').addEventListener('click', loadGenreGrid);

// =========================================================
// ALBUMS
// =========================================================
async function loadAlbumGrid() {
  document.getElementById('albumDetail').classList.add('hidden');
  document.getElementById('albumGridWrap').classList.remove('hidden');
  const res = await fetch('/api/albums', { credentials: 'same-origin' });
  const albums = await res.json();
  const grid = document.getElementById('albumGrid');
  grid.innerHTML = '';
  albums.forEach(al => {
    const tile = document.createElement('div');
    tile.className = 'tile';
    tile.innerHTML = `
      <img src="${al.cover_url || 'https://picsum.photos/seed/default/300'}">
      <div class="tile-title">${al.album_title}</div>
      <div class="tile-sub">${al.artist_name} · ${al.release_year || ''}</div>
    `;
    tile.addEventListener('click', () => openAlbum(al.album_id, al.album_title, al.artist_name));
    grid.appendChild(tile);
  });
}

async function openAlbum(albumId, albumTitle, artistName) {
  document.getElementById('albumGridWrap').classList.add('hidden');
  const detail = document.getElementById('albumDetail');
  detail.classList.remove('hidden');
  document.getElementById('albumDetailTitle').textContent = albumTitle;
  document.getElementById('albumDetailArtist').textContent = artistName;

  const res = await fetch(`/api/albums/${albumId}/songs`, { credentials: 'same-origin' });
  const songs = await res.json();

  // group songs by artist (classification requirement)
  const groups = {};
  songs.forEach(s => {
    if (!groups[s.artist_name]) groups[s.artist_name] = [];
    groups[s.artist_name].push(s);
  });

  const container = document.getElementById('albumSongs');
  container.innerHTML = '';
  Object.keys(groups).forEach(artist => {
    const header = document.createElement('div');
    header.className = 'artist-group-title';
    header.textContent = artist;
    container.appendChild(header);
    const listDiv = document.createElement('div');
    listDiv.className = 'song-list';
    groups[artist].forEach(s => listDiv.appendChild(songRow(s)));
    container.appendChild(listDiv);
  });
}

document.getElementById('backFromAlbum').addEventListener('click', loadAlbumGrid);

// =========================================================
// AUTH  (full-screen gate — app is inaccessible until logged in)
// =========================================================
let authMode = 'login';

function setAuthGateMode(mode) {
  authMode = mode;
  document.getElementById('authError').classList.add('hidden');
  document.getElementById('authUsername').value = '';
  document.getElementById('authEmail').value = '';
  document.getElementById('authPassword').value = '';
  if (mode === 'login') {
    document.getElementById('authGateTitle').textContent = 'Log in to continue';
    document.getElementById('authEmail').classList.add('hidden');
    document.getElementById('authSubmitBtn').textContent = 'Log in';
    document.getElementById('authSwitchText').textContent = "Don't have an account?";
    document.getElementById('authSwitchLink').textContent = 'Sign up';
  } else {
    document.getElementById('authGateTitle').textContent = 'Create your account';
    document.getElementById('authEmail').classList.remove('hidden');
    document.getElementById('authSubmitBtn').textContent = 'Sign up';
    document.getElementById('authSwitchText').textContent = 'Already have an account?';
    document.getElementById('authSwitchLink').textContent = 'Log in';
  }
}

document.getElementById('authSwitchLink').addEventListener('click', (e) => {
  e.preventDefault();
  setAuthGateMode(authMode === 'login' ? 'register' : 'login');
});

document.getElementById('authSubmitBtn').addEventListener('click', async () => {
  const username = document.getElementById('authUsername').value.trim();
  const password = document.getElementById('authPassword').value;
  const email = document.getElementById('authEmail').value.trim();
  const errEl = document.getElementById('authError');
  errEl.classList.add('hidden');

  const url = authMode === 'login' ? '/api/auth/login' : '/api/auth/register';
  const body = authMode === 'login' ? { username, password } : { username, email, password };

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'same-origin',
    body: JSON.stringify(body),
  });
  const data = await res.json();
  if (!res.ok) {
    errEl.textContent = data.error || 'Something went wrong';
    errEl.classList.remove('hidden');
    return;
  }
  currentUser = { user_id: data.user_id, username: data.username };
  enterApp();
});

function enterApp() {
  document.getElementById('authGate').classList.add('hidden');
  document.getElementById('appRoot').classList.remove('hidden');
  playerBar.classList.remove('hidden');

  document.getElementById('userAvatar').textContent = currentUser.username[0].toUpperCase();
  document.getElementById('userMenuName').textContent = currentUser.username;

  loadAllSongs();
  loadPlaylists();
}

// user menu dropdown (logout lives here)
document.getElementById('userMenuTrigger').addEventListener('click', () => {
  document.getElementById('userMenuDropdown').classList.toggle('hidden');
});
document.addEventListener('click', (e) => {
  if (!e.target.closest('#userMenu')) {
    document.getElementById('userMenuDropdown').classList.add('hidden');
  }
});
document.getElementById('logoutBtn').addEventListener('click', async () => {
  await fetch('/api/auth/logout', { method: 'POST', credentials: 'same-origin' });
  currentUser = null;
  currentSong = null;
  audio.pause();
  audio.src = '';
  document.getElementById('appRoot').classList.add('hidden');
  playerBar.classList.add('hidden');
  document.getElementById('authGate').classList.remove('hidden');
  setAuthGateMode('login');
});

async function checkSession() {
  const res = await fetch('/api/auth/me', { credentials: 'same-origin' });
  const data = await res.json();
  if (data.logged_in) {
    currentUser = { user_id: data.user_id, username: data.username };
    enterApp();
  } else {
    setAuthGateMode('login');
  }
}

checkSession();

// =========================================================
// PLAYLISTS
// =========================================================
async function loadPlaylists() {
  const res = await fetch('/api/playlists', { credentials: 'same-origin' });
  if (!res.ok) return;
  const playlists = await res.json();
  const container = document.getElementById('playlistList');
  container.innerHTML = '';
  playlists.forEach(p => {
    const row = document.createElement('div');
    row.className = 'playlist-row';
    row.innerHTML = `
      <span>${p.playlist_name}</span>
      <span class="pcount">${p.song_count}</span>
      <button class="delBtn" title="Delete playlist">🗑</button>
    `;
    row.addEventListener('click', (e) => {
      if (e.target.closest('.delBtn')) return;
      openPlaylist(p.playlist_id, p.playlist_name);
    });
    row.querySelector('.delBtn').addEventListener('click', async (e) => {
      e.stopPropagation();
      if (!confirm(`Delete playlist "${p.playlist_name}"?`)) return;
      await fetch(`/api/playlists/${p.playlist_id}`, { method: 'DELETE', credentials: 'same-origin' });
      loadPlaylists();
      document.getElementById('playlistView').classList.add('hidden');
    });
    container.appendChild(row);
  });
  return playlists;
}

document.getElementById('newPlaylistBtn').addEventListener('click', () => createPlaylistFlow());

async function createPlaylistFlow() {
  const name = prompt('Name your new playlist:');
  if (!name || !name.trim()) return null;
  const res = await fetch('/api/playlists', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'same-origin',
    body: JSON.stringify({ playlist_name: name.trim() }),
  });
  const data = await res.json();
  await loadPlaylists();
  return data;
}

async function openPlaylist(playlistId, playlistName) {
  switchView('home');
  const res = await fetch(`/api/playlists/${playlistId}/songs`, { credentials: 'same-origin' });
  const songs = await res.json();
  const view = document.getElementById('playlistView');
  view.classList.remove('hidden');
  document.getElementById('playlistViewTitle').textContent = playlistName;
  renderList(document.getElementById('playlistViewSongs'), songs, {
    showRemove: true,
    playlistId,
    playlistName,
  });
  view.scrollIntoView({ behavior: 'smooth' });
}

document.getElementById('closePlaylistViewBtn').addEventListener('click', () => {
  document.getElementById('playlistView').classList.add('hidden');
});

// ---------- Add-to-playlist: real dropdown menu near the + button ----------
const atpMenu = document.getElementById('addToPlaylistMenu');

async function openAddToPlaylistMenu(songId, anchorEl) {
  const res = await fetch('/api/playlists', { credentials: 'same-origin' });
  const playlists = res.ok ? await res.json() : [];

  atpMenu.innerHTML = '';
  if (playlists.length === 0) {
    const empty = document.createElement('div');
    empty.className = 'atp-empty';
    empty.textContent = 'No playlists yet';
    atpMenu.appendChild(empty);
  } else {
    playlists.forEach(p => {
      const item = document.createElement('div');
      item.className = 'atp-item';
      item.innerHTML = `<span>${p.playlist_name}</span><span class="dim">${p.song_count}</span>`;
      item.addEventListener('click', async () => {
        const result = await fetch(`/api/playlists/${p.playlist_id}/songs`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          credentials: 'same-origin',
          body: JSON.stringify({ song_id: songId }),
        });
        closeAddToPlaylistMenu();
        if (result.status === 409) {
          alert('That song is already in this playlist.');
        } else {
          loadPlaylists();
        }
      });
      atpMenu.appendChild(item);
    });
  }

  const createItem = document.createElement('div');
  createItem.className = 'atp-item create-new';
  createItem.textContent = '+ Create new playlist';
  createItem.addEventListener('click', async () => {
    closeAddToPlaylistMenu();
    const newPl = await createPlaylistFlow();
    if (newPl && newPl.playlist_id) {
      await fetch(`/api/playlists/${newPl.playlist_id}/songs`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify({ song_id: songId }),
      });
      loadPlaylists();
    }
  });
  atpMenu.appendChild(createItem);

  const rect = anchorEl.getBoundingClientRect();
  atpMenu.style.top = `${rect.bottom + 4}px`;
  atpMenu.style.left = `${Math.max(8, rect.left - 150)}px`;
  atpMenu.classList.remove('hidden');
}

function closeAddToPlaylistMenu() {
  atpMenu.classList.add('hidden');
}

document.addEventListener('click', (e) => {
  if (!e.target.closest('#addToPlaylistMenu') && !e.target.closest('.addBtn')) {
    closeAddToPlaylistMenu();
  }
});
