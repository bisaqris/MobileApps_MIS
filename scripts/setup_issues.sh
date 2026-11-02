#!/usr/bin/env bash
set -e

echo "=== Membersihkan Label Anggota (Jika Ada) ==="
gh label delete "anggota-1" --yes 2>/dev/null || true
gh label delete "anggota-2" --yes 2>/dev/null || true
gh label delete "anggota-3" --yes 2>/dev/null || true

echo "=== Memastikan Label Modul & Status Tersedia ==="
gh label create "status:ready" --color "FBCA04" --description "Siap dikerjakan (Sprint 1)" --force || true
gh label create "status:backlog" --color "C5DEF5" --description "Backlog (Sprint 2 & 3)" --force || true
gh label create "module:auth" --color "D93F0B" --description "Modul Autentikasi" --force || true
gh label create "module:dashboard" --color "0075CA" --description "Modul Dashboard" --force || true
gh label create "module:projects" --color "F9D0C4" --description "Modul Projects" --force || true
gh label create "module:approvals" --color "E99695" --description "Modul Approvals" --force || true
gh label create "module:manpower" --color "BFD4F2" --description "Modul Manpower" --force || true
gh label create "module:clients" --color "D4C5F9" --description "Modul Clients" --force || true

echo "=== Memeriksa dan Membersihkan Issue Duplikat ==="
temp_file=$(mktemp)
seen_file=$(mktemp)

# Ambil daftar seluruh open issue, urutkan berdasarkan nomor issue terkecil
gh issue list --limit 200 --state open --json number,title --jq '.[] | "\(.number)\t\(.title)"' | sort -n > "$temp_file"

while IFS=$'\t' read -r num title; do
  if [ -z "$num" ] || [ -z "$title" ]; then
    continue
  fi

  if grep -Fxq "$title" "$seen_file"; then
    echo "Mendeteksi duplikat! Menghapus/menutup Issue #$num: '$title'"
    gh issue delete "$num" --yes 2>/dev/null || gh issue close "$num" --reason "not_planned" || true
  else
    echo "$title" >> "$seen_file"
  fi
done < "$temp_file"

rm -f "$temp_file" "$seen_file"

# Fungsi pembantu untuk membuat issue jika belum ada
create_issue_if_not_exists() {
  local title="$1"
  local labels="$2"
  local body="$3"

  # Cek apakah issue dengan judul ini sudah ada di open issues
  local count
  count=$(gh issue list --limit 100 --state open --search "\"$title\" in:title" --json title --jq "[.[] | select(.title == \"$title\")] | length")

  if [ "$count" -gt 0 ]; then
    echo "Issue sudah ada: '$title' (dilewati)"
  else
    echo "Membuat issue baru: '$title'"
    gh issue create --title "$title" --label "$labels" --body "$body"
  fi
}

echo "=== Sinkronisasi 17 Issue Unik ==="

create_issue_if_not_exists "[AUTH] Integrasi API Login & Token Storage" "status:ready,module:auth" "### Deskripsi
Hubungkan halaman login dengan API backend dan simpan JWT token ke local secure storage.

### Checklist
- [ ] Validasi form email & password
- [ ] Request API POST /login via Dio
- [ ] Simpan token & refresh token ke flutter_secure_storage
- [ ] Error feedback jika login gagal (snack/banner)
- [ ] State auth disimpan di Riverpod"

create_issue_if_not_exists "[CORE] Setup Dio Auth Interceptor & Router Guard" "status:ready,module:auth" "### Deskripsi
Konfigurasi Dio Interceptor untuk inject header Authorization dan redirect guard di go_router.

### Checklist
- [ ] Auth interceptor: tambahkan header 'Authorization: Bearer <token>' pada tiap request
- [ ] Error interceptor: jika response 401 Unauthorized, hapus token dan redirect ke /login
- [ ] GoRouter redirect guard: cegah akses halaman dalam jika belum login"

create_issue_if_not_exists "[DASHBOARD] Integrasi Widget KPI Cards dengan Real API" "status:backlog,module:dashboard" "### Deskripsi
Ganti nilai statis pada card Dashboard dengan response real dari endpoint summary/statistik BE.

### Checklist
- [ ] Buat model KPI/Summary
- [ ] Fetch data dari API summary dashboard
- [ ] Tampilkan Total Contract, Paid, Rest of Bill, dan Project Cost
- [ ] Handle loading shimmer & error state"

create_issue_if_not_exists "[DASHBOARD] Implementasi Project Calendar menggunakan table_calendar" "status:backlog,module:dashboard" "### Deskripsi
Tampilkan kalender project dan event di halaman Dashboard menggunakan package table_calendar.

### Checklist
- [ ] Setup table_calendar di dashboard_page
- [ ] Tandai tanggal yang memiliki jadwal event project
- [ ] Tampilkan list event yang terjadi pada tanggal yang diklik"

create_issue_if_not_exists "[DASHBOARD] Implementasi Financial & Project Chart menggunakan fl_chart" "status:backlog,module:dashboard" "### Deskripsi
Implementasikan grafik visualisasi data pada dashboard menggunakan fl_chart.

### Checklist
- [ ] Buat Bar Chart / Line Chart tren pendapatan atau status project
- [ ] Tooltip saat bar chart disentuh
- [ ] Desain responsif mengikuti lebar layar"

create_issue_if_not_exists "[PROFILE] Halaman Profil & Role-based Sidebar" "status:backlog,module:auth" "### Deskripsi
Halaman profil pengguna dan filter menu sidebar berdasarkan role akun.

