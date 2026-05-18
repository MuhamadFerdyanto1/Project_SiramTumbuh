<div id="dashboard-content" class="hidden p-8 fade-in flex-col">
                <div class="mb-8">
                    <h1 class="text-2xl font-bold">Ringkasan Operasional</h1>
                    <p class="text-sm text-gray-400">Statistik real-time dan analisis tren pengerjaan taman.</p>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-6 mb-8 text-white font-black">
                    <div class="bg-purple-600 p-6 rounded-[2rem] shadow-xl relative overflow-hidden group">
                        <div class="absolute -right-4 -bottom-4 opacity-10"><i data-lucide="users" class="w-24 h-24"></i></div>
                        <p class="text-[10px] uppercase opacity-70 mb-1 tracking-widest">Total Klien</p>
                        <p class="text-4xl" id="stat-klien">0</p>
                    </div>
                    <div class="bg-blue-600 p-6 rounded-[2rem] shadow-xl relative overflow-hidden group">
                        <div class="absolute -right-4 -bottom-4 opacity-10"><i data-lucide="folder" class="w-24 h-24"></i></div>
                        <p class="text-[10px] uppercase opacity-70 mb-1 tracking-widest">Total Proyek</p>
                        <p class="text-4xl" id="stat-total">0</p>
                    </div>
                    <div class="bg-emerald-600 p-6 rounded-[2rem] shadow-xl relative overflow-hidden group">
                        <div class="absolute -right-4 -bottom-4 opacity-10"><i data-lucide="banknote" class="w-24 h-24"></i></div>
                        <p class="text-[10px] uppercase opacity-70 mb-1 tracking-widest">Estimasi Omzet</p>
                        <p class="text-2xl" id="stat-nilai">Rp 0</p>
                    </div>
                    <div class="bg-amber-500 p-6 rounded-[2rem] shadow-xl relative overflow-hidden group">
                        <div class="absolute -right-4 -bottom-4 opacity-10"><i data-lucide="clock" class="w-24 h-24"></i></div>
                        <p class="text-[10px] uppercase opacity-70 mb-1 tracking-widest">On-Progress</p>
                        <p class="text-4xl" id="stat-aktif">0</p>
                    </div>
                    <div class="bg-rose-600 p-6 rounded-[2rem] shadow-xl relative overflow-hidden group">
                        <div class="absolute -right-4 -bottom-4 opacity-10"><i data-lucide="alert-triangle" class="w-24 h-24"></i></div>
                        <p class="text-[10px] uppercase opacity-70 mb-1 tracking-widest">Stok Menipis</p>
                        <p class="text-4xl" id="stat-stok-low">0</p>
                    </div>
                </div>

                <!-- SPK OTOMATIS -->
                <div class="bg-gradient-to-br from-indigo-900 to-blue-900 p-8 rounded-[2.5rem] shadow-xl text-white mb-8 relative overflow-hidden">
                    <div class="absolute -right-10 -top-10 opacity-5 blur-xl w-64 h-64 bg-white rounded-full"></div>
                    <div class="flex items-center mb-6 relative z-10">
                        <div class="p-3 bg-white/10 rounded-2xl mr-4"><i data-lucide="brain-circuit" class="w-6 h-6 text-indigo-200"></i></div>
                        <div>
                            <h2 class="font-black text-xl tracking-tight">Analisa SPK Otomatis</h2>
                            <p class="text-xs text-indigo-200 mt-1 font-medium">Sistem membaca data operasional Anda dan memberikan rekomendasi cerdas secara real-time.</p>
                        </div>
                    </div>
                    <div id="automated-spk-insights" class="grid grid-cols-1 md:grid-cols-2 gap-4 relative z-10">
                        <p class="text-sm opacity-50 italic px-4">Memproses data dari database...</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    <!-- Kolom Kiri -->
                    <div class="lg:col-span-2 space-y-8 flex flex-col">
                        
                        <!-- Informasi Kritis -->
                        <div class="bg-rose-50 p-6 rounded-[2rem] shadow-sm border border-rose-100 relative overflow-hidden">
                            <div class="absolute -right-4 -top-4 opacity-5"><i data-lucide="alert-triangle" class="w-32 h-32 text-rose-500"></i></div>
                            <h2 class="font-black text-rose-600 flex items-center text-sm mb-4 relative z-10"><i data-lucide="shopping-cart" class="mr-2 w-4 h-4"></i> Re-Stock Segera</h2>
                            <div id="low-stock-list" class="space-y-3 relative z-10"></div>
                        </div>

                        <!-- Chart -->
                        <div class="bg-white p-8 rounded-[2.5rem] shadow-sm flex flex-col border border-gray-100">
                            <div class="flex justify-between items-center mb-10"><h2 class="font-black flex items-center tracking-tight"><i data-lucide="trending-up" class="mr-3 text-emerald-500"></i> Tren Proyek Bulanan</h2></div>
                            <div id="chart-container" class="w-full h-64 mb-4 px-4 relative"></div>
                        </div>

                    </div>

                    <!-- Kolom Kanan -->
                    <div class="space-y-8 flex flex-col">
                        <!-- Widget Jadwal Terdekat -->
                        <div class="bg-white p-8 rounded-[2.5rem] shadow-sm border border-gray-100 flex-1">
                            <div class="flex justify-between items-center mb-6">
                                <h2 class="font-black flex items-center tracking-tight text-gray-800"><i data-lucide="calendar-clock" class="mr-3 text-blue-500"></i> Jadwal Terdekat</h2>
                                <button onclick="document.getElementById('nav-jadwal').click()" class="text-xs font-bold text-blue-500 hover:text-blue-700 bg-blue-50 px-3 py-1.5 rounded-lg transition-colors">Lihat</button>
                            </div>
                            <div id="dashboard-jadwal-list" class="space-y-3">
                                <p class="text-xs text-gray-400 italic">Memuat jadwal...</p>
                            </div>
                        </div>
                        
                        <!-- Klien Baru -->
                        <div class="bg-white p-6 rounded-[2rem] shadow-sm border border-gray-100">
                            <h2 class="font-black flex items-center text-sm mb-4 text-gray-700"><i data-lucide="user-plus" class="mr-2 w-4 h-4 text-blue-500"></i> Klien Baru Terdaftar</h2>
                            <div id="dashboard-recent-klien" class="space-y-3 max-h-[250px] overflow-y-auto custom-scroll pr-2"></div>
                        </div>
                    </div>
                </div>
            </div>