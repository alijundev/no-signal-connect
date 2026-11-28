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
│   │   ├── broken_robot/       # Musuh patroli darat Stage 1
│   │   └── drone/              # Musuh Stage 2
│   └── players/
│       ├── allen/              # Karakter A (Permukaan)
│       ├── base_player/        # Base scene & fisika dasar (gerak, double jump, sprint)
│       └── luna/               # Karakter B (Underground + terminal combat)
├── levels/
│   ├── stage_01/               # surface_01.tscn & underground_01.tscn
│   └── stage_02/               # surface_02.tscn & underground_02.tscn
├── mechanics/
│   ├── cable_puzzle/           # Mini-puzzle urutan kabel Allen (Stage 1)
│   ├── laptop_terminal/        # UI ketik command serangan Luna
│   ├── lightning_bolt/         # Proyektil serangan petir Luna
│   ├── signal_tower/           # Menara pemancar sinyal utama
│   └── stage_exit/             # Titik finis underground tiap stage
├── packaging/                  # Konfigurasi installer Linux & Windows
├── scenes/                     # Scene layar menu, intro cutscene, settings, credits, feedback
├── scripts/                    # Skrip untuk intro, screens, & komponen UI retro
├── shaders/                    # Shader CRT, pixel transition, & starfield
├── ui/
│   ├── dialog/                 # Sistem kotak dialog (DialogBox)
│   └── hud_dual_screen.tscn    # HUD bar HP, bar energi, & status sinyal
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
* **[docs/ASSET_GUIDELINES.md](https://www.google.com/search?q=docs/ASSET_GUIDELINES.md)** — Spesifikasi ukuran piksel, format audio, dan aturan impor aset.

---

## Roadmap Pengembangan

* [x] Arsitektur *dual-viewport* bergantian layar penuh (`main.gd`) & cutscene intro
* [x] Sistem pergerakan dasar (*double jump*, *sprint* berbasis energi) & *Health/Damage*
* [x] *Core gameplay loop* Stage 1 (Puzzle kabel, Menara Sinyal, *Typing Combat* petir, & Robot Rusak) — *perlu penyempurnaan & bugfix*
* [x] HUD status lintas layar & sistem transisi antar-stage
* [ ] Implementasi Stage 2, Puzzle *Color Memory*, & musuh *Drone*
* [ ] Sistem item *Buff / Power-Up* acak berdurasi & *One-Way Gate*
* [ ] Layar *Main Menu* (selesai), *Game Over*, *Win Screen*, serta *Pause Menu*
* [ ] Integrasi penuh aset *2D pixel art* & SFX gameplay, serta *export build* Windows & Linux
