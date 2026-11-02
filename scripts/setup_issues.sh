#!/usr/bin/env bash
set -e

echo "=== 1. Menghapus Label Status (Status Ditangani Oleh Kolom Kanban) ==="
gh label delete "status:ready" --yes 2>/dev/null || true
gh label delete "status:backlog" --yes 2>/dev/null || true
gh label delete "anggota-1" --yes 2>/dev/null || true
gh label delete "anggota-2" --yes 2>/dev/null || true
gh label delete "anggota-3" --yes 2>/dev/null || true

echo "=== 2. Memperbarui Label Tanpa Prefix 'module:' ==="
gh label edit "module:auth" --name "auth" 2>/dev/null || gh label create "auth" --color "D93F0B" --description "Modul Autentikasi" --force || true
gh label edit "module:dashboard" --name "dashboard" 2>/dev/null || gh label create "dashboard" --color "0075CA" --description "Modul Dashboard" --force || true
gh label edit "module:projects" --name "projects" 2>/dev/null || gh label create "projects" --color "F9D0C4" --description "Modul Projects" --force || true
gh label edit "module:approvals" --name "approvals" 2>/dev/null || gh label create "approvals" --color "E99695" --description "Modul Approvals" --force || true
gh label edit "module:manpower" --name "manpower" 2>/dev/null || gh label create "manpower" --color "BFD4F2" --description "Modul Manpower" --force || true
gh label edit "module:clients" --name "clients" 2>/dev/null || gh label create "clients" --color "D4C5F9" --description "Modul Clients" --force || true

echo "=== 3. Mengambil Daftar Open Issue yang Sudah Ada ==="
existing_titles=$(gh issue list --limit 100 --state open --json title --jq '.[].title' || echo "")

check_and_create() {
  local title="$1"
  local labels="$2"
  local body="$3"

  if echo "$existing_titles" | grep -Fxq "$title"; then
    echo "✓ Issue sudah ada: '$title' (dilewati)"
  else
    echo "+ Membuat issue yang hilang: '$title'"
    gh issue create --title "$title" --label "$labels" --body "$body"
  fi
}

echo "=== 4. Sinkronisasi Target Issue ==="

check_and_create "[AUTH] Integrasi API Login & Token Storage" "auth" "### Deskripsi
Hubungkan halaman login dengan API backend dan simpan JWT token ke local secure storage.

### Checklist
- [ ] Validasi form email & password
- [ ] Request API POST /login via Dio
- [ ] Simpan token & refresh token ke flutter_secure_storage
- [ ] Error feedback jika login gagal (snack/banner)
- [ ] State auth disimpan di Riverpod"

check_and_create "[CORE] Setup Dio Auth Interceptor & Router Guard" "auth" "### Deskripsi
Konfigurasi Dio Interceptor untuk inject header Authorization dan redirect guard di go_router.

### Checklist
- [ ] Auth interceptor: tambahkan header 'Authorization: Bearer <token>' pada tiap request
- [ ] Error interceptor: jika response 401 Unauthorized, hapus token dan redirect ke /login
- [ ] GoRouter redirect guard: cegah akses halaman dalam jika belum login"

check_and_create "[DASHBOARD] Integrasi Widget KPI Cards dengan Real API" "dashboard" "### Deskripsi
Ganti nilai statis pada card Dashboard dengan response real dari endpoint summary/statistik BE.

### Checklist
- [ ] Buat model KPI/Summary
- [ ] Fetch data dari API summary dashboard
- [ ] Tampilkan Total Contract, Paid, Rest of Bill, dan Project Cost
- [ ] Handle loading shimmer & error state"

check_and_create "[DASHBOARD] Implementasi Project Calendar menggunakan table_calendar" "dashboard" "### Deskripsi
Tampilkan kalender project dan event di halaman Dashboard menggunakan package table_calendar.

### Checklist
- [ ] Setup table_calendar di dashboard_page
- [ ] Tandai tanggal yang memiliki jadwal event project
- [ ] Tampilkan list event yang terjadi pada tanggal yang diklik"

check_and_create "[DASHBOARD] Implementasi Financial & Project Chart menggunakan fl_chart" "dashboard" "### Deskripsi
Implementasikan grafik visualisasi data pada dashboard menggunakan fl_chart.

### Checklist
- [ ] Buat Bar Chart / Line Chart tren pendapatan atau status project
- [ ] Tooltip saat bar chart disentuh
- [ ] Desain responsif mengikuti lebar layar"

check_and_create "[PROFILE] Halaman Profil & Role-based Sidebar" "auth" "### Deskripsi
Halaman profil pengguna dan filter menu sidebar berdasarkan role akun.

### Checklist
- [ ] Tampilkan informasi profil user (nama, role, email)
- [ ] Fitur Logout (clear token, reset state, redirect ke /login)
- [ ] Filter item sidebar AppShell berdasarkan role pengguna"

