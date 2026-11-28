# No Signal, Connect!

**No Signal, Connect!** adalah game *2D pixel art puzzle-platformer side-scroller* dengan **mode bergantian layar penuh** (*dual-world alternating screen*) yang mengisahkan kerja sama dua kakak-beradik yang terpisah dan saling bergantung untuk pulang bersama.

---


https://github.com/user-attachments/assets/11be990d-d462-4740-a447-e5d4835708c6


---

## Konsep & Mekanik Utama

Permainan dijalankan melalui dua dunia terpisah yang dimainkan **secara bergantian dalam layar penuh** dalam setiap stage:

* **Fase 1 — Allen (Permukaan / *Network Engineer*):**
  Menjelajahi area kota dan jalan raya, melewati rintangan serta jebakan, memecahkan *mini-puzzle* jaringan (urutan kabel, *color memory*), dan menyalakan **Menara Sinyal**. Setelah menara menyala, kontrol otomatis berpindah ke Luna.
* **Fase 2 — Luna (*Underground* / *Programmer*):**
  Bertahan hidup di area pembuangan limbah dan robot (*Robot Rusak*, *Drone*). Dengan sinyal menara yang sudah aktif, Luna dapat membuka layar laptopnya untuk mengetik *command* dan menembakkan **kilatan petir** ke arah musuh hingga mencapai pintu keluar stage.
* **Aturan Progres:**
  Kedua karakter berbagi kondisi kritis—jika HP salah satu karakter habis, permainan langsung berakhir (*Game Over*). Area yang telah dilewati tidak dapat diulang kembali (*no backtracking*).

---

## Kontrol Permainan (Default)

| Aksi | Tombol Keyboard | Keterangan |
| :--- | :--- | :--- |
| **Gerak Kiri / Kanan** | `A` / `D` atau `←` / `→` | Menggerakkan karakter pada layar yang sedang aktif |
| **Lompat / Double Jump** | `Space` / `W` | Maksimal 2 kali lompatan berturut-turut |
| **Sprint** | `Shift` (Tahan) | Meningkatkan kecepatan lari dengan mengonsumsi *Energy Bar* |
| **Interaksi / Buka Laptop** | `E` | Membuka panel puzzle menara (Allen) atau terminal laptop (Luna) |
| **Eksekusi Command** | `Enter` | Mengirim ketikan *command* serangan di terminal laptop Luna |

---

## Spesifikasi Teknis & Cara Menjalankan

* **Game Engine:** Godot Engine **4.7**
* **Target Platform:** Desktop (Windows & Linux)
* **Arsitektur Layar:** *Dual SubViewport* (`TopViewport` & `BottomViewport`) yang tampil **bergantian secara layar penuh** melalui [`main.gd`](main.gd), dengan komunikasi sinyal global melalui Autoload [`GameBridge`](autoload/game_bridge.gd) dan manajemen menu/transisi/audio melalui Autoload [`Game`](autoload/game.gd).

### Langkah Instalasi Lokal
1. *Clone* repositori ini ke komputer lokal:
   ```bash
   git clone <url-repositori-tim>
   cd no-signal-connect

```

2. Buka **Godot Engine 4.7**.
3. Klik **Import**, arahkan ke file `project.godot` di dalam folder proyek, lalu klik **Import & Edit**.
4. Tekan **`F5`** (atau klik ikon **Run Project** di pojok kanan atas) untuk menjalankan game dari `main.tscn`.

---

## Struktur Direktori Proyek

