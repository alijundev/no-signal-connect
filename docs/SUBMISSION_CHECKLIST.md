# 🏆 Checklist Submission — Gimersia Inspire 2026

> **Batas Akhir:** Minggu, 29 November 2026, pukul **23.59 WIB** (24.59 WITA)  
> **Penting:** Jangan mengubah build di halaman game jam setelah batas submission!

---

## 1. Isi Placeholder Identitas & Atribusi di Dalam Gim

Sebelum *export build* final, buka **`scenes/credits.tscn`** (di Godot atau teks editor) dan lengkapi:

- [ ] **Identitas Tim (`SectionTeam` & `BodyTeam`):**
  - Ganti `[NAMA TIM]`, `[TEAM ID]`, `[NAMA INSTITUSI]`
  - Ganti daftar `[NAMA ANGGOTA]` dan peran masing-masing
- [ ] **Atribusi Aset Pihak Ketiga (`BodyAssets`):**
  - **Wajib sesuai dengan daftar aset di Form Submission** (Rulebook Bag. III)
  - Cantumkan sumber & lisensi untuk:
    - VFX Sprites (`assets/Efek/lightning_burst_*`, `assets/Efek/scifi_warp_*`)
    - Tileset & Sprite (`assets/Maps/`, `assets/Character/`)
    - BGM & SFX (`assets/audio/`)
  - **⚠️ Catatan Khusus Audio Meme (`cat-laugh-meme-1.mp3`, `cihuy.mp3`):**
    - Diambil dari *MyInstants*. Pastikan aman dari klaim hak cipta (Rulebook Bag. V: *"Semua aset visual, audio, dan kode harus orisinal atau memiliki lisensi yang sah"*). Jika ragu, disarankan ganti dengan SFX bebas royalti (CC0/CC-BY) atau buat sendiri, lalu cantumkan sumbernya.
- [ ] **Pastikan Tidak Ada Aset AI:**
  - Rulebook Bag. III & XI melarang keras aset gambar, suara, atau musik hasil AI.

---

## 2. Verifikasi Gim (*Playtest* Sebelum Export)

Jalankan dari `MainMenu` (`F5`) dan pastikan seluruh alur berjalan tanpa error merah di Debugger:

- [ ] **Tutorial In-Game:** Panel tutorial kontrol muncul di awal Stage 1 (Allen) dan Stage 1 (Luna).
- [ ] **Core Gameplay Loop:**
  - `MainMenu` $\rightarrow$ `Intro` (bisa di-skip pakai `SKIP [ESC]`) $\rightarrow$ `Stage 1` (Allen)
  - Buka `RandomChest`, selesaikan `CablePuzzle` di `SignalTower` $\rightarrow$ transisi ke Luna
  - Buka laptop (`E`), ketik command + `Enter` $\rightarrow$ petir kena robot $\rightarrow$ masuk `StageExit`
  - `Stage 2` (Allen: `ColorMemoryPuzzle`, Luna: `Drone` & `BrokenRobotV2`) $\rightarrow$ `Outro` $\rightarrow$ `WinScreen`
- [ ] **Pause & Game Over:** Tekan `ESC` untuk Pause; uji HP habis $\rightarrow$ `GameOverScreen` $\rightarrow$ Retry / Main Menu.
- [ ] **Credits:** Buka menu `CREDITS` dari Main Menu, pastikan seluruh teks terbaca rapi dan tidak terpotong.

---

## 3. Rekam Video Gameplay (YouTube Unlisted)

*(Dipakai untuk **Kurasi 1: Game Hook** — skor 0–5)*

- [ ] **Durasi:** **60 detik hingga 2 menit** (maksimal 2 menit).
- [ ] **Isi Rekaman:**
  - Tampilkan **2 menit pertama** atau *core gameplay loop* secara utuh (Allen bergerak, tutorial, puzzle/menara sinyal, transisi ke Luna, mengetik command petir melawan musuh).
  - Utamakan rekaman layar yang jernih dengan audio terdengar jelas, tanpa editing yang rumit.
- [ ] **Upload ke YouTube:** Set visibilitas menjadi **Unlisted** (Tidak Publik) dan simpan link-nya.

---

## 4. Halaman itch.io (`https://itch.io/jam/gimersia-inspire-2026`)

- [ ] **Baris Pertama Deskripsi (WAJIB):**
  ```text
  Team ID <ID> · <Nama Tim> · <Nama Institusi>
  ```
  *(Tanpa format ini di baris pertama, panitia tidak bisa mencocokkan halaman dengan data pendaftaran)*
- [ ] **Build yang Diunggah:**
  - **WebGL (HTML5)** agar bisa dimainkan langsung di browser *(sangat direkomendasikan untuk kurator)*, **dan/atau**
  - **Windows Desktop** (`.zip` portable / installer `.exe`).
- [ ] **Kelengkapan Halaman:**
  - Deskripsi gim & tema yang dipilih (**Pulang** / *Gotong Royong*)
  - Cara bermain & daftar kontrol (`A/D` gerak, `Space/W` double jump, `Shift` sprint, `E` interaksi/laptop, `Enter` kirim command)
  - Minimal **3 tangkapan layar (screenshot / GIF)** terbaru
  - Link video gameplay YouTube
- [ ] **Submit ke Game Jam:** Pastikan halaman sudah disubmit melalui tombol **"Submit your project"** di `https://itch.io/jam/gimersia-inspire-2026`.
- [ ] **Tes Buka Publik:** Buka halaman itch.io di mode *Incognito* dan pastikan gim bisa dimainkan dari awal sampai akhir.

---

## 5. Form Submission (`https://forms.gle/MZU3V2eJGJP7DygE9`)

Diisi **1 kali** oleh ketua tim sebelum **29 November 2026, 23.59 WIB**:

- [ ] Team ID, Nama Tim, Asal Institusi, Kategori (PT/SMK), dan Nama Gim (`No Signal, Connect!`)
- [ ] **Tema Pilihan:** **Pulang**
  - *Contoh penjelasan:* "Tema **Pulang** terasa langsung di cerita dan mekanik: dua kakak-beradik (Allen & Luna) terpisah saat perjalanan pulang. Pemain mengendalikan Allen menyalakan menara sinyal di permukaan agar Luna bisa bertahan dan keluar dari underground sehingga keduanya dapat pulang bersama."
- [ ] Link halaman itch.io & link YouTube Unlisted
- [ ] **Daftar Aset Pihak Ketiga & Sumbernya** *(harus sama dengan yang tertulis di `scenes/credits.tscn`)*
- [ ] Data **2 perwakilan tim** (anggota/pembimbing) untuk Final di Bandung (4–6 Desember 2026)

---

## 6. Release via GitHub Actions (Opsional / Otomatis)

Jika ingin otomatis build & upload via GitHub Actions (`release.yml`):
1. Pastikan secret **`BUTLER_API_KEY`** sudah diset di GitHub Repo Settings → Secrets.
2. Pastikan variable **`ITCH_GAME`** sudah sesuai slug halaman itch.io kamu (default: `alijundev/no-signal-connect`).
3. Merge ke `main` dan push tag (contoh: `git tag v1.0.0 && git push origin v1.0.0`).
4. **Ingat:** Jangan push tag/build baru ke halaman jam setelah **29 Nov 2026, 23.59 WIB**.
