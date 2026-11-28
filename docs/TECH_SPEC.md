# Spesifikasi Teknis & Arsitektur — No Signal, Connect!

Dokumen ini menjadi referensi teknis bagi Programmer dan Level Designer dalam memahami alur data lintas layar, perakitan entitas berbasis komponen, serta konfigurasi fisika di **Godot Engine 4.7**.

---

## 1. Arsitektur Dual-Viewport Bergantian Layar Penuh

Permainan menampung dua dunia terpisah dalam satu *scene* utama menggunakan dua `SubViewport` berukuran penuh (`1280x720`) pada `res://main.tscn`, yang ditampilkan **secara bergantian** (bukan *split-screen* simultan):

```text
Main (Control - main.gd)
├── HudDualScreen (CanvasLayer)            <-- UI statis lintas stage (HP, Energy, Status Sinyal)
├── TopContainer (SubViewportContainer)
│   └── TopViewport (SubViewport)          <-- Memuat scene surface_XX.tscn (Allen)
└── BottomContainer (SubViewportContainer)
    └── BottomViewport (SubViewport)       <-- Memuat scene underground_XX.tscn (Luna)
```

### Alur Pergantian Layar & Transisi Level

* **Mode Bergantian Layar Penuh:** Setiap stage dimulai pada layar **Allen (`TopContainer`)**. Selama giliran Allen, `BottomContainer` disembunyikan (`visible = false`) dan dibekukan (`PROCESS_MODE_DISABLED`). Saat `SignalTower` diaktifkan (`GameBridge.signal_state_changed(true)`), `main.gd` memanggil `switch_to_underground()` dengan *fade* layar hitam, membekukan dunia atas, lalu mengaktifkan **Luna (`BottomContainer`)** beserta musik latarnya.
* **Dilarang menggunakan `get_tree().change_scene_to_file()`** untuk perpindahan antar-stage di dalam gameplay karena akan menghancurkan `TopViewport`, `BottomViewport`, dan `HudDualScreen`.
* Pergantian stage dikendalikan oleh `main.gd` (`_load_stage()`) dengan menghapus *child* lama di dalam `TopViewport` dan `BottomViewport` (`queue_free()`), lalu melakukan `instantiate()` pasangan level baru berdasarkan indeks `current_stage` dan kembali menampilkan layar Allen.
* Seluruh pop-up UI spesifik dunia (seperti `CablePuzzle` milik menara atau `LaptopTerminal` milik Luna) dibungkus menggunakan `CanvasLayer` di dalam *scene* masing-masing agar terisolasi per dunia.

---

## 2. Global Autoloads (`GameBridge` & `Game`)

### A. `GameBridge` (`res://autoload/game_bridge.gd`)
Bertindak sebagai *event bus* tunggal antara dunia permukaan (`TOP`), dunia bawah (`BOTTOM`), `Main`, dan `HudDualScreen`. Node di layar atas dilarang mengakses node di layar bawah secara langsung menggunakan `get_node()`.

#### Enum & State Global

| Properti | Tipe | Default | Fungsi |
| --- | --- | --- | --- |
| `Screen` | `enum` | `TOP, BOTTOM` | Identitas layar aktif dan kepemilikan karakter (`assigned_screen`). |
| `active_screen` | `Screen` | `Screen.TOP` | Menentukan karakter mana yang saat ini tampil penuh dan menerima input gerak/aksi. |
| `is_signal_active` | `bool` | `false` | Status menara sinyal. Harus `true` agar berpindah ke Luna serta membuka laptop & pintu keluar stage. |
| `current_stage` | `int` | `0` | Indeks stage aktif (berbasis 0) untuk array level di `main.gd`. |
| `total_stages` | `int` | `2` | Jumlah total stage sebelum memicu kondisi menang (`game_won`). |

#### Peta Sinyal Global

