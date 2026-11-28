# Game Design Document

## 1. Ringkasan Game

Game ini adalah platformer puzzle side-scroller 2D pixel tentang dua kakak beradik yang terpisah dan harus saling membantu untuk pulang bersama, dimainkan **secara bergantian dalam layar penuh** lewat dua sudut pandang karakter yang saling bergantung.

| Aspek           | Keterangan                                                                                                 |
| --------------- | ---------------------------------------------------------------------------------------------------------- |
| Nama game       | No Signal, Connect!                                                                                        |
| Genre           | Platformer, puzzle, side-scroller                                                                          |
| Gaya visual     | 2D pixel art                                                                                               |
| Sudut pandang   | Dua karakter dengan sudut pandang terpisah (Kakak A dan Adik B)                                            |
| Konsep inti     | A menyalakan menara sinyal lewat puzzle jaringan; B memakai sinyal itu untuk menyerang musuh dengan laptop |
| Tujuan akhir    | B keluar dari underground dan pulang bersama A ke rumah                                                    |
| Platform target | Desktop Windows/Linux                                                                                      |
| Target pemain   | Semua kalangan                                                                                             |

## 2. Latar Belakang Cerita

Dua kakak beradik dengan profesi berbeda sedang dalam perjalanan pulang ketika sang adik tiba-tiba terjatuh ke dalam sebuah underground. Lubang tempat ia jatuh langsung tertutup, sehingga adik tidak bisa keluar dan kakak tidak bisa masuk.

Satu-satunya penghubung mereka adalah alat komunikasi buatan sang kakak. Alat ini tidak membutuhkan sinyal internet, tetapi jangkauannya terbatas: keduanya tidak boleh terlalu jauh agar tetap bisa berbicara.

Dari sini lahir dua misi yang berjalan bersamaan. Kakak harus mencari dan menyalakan menara sinyal. Adik harus bertahan di underground dan memakai sinyal itu untuk mengaktifkan laptop magisnya, lalu menemukan jalan keluar.

- Pemicu cerita: adik jatuh ke underground dan lubang tertutup.
- Konflik utama: terpisah, tanpa akses langsung satu sama lain.
- Penghubung: alat komunikasi buatan kakak (tanpa sinyal internet, jangkauan terbatas).
- Resolusi: adik keluar dari underground, lalu pulang bersama kakak.

## 3. Karakter

| Aspek           | Karakter A (Kakak)                                            | Karakter B (Adik)                                        |
| --------------- | ------------------------------------------------------------- | -------------------------------------------------------- |
| Gender          | Pria                                                          | Wanita                                                   |
| Profesi         | Network engineer                                              | Programmer                                               |
| Nama            | Allen                                                         | Luna                                                     |
| Lokasi          | Permukaan, bergerak menuju menara sinyal                      | Underground, terjebak                                    |
| Peran utama     | Memecahkan puzzle dan menyambungkan kabel agar menara menyala | Bertarung dengan command laptop memakai jangkauan sinyal |
| Senjata/alat    | Kabel internet, alat komunikasi                               | Laptop magis (efek kilatan petir)                        |
| Tantangan utama | Puzzle jaringan yang makin sulit                              | Musuh yang makin kuat dan mengetik command dengan benar  |
| Kepribadian     | Bisa di andalkan, jenius, pekerja keras                       | Mengagumi Allen, Pemberani, Ambisius                     |

Kakak digambarkan sebagai network engineer hebat yang mampu menyelesaikan banyak masalah. Adik membawa laptop ke mana pun, tetapi laptop itu hanya bisa berfungsi jika ada sinyal.

## 4. Mekanik Inti

Game memakai dua sudut pandang yang berjalan **bergantian secara berurutan** dalam satu stage (mode bergantian layar penuh): kemajuan A membuka giliran dan kemampuan B.

1. A bergerak menyusuri stage permukaan, melewati puzzle, dan mencari menara sinyal.
2. A menyambungkan kabel internet ke menara agar menara berfungsi.
3. Menara yang menyala memicu transisi ke layar B di underground dengan sinyal aktif.
4. B membuka layar laptop, menulis command tertentu, dan menyerang musuh dengan kilatan petir.
5. B maju melewati stage underground sampai menemukan jalan keluar untuk lanjut ke stage berikutnya.

### Sudut pandang A (Network Engineer)

- Fokus: eksplorasi, puzzle, menyambungkan kabel ke menara sinyal.
- Hambatan: puzzle bertingkat dan musuh di jalur.
- Hasil: menara menyala, yang membuka kemajuan B.

### Sudut pandang B (Programmer)

- Fokus: bertahan, bertarung, dan menempuh jalur underground.
- Syarat: harus berada dalam jangkauan sinyal yang sudah dinyalakan A untuk bisa memakai laptop.
- Senjata: command yang diketik di laptop, berefek kilatan petir.

## 5. Kontrol dan Batasan Karakter

Kedua karakter memakai set gerakan yang sama dan sengaja dibuat sederhana.

| Aksi                  | Aturan                                                                       |
| --------------------- | ---------------------------------------------------------------------------- |
| Gerak kiri / kanan    | Bebas selama berada di dalam stage                                           |
| Lompat                | Maksimal 2 kali berturut-turut (double jump)                                 |
| Sprint                | Mempercepat gerak, memakai energi                                            |
| Health bar            | Berkurang saat terkena serangan atau jebakan; juga menjadi dasar score/point |
| Energi                | Dipakai untuk sprint; habis berarti tidak bisa sprint sampai pulih           |
| Kematian              | Health habis berarti game over; karakter tidak kebal                         |
| Kembali ke stage lama | Tidak bisa; stage yang sudah dilewati tertutup                               |

