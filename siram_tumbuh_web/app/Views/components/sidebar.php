<!-- SIDEBAR -->
    <div class="w-64 bg-green-900 text-white flex flex-col hidden print-hidden shrink-0 border-r border-green-800 transition-all duration-300" id="sidebar">
        <div class="p-5 flex items-center justify-between border-b border-green-800">
            <div class="flex items-center">
                <i data-lucide="leaf" class="w-7 h-7 mr-3 text-green-400"></i>
                <div>
                    <h1 class="font-bold text-lg leading-tight">Mitra Rizki</h1>
                    <span class="text-[10px] text-green-300 uppercase tracking-wider font-bold">Admin Panel</span>
                </div>
            </div>
        </div>
        
        <!-- QUICK ACTIONS -->
        <div class="p-4 border-b border-green-800/50">
            <p class="text-[10px] text-green-400/70 font-black uppercase tracking-wider mb-2 px-2">Aksi Cepat</p>
            <div class="grid grid-cols-2 gap-2">
                <button onclick="document.getElementById('nav-database').click(); setTimeout(() => document.getElementById('btn-tambah-db').click(), 100);" class="flex flex-col items-center justify-center p-2 bg-white/5 hover:bg-white/10 rounded-xl transition-colors border border-white/5 group relative" title="Tambah Klien/Pekerja">
                    <i data-lucide="user-plus" class="w-5 h-5 text-blue-300 mb-1 group-hover:scale-110 transition-transform"></i>
                    <span class="text-[9px] font-bold text-gray-300">+ Klien</span>
                </button>
                <button onclick="document.getElementById('nav-jadwal').click(); setTimeout(() => document.getElementById('btn-tambah-jadwal').click(), 100);" class="flex flex-col items-center justify-center p-2 bg-white/5 hover:bg-white/10 rounded-xl transition-colors border border-white/5 group relative" title="Buat Jadwal Baru">
                    <i data-lucide="calendar-plus" class="w-5 h-5 text-amber-300 mb-1 group-hover:scale-110 transition-transform"></i>
                    <span class="text-[9px] font-bold text-gray-300">+ Jadwal</span>
                </button>
            </div>
        </div>

        <nav class="flex-1 overflow-y-auto p-3 space-y-4 custom-scroll">
            
            <!-- OPERASIONAL -->
            <div>
                <p class="text-[10px] text-green-400/70 font-black uppercase tracking-wider mb-1 px-3">Operasional & Dashboard</p>
                <div class="space-y-1">
                    <button id="nav-dashboard" title="Ringkasan Utama" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="layout-dashboard" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Ringkasan
                    </button>
                    <button id="nav-proyek" title="Manajemen Proyek Klien" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="briefcase" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Proyek Klien
                        <span id="badge-proyek" class="absolute right-3 bg-amber-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full hidden">0</span>
                    </button>
                    <button id="nav-jadwal" title="Jadwal Lapangan" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="calendar" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Jadwal Lapangan
                    </button>
                    <button id="nav-laporan" title="Laporan Pekerjaan Lapangan" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="clipboard-list" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Laporan Lapangan
                    </button>
                    <button id="nav-stok" title="Manajemen Stok & Alat" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="package" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Stok & Alat
                        <span id="badge-stok" class="absolute right-3 bg-rose-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full hidden">0</span>
                    </button>
                </div>
            </div>

            <!-- KEUANGAN -->
            <div>
                <p class="text-[10px] text-green-400/70 font-black uppercase tracking-wider mb-1 px-3">Keuangan</p>
                <div class="space-y-1">
                    <button id="nav-katalog" title="Katalog Harga Material (RAB)" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="tags" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Katalog RAB
                    </button>
                </div>
            </div>

            <!-- MARKETING / B2C -->
            <div>
                <p class="text-[10px] text-green-400/70 font-black uppercase tracking-wider mb-1 px-3">Marketing & B2C</p>
                <div class="space-y-1">
                    <button id="nav-paket" title="Daftar Layanan Customer" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="shopping-bag" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Katalog Layanan
                    </button>
                    <button id="nav-promo" title="Manajemen Banner Promo" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="image" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Banner Promo
                    </button>
                    <button id="nav-artikel" title="Testimoni Instagram" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="instagram" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Testimoni IG
                    </button>
                </div>
            </div>

            <!-- SISTEM & SUPPORT -->
            <div>
                <p class="text-[10px] text-green-400/70 font-black uppercase tracking-wider mb-1 px-3">Sistem & Support</p>
                <div class="space-y-1">
                    <button id="nav-database" title="Database Master Klien & Pekerja" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="users" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Database Master
                    </button>
                    <button id="nav-chat" title="Chat Konsultasi Customer" class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-xl text-green-100 hover:bg-green-800 hover:text-white transition-all text-left relative group">
                        <i data-lucide="message-square" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Chat Konsultasi
                        <span id="chat-badge" class="absolute right-3 bg-red-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full hidden">0</span>
                    </button>
                </div>
            </div>

        </nav>
        <div class="p-4 border-t border-green-800 bg-green-900/50">
            <button id="btn-logout" class="w-full flex items-center px-4 py-2 text-sm font-bold rounded-xl text-red-300 hover:bg-red-500/20 hover:text-red-200 transition-all text-left group">
                <i data-lucide="log-out" class="w-4 h-4 mr-3 opacity-70 group-hover:opacity-100"></i> Keluar
            </button>
        </div>
    </div>