| Nama Sinyal | Parameter | Pengirim (*Emitter*) | Penerima (*Listener*) |
| --- | --- | --- | --- |
| `screen_switched` | `new_screen: Screen` | `Main` (`_show_top_screen` / `_show_bottom_screen`) | `HudDualScreen` |
| `signal_state_changed` | `is_active: bool` | `SignalTower` via `GameBridge` | `Main` (transisi ke Luna), `HudDualScreen`, `StageExit` |
| `player_health_updated` | `screen: Screen, current: float, max_val: float` | `BasePlayer` | `HudDualScreen` |
| `player_energy_updated` | `screen: Screen, current: float, max_val: float` | `BasePlayer` | `HudDualScreen` |
| `game_over` | *(tanpa parameter)* | `BasePlayer` (`health_comp.died`) via `GameBridge` | `GameBridge` (reset state & reload) |
| `stage_changed` | `stage_index: int` | `GameBridge` (`completed_stage`) | `Main` (`_load_stage`) |
| `game_won` | *(tanpa parameter)* | `GameBridge` (`completed_stage`) | `Main` (`_on_game_won`) |

### B. `Game` (`res://autoload/game.gd`)
Mengelola navigasi antar-*screen* utama (`MainMenu` $\rightarrow$ `Intro` $\rightarrow$ `Main`), `RetroTheme`, overlay CRT (`crt.gdshader`), transisi *pixel fade*, penyimpanan `user://settings.cfg`, pool SFX UI, serta pemutaran BGM dengan *crossfade*.

---

## 3. Sistem Komponen & Pewarisan Entitas

Proyek ini menggabungkan **Script Inheritance** untuk variasi perilaku karakter dan **Composition** (`res://components/`) untuk fitur stat dan pertarungan.

### Hierarki Karakter Pemain

* **`BasePlayer`** (`res://entities/players/base_player/`): Mengatur gravitasi, gerak horizontal dengan `move_toward()`, *double jump* (`max_jump = 2`), *sprint* berbasis energi, filter `active_screen`, sakelar `can_move`, serta penerusan sinyal HP/Energi ke `GameBridge` menggunakan `.call_deferred()`.
* **`Allen`** (`res://entities/players/allen/`): Mewarisi `BasePlayer` (`assigned_screen = Screen.TOP`).
* **`Luna`** (`res://entities/players/luna/`): Mewarisi `BasePlayer` (`assigned_screen = Screen.BOTTOM`), menambahkan deteksi arah hadap (`facing_direction`), kontrol `LaptopTerminal`, dan *instantiating* proyektil `LightningBolt`.

### Daftar Komponen (`res://components/`)

1. **`HealthComponent` (`Node`)**
* **Properti:** `@export var max_health: float = 100.0`
* **Sinyal:** `health_changed(current: float, max_val: float)`, `died`
* **Method:** `take_damage(amount: float)`, `heal(amount: float)`


2. **`EnergyComponent` (`Node`)**
* **Properti:** `max_energi`, `drain_rate`, `regen_rate`, `recovery_threshold`
* **Sinyal:** `energy_changed(current: float, max: float)`
* **Method:** `can_sprint() -> bool`, `consume(delta: float)`, `regenerate(delta: float)`


3. **`HitboxComponent` (`Area2D`)**
* **Properti:** `@export var damage: float = 25.0`
* **Penggunaan:** Dipasang pada jebakan lingkungan, badan/serangan musuh, dan diwarisi langsung oleh `lightning_bolt.gd`.


4. **`HurtboxComponent` (`Area2D`)**
* **Properti:** `@export var health_comp: HealthComponent` (wajib di-assign lewat Inspector).
* **Mekanisme:** Mendengarkan sinyal `area_entered`; jika area tersebut bertipe `HitboxComponent`, otomatis memanggil `health_comp.take_damage(area.damage)`.



> **Catatan Urutan Eksekusi:** Pengiriman data awal HP dan Energi di `BasePlayer._ready()` wajib menggunakan `.call_deferred()` agar `HudDualScreen` sudah selesai menjalankan `_ready()` dan menyambungkan sinyalnya sebelum data pertama dipancarkan.

---

## 4. Konfigurasi 2D Physics: Collision Layer & Mask

Seluruh interaksi fisika dibagi ke dalam **6 Layer** (dikonfigurasi di **Project Settings $\rightarrow$ Layer Names $\rightarrow$ 2D Physics**) untuk mencegah musuh melukai dirinya sendiri atau proyektil Luna mengenai Allen/Luna:

