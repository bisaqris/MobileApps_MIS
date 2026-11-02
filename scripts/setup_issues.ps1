# Script PowerShell untuk membersihkan label status dan prefix module

Write-Host "=== 1. Menghapus Label Status & Anggota ===" -ForegroundColor Yellow
gh label delete "status:ready" --yes 2>$null
gh label delete "status:backlog" --yes 2>$null
gh label delete "anggota-1" --yes 2>$null
gh label delete "anggota-2" --yes 2>$null
gh label delete "anggota-3" --yes 2>$null

Write-Host "=== 2. Memperbarui Label Tanpa Prefix 'module:' ===" -ForegroundColor Cyan
gh label edit "module:auth" --name "auth" 2>$null; if ($LASTEXITCODE -ne 0) { gh label create "auth" --color "D93F0B" --description "Modul Autentikasi" --force }
gh label edit "module:dashboard" --name "dashboard" 2>$null; if ($LASTEXITCODE -ne 0) { gh label create "dashboard" --color "0075CA" --description "Modul Dashboard" --force }
gh label edit "module:projects" --name "projects" 2>$null; if ($LASTEXITCODE -ne 0) { gh label create "projects" --color "F9D0C4" --description "Modul Projects" --force }
gh label edit "module:approvals" --name "approvals" 2>$null; if ($LASTEXITCODE -ne 0) { gh label create "approvals" --color "E99695" --description "Modul Approvals" --force }
gh label edit "module:manpower" --name "manpower" 2>$null; if ($LASTEXITCODE -ne 0) { gh label create "manpower" --color "BFD4F2" --description "Modul Manpower" --force }
gh label edit "module:clients" --name "clients" 2>$null; if ($LASTEXITCODE -ne 0) { gh label create "clients" --color "D4C5F9" --description "Modul Clients" --force }

$existingTitles = gh issue list --limit 100 --state open --json title --jq '.[].title'

function Check-And-Create($title, $labels, $body) {
    if ($existingTitles -contains $title) {
        Write-Host "✓ Issue sudah ada: '$title' (dilewati)" -ForegroundColor Gray
    } else {
        Write-Host "+ Membuat issue: '$title'" -ForegroundColor Green
        gh issue create --title $title --label $labels --body $body
    }
}

Write-Host "=== 3. Sinkronisasi Target Issue ===" -ForegroundColor Cyan
Check-And-Create "[AUTH] Integrasi API Login & Token Storage" "auth" "Hubungkan login page dengan API backend & flutter_secure_storage."
Check-And-Create "[CORE] Setup Dio Auth Interceptor & Router Guard" "auth" "Setup auth header Bearer token dan redirect guard GoRouter."
Check-And-Create "[DASHBOARD] Integrasi Widget KPI Cards dengan Real API" "dashboard" "Ganti mock KPI cards dengan response API."
Check-And-Create "[DASHBOARD] Implementasi Project Calendar menggunakan table_calendar" "dashboard" "Implementasi kalender jadwal project."
Check-And-Create "[DASHBOARD] Implementasi Financial & Project Chart menggunakan fl_chart" "dashboard" "Implementasi chart performa keuangan."
Check-And-Create "[PROFILE] Halaman Profil & Role-based Sidebar" "auth" "Profil user, tombol logout, dan role filter sidebar."
Check-And-Create "[PROJECTS] Integrasi API Get All Projects (Replace Mock Data)" "projects" "Hubungkan ProjectListPage dengan real API via Dio."
Check-And-Create "[PROJECTS] Form Tambah & Edit Project" "projects" "Form input untuk create dan edit project."
Check-And-Create "[PROJECTS] Halaman Detail Project (/projects/:id)" "projects" "Halaman detail project dan list manpower bertugas."
Check-And-Create "[APPROVALS] Halaman List Production Cost Approval" "approvals" "List pengajuan biaya produksi yang butuh approval."
Check-And-Create "[APPROVALS] Detail Approval & Action Approve/Reject dengan Catatan" "approvals" "Aksi approve atau reject rincian biaya."
Check-And-Create "[HISTORY] Halaman History Project dengan Filter Status & Tahun" "projects" "Arsip riwayat project selesai."
Check-And-Create "[MANPOWER] Halaman List Manpower dengan ResponsiveDataView" "manpower" "Daftar manpower dan filter status ketersediaan."
Check-And-Create "[MANPOWER] Form Tambah & Edit Data Manpower" "manpower" "Form CRUD data SDM manpower."
Check-And-Create "[SKILLS] CRUD Skill Management (/skills)" "manpower" "Manajemen master keahlian tim."
Check-And-Create "[CLIENTS] Halaman Data Client & Form CRUD Client" "clients" "CRUD data kontak client."
Check-And-Create "[COMPANIES] Halaman Data Perusahaan & Form CRUD Company" "clients" "CRUD data instansi/rekanan perusahaan."

Write-Host "=== Selesai! Label Bersih dan Siap Digunakan ===" -ForegroundColor Green
