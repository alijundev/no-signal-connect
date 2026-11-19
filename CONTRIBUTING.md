# Panduan Kontribusi — No Signal, Connect!

Dokumen ini mengatur alur kerja Git, standar penamaan, dan aturan teknis khusus Godot Engine agar seluruh anggota tim (Programmer, Level Designer, dan Artist) dapat berkolaborasi tanpa merusak referensi *scene* maupun menimbulkan *merge conflict*.

---

## 1. Sinkronisasi Lingkungan Kerja

* **Versi Engine Wajib:** **Godot Engine 4.7** (Standard GDScript). Dilarang melakukan *upgrade* versi engine tanpa kesepakatan seluruh tim karena dapat mengubah format internal `project.godot` dan file `.tscn`.
* **Testing Sebelum Push:** Pastikan proyek dapat dijalankan (`F5`) tanpa *error* merah di panel **Debugger** sebelum membuat *Pull Request*.

---

## 2. Alur Kerja Git (*Branching* & *Commit*)

### Struktur Branch
* `main` — *Branch* stabil yang siap untuk demo atau *build* rilis. **Dilarang *push* langsung ke `main`.**
* `dev` — *Branch* utama penggabungan fitur sebelum masuk ke `main`.
* *Branch* kerja individu (buat dari `dev`):
  * `feat/<nama-fitur>` — Mekanik atau sistem baru (contoh: `feat/color-memory-puzzle`, `feat/drone-enemy`).
  * `level/<nama-level>` — Desain map dan penempatan rintangan (contoh: `level/stage-02-surface`).
  * `art/<nama-aset>` — Penambahan sprite, tileset, UI, atau audio (contoh: `art/allen-animations`).
  * `fix/<nama-bug>` — Perbaikan bug (contoh: `fix/drone-collision-mask`).

### Format Pesan Commit
Gunakan awalan (*prefix*) yang jelas agar riwayat perubahan mudah dilacak:
* `feat: tambah logika puzzle color memory untuk menara stage 2`
* `level: susun layout platform dan jebakan pada underground_02`
* `art: tambah spritesheet animasi lari dan lompat luna`
* `fix: perbaiki arah raycast pada broken_robot`
* `docs: perbarui tabel collision layer di TECH_SPEC.md`

---

## 3. Aturan Emas Anti-Konflik Godot

File `.tscn` (scene) dan `project.godot` adalah file teks terstruktur yang sangat rentan konflik jika diedit dua orang sekaligus. Patuhi aturan berikut:

1. **Satu File `.tscn` = Satu Orang pada Satu Waktu**
   * Sebelum mengedit *scene* bersama seperti `main.tscn`, `surface_01.tscn`, `underground_01.tscn`, atau `project.godot`, beri kabar di grup tim terlebih dahulu.
   * Buat fitur baru dalam *scene* mandiri di folder `mechanics/` atau `entities/` terlebih dahulu sebelum di-*instantiate* ke dalam level utama.
2. **Pindahkan & Ubah Nama File Hanya Lewat Editor Godot**
   * **Dilarang** memindahkan, mengganti nama, atau menghapus file lewat File Explorer / Finder / Terminal OS.
   * Selalu lakukan lewat panel **FileSystem** di dalam editor Godot agar file `.uid` dan jalur `preload()` diperbarui otomatis.
3. **Wajib Sertakan File `.uid` dan `.import`**
   * Setiap membuat *script* baru (`.gd`), Godot otomatis membuat pasangan file `.gd.uid`. Pastikan keduanya ikut ter-*commit*.
   * Setiap memasukkan gambar (`.png`) atau audio (`.ogg`/`.wav`), jalankan editor Godot sebentar agar file `.import` terbentuk, lalu ikut sertakan dalam *commit*.

---

## 4. Standar Penamaan & Gaya Kode

### Konvensi Penamaan
| Jenis Elemen | Gaya Penamaan | Contoh Benar | Contoh Salah |
| :--- | :--- | :--- | :--- |
| **Folder & File** (`.tscn`, `.gd`, `.png`) | `snake_case` | `signal_tower.tscn`, `broken_robot.gd` | `SignalTower.tscn`, `brokenRobot.gd` |
| **Node di Scene Tree** | `PascalCase` | `HealthComponent`, `WallCheck`, `TopViewport` | `health_component`, `wallcheck` |
| **Class Name (`class_name`)** | `PascalCase` | `BasePlayer`, `HitboxComponent` | `base_player` |
| **Variabel & Fungsi GDScript** | `snake_case` | `move_speed`, `activate_tower()` | `moveSpeed`, `ActivateTower()` |
| **Konstanta & Enum** | `UPPER_SNAKE_CASE` | `LIGHTNING_SCENE`, `Screen.TOP` | `lightningScene` |

### Prinsip Arsitektur Kode
* **Gunakan Static Typing:** Selalu tulis tipe data pada variabel, parameter, dan nilai kembali fungsi untuk mencegah *bug* saat *runtime*:
  ```gdscript
  @export var move_speed: float = 80.0

  func take_damage(amount: float) -> void:
  	pass

```

* **Utamakan Composition:** Untuk objek baru yang membutuhkan HP, energi, atau deteksi serangan, pasang node dari `res://components/` (`HealthComponent`, `EnergyComponent`, `HitboxComponent`, `HurtboxComponent`) daripada menulis ulang logikanya.
* **Komunikasi Lintas Layar:** Karakter di layar atas (`TOP`) dan bawah (`BOTTOM`) tidak boleh saling mengakses node secara langsung (`get_node("../...")`). Gunakan sinyal global melalui Autoload `GameBridge`.

---

## 5. Checklist Sebelum Membuat Pull Request

* [ ] *Branch* sudah diperbarui (*pull/rebase*) dengan perubahan terbaru dari `dev`.
* [ ] Seluruh file `.gd.uid` dan `.import` baru ikut masuk dalam *commit*.
* [ ] Tidak ada *hardcoded path* yang rusak setelah pemindahan folder.
* [ ] Game diuji dari `main.tscn` (`F5`): perpindahan layar (`Tab`), puzzle menara, combat laptop, dan transisi stage berjalan normal tanpa *error*.

```

---