check_and_create "[PROJECTS] Integrasi API Get All Projects (Replace Mock Data)" "projects" "### Deskripsi
Ganti MockProjectRepository dengan HttpProjectRepository yang memanggil REST API backend.

### Checklist
- [ ] Sesuaikan model Project dengan JSON backend
- [ ] Buat repository Dio untuk fetch list project
- [ ] Implementasi search query ke backend
- [ ] Tampilkan data asli pada ProjectListPage"

check_and_create "[PROJECTS] Form Tambah & Edit Project" "projects" "### Deskripsi
Buat form dialog atau halaman untuk membuat project baru dan mengedit project yang sudah ada.

### Checklist
- [ ] Form input: Nama, Kategori, PM, Nilai Kontrak, Tanggal Event
- [ ] Validasi form input
- [ ] Request POST project baru ke BE
- [ ] Request PUT/PATCH edit project ke BE
- [ ] Integrasi tombol delete project dengan konfirmasi dialog"

check_and_create "[PROJECTS] Halaman Detail Project (/projects/:id)" "projects" "### Deskripsi
Halaman detail project yang menampilkan informasi lengkap dan daftar tim yang bertugas.

### Checklist
- [ ] Route dinamis /projects/:id di AppRouter
- [ ] Fetch detail project by ID dari BE
- [ ] Tampilkan rincian biaya, client, dan status milestone
- [ ] Tampilkan tim manpower yang di-assign ke project"

check_and_create "[APPROVALS] Halaman List Production Cost Approval" "approvals" "### Deskripsi
Halaman list pengajuan biaya produksi yang memerlukan persetujuan.

### Checklist
- [ ] Buat model & repository untuk Production Cost Approval
- [ ] Tampilan list menggunakan ResponsiveDataView
- [ ] Badge status approval (Pending, Approved, Rejected)
- [ ] Filter berdasarkan status pengajuan"

check_and_create "[APPROVALS] Detail Approval & Action Approve/Reject dengan Catatan" "approvals" "### Deskripsi
Aksi approve atau reject pengajuan biaya produksi.

### Checklist
- [ ] Dialog/Halaman rincian item pengeluaran biaya
- [ ] Tombol Approve -> memicu API POST /approve
- [ ] Tombol Reject -> buka dialog input alasan penolakan -> memicu API POST /reject
- [ ] Refresh data otomatis setelah aksi berhasil"

check_and_create "[HISTORY] Halaman History Project dengan Filter Status & Tahun" "projects" "### Deskripsi
Halaman arsip project yang telah selesai atau ditutup.

### Checklist
- [ ] Tampilan list history project
- [ ] Filter berdasarkan tahun dan kategori
- [ ] Ringkasan pencapaian dan total nilai kontrak project selesai"

check_and_create "[MANPOWER] Halaman List Manpower dengan ResponsiveDataView" "manpower" "### Deskripsi
Tampilkan daftar seluruh manpower/SDM tim menggunakan ResponsiveDataView.

### Checklist
- [ ] Model Manpower & repository Dio
- [ ] Tampilan data manpower (nama, role/keahlian, status ketersediaan, kontak)
- [ ] Search & filter manpower berdasarkan ketersediaan (Available / On Project)"

check_and_create "[MANPOWER] Form Tambah & Edit Data Manpower" "manpower" "### Deskripsi
Fitur untuk menambahkan manpower baru dan memperbarui data manpower.

### Checklist
- [ ] Form input data manpower (nama, kontak, keahlian/skill, role)
- [ ] Integrasi endpoint POST /manpower
- [ ] Integrasi endpoint PUT /manpower/:id
- [ ] Aksi hapus manpower dengan dialog konfirmasi"

check_and_create "[SKILLS] CRUD Skill Management (/skills)" "manpower" "### Deskripsi
Manajemen data master keahlian/skill tim.

### Checklist
- [ ] Tampilan list skills (/skills)
- [ ] Dialog tambah skill baru
- [ ] Dialog edit skill & hapus skill
- [ ] Integrasi API CRUD skills"

check_and_create "[CLIENTS] Halaman Data Client & Form CRUD Client" "clients" "### Deskripsi
Manajemen data kontak client perorangan atau PIC perusahaan.

### Checklist
- [ ] List data client menggunakan ResponsiveDataView
- [ ] Search client by nama / email / no telp
- [ ] Form tambah & edit client
- [ ] Hapus data client dengan konfirmasi"

check_and_create "[COMPANIES] Halaman Data Perusahaan & Form CRUD Company" "clients" "### Deskripsi
Manajemen data perusahaan / instansi rekanan klien.

### Checklist
- [ ] List data instansi/company
- [ ] Form tambah & edit data perusahaan (nama instansi, alamat, nomor kontak)
- [ ] Tampilkan daftar project yang terhubung dengan company tersebut"

echo "=== Selesai! Label Bersih dan Siap Digunakan ==="