- Tidak ada mode invincible untuk karakter mana pun.
- Game over terjadi jika salah satu karakter mati. \[Perlu dikonfirmasi: apakah game over berlaku untuk kedua karakter atau hanya karakter yang mati.\]

## 6. Sistem Combat Karakter B

Combat hanya dimiliki Karakter B (Programmer) dan berbasis mengetik command di laptop.

1. B berada dalam jangkauan sinyal yang sudah dinyalakan A.
2. B mengangkat laptop dan membuka layarnya.
3. Satu kali angkat laptop hanya menghasilkan satu kali serangan.
4. Sebuah command muncul di layar laptop dan B harus mengetiknya dengan benar.
5. Jika benar, laptop melepaskan serangan berupa kilatan petir ke musuh.
6. Jika salah, serangan gagal dan layar laptop harus diklik kembali untuk mengulang.
   - Efek serangan: kilatan petir dari laptop.
   - Aturan keras: tanpa sinyal, laptop tidak berfungsi dan tombol open screen tidak tersedia.
   - Kesulitan combat naik per stage lewat command yang lebih panjang atau lebih rumit. \[Ide, belum final\]

## 7. Sistem Puzzle Karakter A

Puzzle adalah penghalang utama A menuju menara sinyal, dan semuanya harus diselesaikan secara sah.

- A tidak boleh melewati puzzle dengan cara skip, memanfaatkan bug, atau menjebol paksa.
- Puzzle harus selesai agar jalur ke stage berikutnya terbuka.
- Tipe puzzle berbeda di tiap stage dan tingkat kesulitannya meningkat.
- Tema puzzle mengikuti profesi A, yaitu jaringan dan kabel. \[Contoh ide, belum final: menyambung kabel ke port yang benar, mengatur urutan perangkat jaringan, memperbaiki jalur yang terputus.\]
- Puzzle terakhir dalam rangkaian adalah menyambungkan kabel internet ke menara sinyal agar menyala.

## 8. Struktur Stage dan Progres

Setiap stage punya tipe enemy dan tipe puzzle sendiri dengan tingkat kesulitan yang berbeda. Pemain tidak bisa kembali ke stage sebelumnya. Tabel di bawah adalah kerangka yang bisa diisi dan ditambah.

| Stage            | Area A (permukaan)  | Tipe puzzle A                                      | Area B (underground)             | Tipe enemy B       | Kesulitan |
| ---------------- | ------------------- | -------------------------------------------------- | -------------------------------- | ------------------ | --------- |
| 1                | Area kota           | Menyambung kabel Listrik sesuai huruf/urutan/angka | Area pembuangan robot dan limbah | Robot rusak        | Mudah     |
| 2                | Dekat jalan raya    | Color memory                                       | Area pembuangan robot dan limbah | drone              | Menengah  |
| Final (opsional) | Menara sinyal utama | \[Isi\]                                            | Jalan keluar underground         | \[Boss, opsional\] | Tersulit  |

- Jumlah stage: 2
- Stage yang sudah dilewati tertutup, sehingga tidak ada backtracking.
- Tiap stage punya satu tujuan jelas: A menyalakan menara, B maju ke titik keluar stage.

## 9. Buff dan Power Up

Kedua karakter berpeluang mendapat buff atau power up dengan asal yang beda-beda, Luna mendapat buff dari drop lawan/musuh, dan Allen mendapatkannya dari random chest Fungsi nya untuk membantu menyelesaikan stage masing-masing. Efeknya terbatas waktu.

| Karakter | Contoh buff (ide, belum final)                                      | Durasi         |
| -------- | ------------------------------------------------------------------- | -------------- |
| A        | Petunjuk puzzle, penambah energi sprint, perisai sementara          | Terbatas waktu |
| B        | Penambah damage petir, waktu mengetik lebih longgar, pemulih health | Terbatas waktu |

- Buff muncul sebagai item di dalam stage dan kemunculannya tidak dijamin (berpeluang).
- Buff hanya berlaku untuk stage tempat item diambil. \[Perlu dikonfirmasi\]

## 10. Ketergantungan A dan B serta Kondisi Menang/Kalah

B tidak bisa maju sendirian: progres B dikunci oleh progres A.

- B tidak bisa memaksa keluar dari stage underground-nya.
- Tombol open screen laptop tidak tersedia jika A belum berprogres atau belum menyelesaikan tujuannya menuju menara sinyal.
- A harus terus maju menuju menara sinyal agar B tetap bisa bertarung.
- Alat komunikasi punya jangkauan terbatas, jadi A dan B tidak boleh terlalu jauh secara alur cerita. \[Perlu dikonfirmasi: apakah jarak ini menjadi mekanik gameplay atau hanya penjelasan cerita.\]

**Menang:** B keluar dari underground dan pulang ke rumah bersama A.

**Kalah:** health salah satu karakter habis, lalu game over.

## 11. Gaya Visual dan Audio

- Visual: 2D pixel art, side-scrolling. Permukaan (area A) dan underground (area B) dibedakan lewat palet warna agar pemain langsung tahu sedang memainkan siapa.
- Efek utama: kilatan petir dari laptop B dan menara sinyal yang menyala saat tersambung.
- UI: health bar, bar energi, score/point, dan indikator sinyal untuk B.
- Audio: \[Belum ditentukan, misalnya musik chiptune dan efek suara ketikan\].