* **Layer 1 (`World`):** Lantai, dinding, platform, dan pembatas arena.
* **Layer 2 (`Player`):** Karakter Allen dan Luna.
* **Layer 3 (`Enemy`):** Musuh darat (`BrokenRobot`) dan musuh udara (`Drone`).
* **Layer 4 (`PlayerHitbox`):** Proyektil serangan Luna (`LightningBolt`).
* **Layer 5 (`EnemyHitbox`):** Serangan kontak musuh dan jebakan lingkungan.
* **Layer 6 (`Interactable`):** Menara sinyal, gerbang satu arah, item *buff*, dan pintu keluar stage.

### Tabel Matriks Layer & Mask

| Scene & Node | Tipe Node | Collision Layer | Collision Mask | Catatan Implementasi |
| --- | --- | --- | --- | --- |
| **`Floor` / `TileMapLayer**` | `StaticBody2D` | `1 (World)` | *(Kosong)* | Permukaan pijakan dan dinding pembatas. |
| **`BasePlayer`** | `CharacterBody2D` | `2 (Player)` | `1 (World)` | Tidak bertabrakan fisik kaku dengan musuh. |
| **`BasePlayer/HurtboxComponent`** | `Area2D` | `2 (Player)` | `5 (EnemyHitbox)` | Hanya menerima *damage* dari musuh & jebakan. |
| **`BrokenRobot` / `Drone**` | `CharacterBody2D` | `3 (Enemy)` | `1 (World)` | Patroli terhadap dinding/lantai. |
| **`BrokenRobot/WallCheck`** | `RayCast2D` | *(Tidak ada)* | `1 (World)` | Wajib membalik `target_position.x` saat berbalik arah. |
| **`Enemy/HurtboxComponent`** | `Area2D` | `3 (Enemy)` | `4 (PlayerHitbox)` | Hanya menerima *damage* dari serangan petir Luna. |
| **`Enemy/HitboxComponent`** | `Area2D` | `5 (EnemyHitbox)` | *(Kosong)* | Memancarkan *damage* saat menyentuh `Hurtbox` Player. |
| **`Hazard` / Jebakan** | `HitboxComponent` | `5 (EnemyHitbox)` | *(Kosong)* | Melukai Player tanpa melukai musuh di sekitar. |
| **`LightningBolt`** | `HitboxComponent` | `4 (PlayerHitbox)` | `1 (World)`, `3 (Enemy)` | Hancur (`queue_free()`) saat mengenai dinding atau musuh. |
| **`SignalTower`** | `Area2D` | `6 (Interactable)` | `2 (Player)` | Mendeteksi `body_entered` khusus Player. |
| **`OneWayGate/BlockerWall`** | `StaticBody2D` | `1 (World)` | *(Kosong)* | `WallCollision` diaktifkan via `set_deferred("disabled", false)`. |
| **`OneWayGate/PassTrigger`** | `Area2D` | `6 (Interactable)` | `2 (Player)` | Memicu penutupan gerbang saat Player lewat ke kanan. |
| **`StageExit`** | `Area2D` | `6 (Interactable)` | `2 (Player)` | Memeriksa `GameBridge.is_signal_active` saat Player masuk. |

---

## 5. Panduan Menambah Konten Baru (Stage 2 & Ekspansi)

### Menambah Musuh Baru (Contoh: `Drone` di `res://entities/enemies/drone/`)

1. Buat *scene* baru dengan root `CharacterBody2D` (`drone.tscn`).
2. Tambahkan child `HealthComponent`, `HurtboxComponent` (Layer `3`, Mask `4`), dan `HitboxComponent` (Layer `5`, Mask kosong).
3. Hubungkan `HurtboxComponent.health_comp` ke node `HealthComponent` di Inspector, lalu hubungkan sinyal `health_comp.died` ke `queue_free` di dalam script.

### Menambah Stage Baru

1. Buat pasangan *scene* `surface_0X.tscn` dan `underground_0X.tscn` di folder `res://levels/stage_0X/`.
2. Pastikan `surface_0X.tscn` memiliki instance `Allen` dan minimal satu `SignalTower`.
3. Pastikan `underground_0X.tscn` memiliki instance `Luna` (`assigned_screen = BOTTOM`) dan satu `StageExit`.
4. Daftarkan kedua path *scene* ke array `surface_levels` dan `underground_levels` di `res://main.gd`, lalu perbarui nilai `total_stages` di `res://autoload/game_bridge.gd`.

```

---