```text
no-signal-connect/
├── assets/                     # Aset visual (Character, Efek, Maps, UI), font, & audio
├── autoload/
│   ├── game.gd                 # Singleton menu, tema retro, CRT, transisi scene, BGM/SFX, & settings
│   └── game_bridge.gd          # Singleton gameplay (status sinyal, HP/energi, stage, & win/lose)
├── components/                 # Modul logika reusable (Composition pattern)
│   ├── energy_component.gd     # Konsumsi sprint & regenerasi energi otomatis
│   ├── footsteps.gd            # Sinkronisasi SFX langkah dengan frame animasi
│   ├── health_component.gd     # Manajemen HP, damage, heal, & sinyal kematian
│   ├── hitbox_component.gd     # Area2D pemberi damage (petir, musuh, jebakan)
│   └── hurtbox_component.gd    # Area2D penerima damage
├── docs/                       # Dokumentasi teknis & panduan aset tim
│   ├── ASSET_GUIDELINES.md
│   ├── Game Design Document.md
│   └── TECH_SPEC.md
├── entities/
│   ├── enemies/
│   │   ├── broken_robot/       # Musuh patroli darat Stage 1 & Stage 2 (broken_robot_v2)
│   │   └── drone/              # Musuh patroli udara Stage 2
│   └── players/
│       ├── allen/              # Karakter A (Permukaan)
│       ├── base_player/        # Base scene & fisika dasar (gerak, double jump, sprint, buff)
│       └── luna/               # Karakter B (Underground + terminal combat)
├── levels/
│   ├── stage_01/               # surface_01.tscn & underground_01.tscn
│   └── stage_02/               # surface_02.tscn & underground_02.tscn
├── mechanics/
│   ├── cable_puzzle/           # Mini-puzzle urutan kabel Allen (Stage 1)
│   ├── color_memory_puzzle/    # Mini-puzzle Color Memory Allen (Stage 2)
│   ├── laptop_terminal/        # UI ketik command serangan Luna
│   ├── lightning_bolt/         # Proyektil serangan petir Luna
│   ├── one_way_gate/           # Gerbang satu arah (anti-backtracking)
│   ├── power_up/               # Item buff berdurasi (Heal, Energy, Shield, ATK x2)
│   ├── random_chest/           # Peti buff acak untuk Allen
│   ├── signal_tower/           # Menara pemancar sinyal utama
│   └── stage_exit/             # Titik finis underground tiap stage
├── packaging/                  # Konfigurasi installer Linux & Windows
├── scenes/                     # Scene menu, intro/outro cutscene, win_screen, settings, credits, feedback
├── scripts/                    # Skrip untuk intro, outro, screens, & komponen UI retro
├── shaders/                    # Shader CRT, pixel transition, & starfield
├── ui/
│   ├── dialog/                 # Sistem kotak dialog (DialogBox)
│   ├── screens/                # Overlay PauseMenu & GameOverScreen
│   └── hud_dual_screen.tscn    # HUD bar HP, bar energi, buff, stage, & status sinyal
├── main.gd                     # Controller pergantian layar & level lintas SubViewport
├── main.tscn                   # Root scene gameplay (TopViewport & BottomViewport)
├── project.godot               # Konfigurasi InputMap, Physics Layers, & Autoload
├── CONTRIBUTING.md             # Aturan Git, standar penamaan, & alur kerja kolaborasi
└── README.md                   # Dokumentasi utama proyek
```

---

## Dokumentasi Tim

* **[CONTRIBUTING.md](CONTRIBUTING.md)** — Standar *branching* Git, aturan penamaan file, dan pencegahan konflik `.tscn`.
* **[docs/TECH_SPEC.md](docs/TECH_SPEC.md)** — Peta sinyal `GameBridge`, tabel *Collision Layer & Mask*, dan cara merakit komponen.
* **[docs/ASSET_GUIDELINES.md](docs/ASSET_GUIDELINES.md)** — Spesifikasi ukuran piksel, format audio, dan aturan impor aset.
* **[docs/SUBMISSION_CHECKLIST.md](docs/SUBMISSION_CHECKLIST.md)** — Panduan lengkap submission & kurasi Gimersia Inspire 2026.

---

## Roadmap Pengembangan

* [x] Arsitektur *dual-viewport* bergantian layar penuh (`main.gd`), backdrop dunia, & cutscene Intro/Outro
* [x] Sistem pergerakan dasar (*double jump*, *sprint* berbasis energi) & *Health/Damage*
* [x] *Core gameplay loop* Stage 1 (Puzzle kabel, Menara Sinyal, *Typing Combat* petir, & Robot Rusak)
* [x] HUD status lintas layar & sistem transisi antar-stage
* [x] Implementasi Stage 2, Puzzle *Color Memory*, & musuh *Drone*
* [x] Sistem item *Buff / Power-Up* acak berdurasi (`RandomChest` & drop musuh) & *One-Way Gate*
* [x] Layar *Main Menu*, *Pause Menu*, *Game Over*, & *Win Screen*
* [x] Integrasi aset *2D pixel art*, SFX gameplay & dialog, serta konsistensi desain UI
* [x] *Final Playtest* & *export build* Windows, Linux & Web v1.0

---

## CI/CD & Release

Proyek ini menggunakan **GitHub Actions** untuk build otomatis:

| Workflow | Trigger | Output |
|----------|---------|--------|
| **CI Build Validation** (`ci.yml`) | Setiap push & PR | Validasi import Godot + scan broken `res://` refs |
| **Build & Release** (`release.yml`) | Push tag `v*` | Windows (portable + installer), Linux (.tar.gz + .deb + .rpm), Web (HTML5) |

Release otomatis dipublikasikan ke:
- **GitHub Releases** — semua artifact build
- **itch.io** — Windows, Linux, & HTML5 (playable in browser)

### Cara Release
```bash
git tag v1.0.0
git push origin v1.0.0
# CI akan otomatis build & publish ke GitHub Releases + itch.io
```
