# Panduan Standar Aset (Art & Audio) — No Signal, Connect!

Dokumen ini menjadi acuan teknis bagi tim *Art*, *UI/UX*, dan *Audio* dalam memproduksi serta memasukkan aset ke proyek **Godot Engine 4.7**.

---

## 1. Struktur Direktori `res://assets/`

Seluruh aset mentah wajib dikelompokkan ke dalam subfolder berikut menggunakan penamaan **`snake_case`** (huruf kecil, tanpa spasi, dipisah garis bawah):

```text
assets/
├── audio/
│   ├── bgm/            # Musik latar looping (.ogg)
│   └── sfx/            # Efek suara aksi & UI (.wav)
├── fonts/              # File font pixel art (.ttf / .otf)
├── sprites/
│   ├── enemies/        # Spritesheet BrokenRobot & Drone (.png)
│   ├── mechanics/      # Menara sinyal, gerbang, petir, jebakan, buff (.png)
│   └── players/        # Spritesheet Allen & Luna (.png)
├── tilesets/
│   ├── surface/        # Tileset & background dunia atas (Allen)
│   └── underground/    # Tileset & background dunia bawah (Luna)
└── ui/                 # Ikon HUD, bingkai terminal laptop, panel puzzle (.png)

```

---

## 2. Standar Visual & Ukuran Piksel

Game menggunakan skala grid dasar **`32 x 32` piksel** (1 *tile* = `32x32` px) tanpa *scaling* pecahan agar tampilan piksel tetap tajam di layar split-screen.

### Tabel Dimensi Aset Utama

| Kategori | Nama Aset | Ukuran Frame (px) | Keterangan Visual & State Animasi |
| --- | --- | --- | --- |
| **Player** | `allen_sheet.png` | `32 x 48` | *Idle*, *Run*, *Jump*, *Fall*, *Hurt*, *Interact* (menghadap **kanan**). |
| **Player** | `luna_sheet.png` | `32 x 48` | *Idle*, *Run*, *Jump*, *Fall*, *Hurt*, *Typing Laptop* (menghadap **kanan**). |
| **Enemy** | `broken_robot_sheet.png` | `32 x 48` | *Patrol/Walk*, *Hurt*, *Destroyed* (menghadap **kanan**). |
| **Enemy** | `drone_sheet.png` | `32 x 32` | *Hover/Fly*, *Attack*, *Destroyed* (Stage 2). |
| **Mechanic** | `signal_tower.png` | `48 x 96` | 2 *frame*: Frame 0 = Mati (redup), Frame 1 = Menyala (aktif/bercahaya). |
| **Mechanic** | `lightning_bolt.png` | `32 x 16` | Proyektil petir horizontal (2–3 *frame* animasi kilatan, arah ke **kanan**). |
| **Mechanic** | `one_way_gate.png` | `32 x 160` | Penghalang vertikal (2 *frame*: terbuka/nonaktif & tertutup/terkunci). |
| **Mechanic** | `stage_exit.png` | `48 x 96` | Pintu keluar *underground* (2 *frame*: terkunci & terbuka). |
| **Hazard** | `trap_spikes.png` | `32 x 32` | Jebakan lantai/listrik *underground* dan rintangan permukaan. |
| **Item** | `buff_icons.png` | `24 x 24` | Ikon item *buff* pemulih HP, pengisi energi, & penguat serangan. |
| **Tileset** | `surface_tiles.png` | `32 x 32` / tile | Lantai aspal, trotoar, platform gedung, & pagar pembatas. |
| **Tileset** | `underground_tiles.png` | `32 x 32` / tile | Lantai beton retak, pipa limbah, platform besi, & dinding terowongan. |

### Kontras Warna Antar-Dunia (*Readability*)

Karena pemain berpindah bergantian antara dua dunia dalam layar penuh:

* **Dunia Atas (Surface / Allen):** Gunakan palet warna terang atau kontras langit siang/sore (biru, abu-abu terang, aksen cyan untuk sinyal aktif).
* **Dunia Bawah (Underground / Luna):** Gunakan palet warna gelap dan hangat (abu-abu tua, cokelat karat, lumut, dengan aksen kuning elektrik/oranye agar karakter Luna dan proyektil petir mudah terlihat).

---

## 3. Aturan Format *Spritesheet*

1. **Format File:** `.png` (32-bit RGBA dengan latar belakang transparan penuh).
2. **Arah Hadap Default:** Semua karakter, musuh, dan proyektil wajib digambar **menghadap ke kanan**. Pembalikan arah ke kiri diatur otomatis lewat kode (`flip_h = true`).
3. **Grid Seragam Tanpa Margin:** Susun *frame* animasi secara horizontal dalam satu baris atau grid yang ukurannya konsisten (contoh: 4 *frame* jalan berukuran `32x48` disusun menjadi gambar `128x48` px tanpa jarak spasi/padding antar-frame) agar mudah dipotong menggunakan properti `Hframes` dan `Vframes` pada node `Sprite2D` / `AnimatedSprite2D`.
4. **Titik Pijak (*Pivot*):** Pastikan kaki karakter dan musuh menyentuh tepi paling bawah frame (`y = 48`) agar karakter tidak terlihat melayang di atas lantai.

---

## 4. Konfigurasi Impor Godot 4.7

Agar gambar *pixel art* tidak menjadi buram (*blur*) akibat filter bilinear bawaan engine:

1. Pada **Project Settings $\rightarrow$ Rendering $\rightarrow$ Textures $\rightarrow$ Canvas Textures**, pastikan **Default Texture Filter** diatur ke **`Nearest`**.
2. Pada tab **Import** untuk setiap aset gambar baru:
* Pastikan **Compress $\rightarrow$ Mode** menggunakan **`Lossless`**.
* Klik **Reimport** setiap kali mengubah pengaturan.


3. Wajib menyertakan file `.png.import` saat melakukan `git commit`.

---

## 5. Standar Audio (BGM & SFX)

| Jenis Audio | Format File | Spesifikasi Teknis | Daftar Kebutuhan Utama |
| --- | --- | --- | --- |
| **BGM (Musik Latar)** | `.ogg` (Ogg Vorbis) | Stereo, 44.1 kHz, wajib mendukung *seamless loop* (centang **Loop** di tab Import Godot). | `bgm_main_menu.ogg`, `bgm_stage_01.ogg`, `bgm_stage_02.ogg` |
| **SFX (Efek Suara)** | `.wav` (PCM 16-bit) | Mono/Stereo, 44.1 kHz, tanpa jeda hening (*silence*) di awal klip agar responsif. | `sfx_jump.wav`, `sfx_switch_screen.wav`, `sfx_cable_click.wav`, `sfx_tower_on.wav`, `sfx_terminal_open.wav`, `sfx_lightning_shoot.wav`, `sfx_robot_hit.wav`, `sfx_gate_close.wav`, `sfx_game_over.wav` |

* **Normalisasi Volume:** Jaga puncak (*peak*) audio BGM di sekitar `-12 dB` hingga `-9 dB`, dan SFX di sekitar `-6 dB` hingga `-3 dB` agar efek suara aksi tetap terdengar jelas di atas musik latar.

---

## 6. Checklist Sebelum Mengunggah Aset ke Git

* [ ] Nama file sudah menggunakan `snake_case` tanpa spasi atau huruf kapital.
* [ ] Dimensi kanvas sesuai dengan tabel ukuran frame di atas.
* [ ] File sudah diletakkan di subfolder yang tepat di dalam `res://assets/`.
* [ ] Proyek sudah dibuka di Godot 4.7 sehingga file `.import` otomatis terbentuk dan ikut di-*commit*.

```

---