### Checklist
- [ ] Tampilkan informasi profil user (nama, role, email)
- [ ] Fitur Logout (clear token, reset state, redirect ke /login)
- [ ] Filter item sidebar AppShell berdasarkan role pengguna"

create_issue_if_not_exists "[PROJECTS] Integrasi API Get All Projects (Replace Mock Data)" "status:ready,module:projects" "### Deskripsi
Ganti MockProjectRepository dengan HttpProjectRepository yang memanggil REST API backend.

### Checklist
- [ ] Sesuaikan model Project dengan JSON backend
- [ ] Buat repository Dio untuk fetch list project
- [ ] Implementasi search query ke backend
- [ ] Tampilkan data asli pada ProjectListPage"

create_issue_if_not_exists "[PROJECTS] Form Tambah & Edit Project" "status:ready,module:projects" "### Deskripsi
Buat form dialog atau halaman untuk membuat project baru dan mengedit project yang sudah ada.

### Checklist
- [ ] Form input: Nama, Kategori, PM, Nilai Kontrak, Tanggal Event
- [ ] Validasi form input
- [ ] Request POST project baru ke BE
- [ ] Request PUT/PATCH edit project ke BE
- [ ] Integrasi tombol delete project dengan konfirmasi dialog"

create_issue_if_not_exists "[PROJECTS] Halaman Detail Project (/projects/:id)" "status:backlog,module:projects" "### Deskripsi
Halaman detail project yang menampilkan informasi lengkap dan daftar tim yang bertugas.

### Checklist
- [ ] Route dinamis /projects/:id di AppRouter
- [ ] Fetch detail project by ID dari BE
- [ ] Tampilkan rincian biaya, client, dan status milestone
- [ ] Tampilkan tim manpower yang di-assign ke project"

create_issue_if_not_exists "[APPROVALS] Halaman List Production Cost Approval" "status:backlog,module:approvals" "### Deskripsi
Halaman list pengajuan biaya produksi yang memerlukan persetujuan.

### Checklist
- [ ] Buat model & repository untuk Production Cost Approval
- [ ] Tampilan list menggunakan ResponsiveDataView
- [ ] Badge status approval (Pending, Approved, Rejected)
- [ ] Filter berdasarkan status pengajuan"

create_issue_if_not_exists "[APPROVALS] Detail Approval & Action Approve/Reject dengan Catatan" "status:backlog,module:approvals" "### Deskripsi
Aksi approve atau reject pengajuan biaya produksi.

### Checklist
- [ ] Dialog/Halaman rincian item pengeluaran biaya
- [ ] Tombol Approve -> memicu API POST /approve
- [ ] Tombol Reject -> buka dialog input alasan penolakan -> memicu API POST /reject
- [ ] Refresh data otomatis setelah aksi berhasil"

create_issue_if_not_exists "[HISTORY] Halaman History Project dengan Filter Status & Tahun" "status:backlog,module:projects" "### Deskripsi
Halaman arsip project yang telah selesai atau ditutup.

### Checklist
- [ ] Tampilan list history project
- [ ] Filter berdasarkan tahun dan kategori
- [ ] Ringkasan pencapaian dan total nilai kontrak project selesai"

create_issue_if_not_exists "[MANPOWER] Halaman List Manpower dengan ResponsiveDataView" "status:ready,module:manpower" "### Deskripsi
Tampilkan daftar seluruh manpower/SDM tim menggunakan ResponsiveDataView.

### Checklist
- [ ] Model Manpower & repository Dio
- [ ] Tampilan data manpower (nama, role/keahlian, status ketersediaan, kontak)
- [ ] Search & filter manpower berdasarkan ketersediaan (Available / On Project)"

create_issue_if_not_exists "[MANPOWER] Form Tambah & Edit Data Manpower" "status:ready,module:manpower" "### Deskripsi
Fitur untuk menambahkan manpower baru dan memperbarui data manpower.

### Checklist
- [ ] Form input data manpower (nama, kontak, keahlian/skill, role)
- [ ] Integrasi endpoint POST /manpower
- [ ] Integrasi endpoint PUT /manpower/:id
- [ ] Aksi hapus manpower dengan dialog konfirmasi"

create_issue_if_not_exists "[SKILLS] CRUD Skill Management (/skills)" "status:ready,module:manpower" "### Deskripsi
Manajemen data master keahlian/skill tim.

### Checklist
- [ ] Tampilan list skills (/skills)
- [ ] Dialog tambah skill baru
- [ ] Dialog edit skill & hapus skill
- [ ] Integrasi API CRUD skills"

create_issue_if_not_exists "[CLIENTS] Halaman Data Client & Form CRUD Client" "status:ready,module:clients" "### Deskripsi
Manajemen data kontak client perorangan atau PIC perusahaan.

### Checklist
- [ ] List data client menggunakan ResponsiveDataView
- [ ] Search client by nama / email / no telp
- [ ] Form tambah & edit client
- [ ] Hapus data client dengan konfirmasi"

create_issue_if_not_exists "[COMPANIES] Halaman Data Perusahaan & Form CRUD Company" "status:backlog,module:clients" "### Deskripsi
Manajemen data perusahaan / instansi rekanan klien.

### Checklist
- [ ] List data instansi/company
- [ ] Form tambah & edit data perusahaan (nama instansi, alamat, nomor kontak)
- [ ] Tampilkan daftar project yang terhubung dengan company tersebut"

echo "=== Selesai! Duplikat Dibersihkan dan Hanya 17 Issue Unik yang Aktif ==="
