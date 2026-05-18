<div id="jadwal-content" class="hidden p-8 fade-in flex-col">
                <div class="flex justify-between items-center mb-8">
                    <div><h1 class="text-2xl font-bold">Jadwal Penugasan Proyek</h1><p class="text-gray-400 text-sm">Atur jadwal survei, pengerjaan, dan perawatan untuk tim lapangan.</p></div>
                    <button id="btn-tambah-jadwal" class="bg-blue-600 text-white px-6 py-2 rounded-xl font-bold shadow-lg hover:bg-blue-700 transition flex items-center"><i data-lucide="calendar-plus" class="mr-2"></i> Jadwal Baru</button>
                </div>
                <div class="bg-white rounded-3xl shadow-sm border overflow-hidden border-gray-100">
                    <table class="w-full text-left">
                        <thead class="bg-gray-50 border-b text-gray-400 text-xs uppercase font-black">
                            <tr class="p-4"><th class="p-4">Tanggal</th><th>Pekerjaan & Proyek</th><th>Tim Bertugas</th><th>Status</th><th class="text-right p-4">Aksi</th></tr>
                        </thead>
                        <tbody id="jadwal-table-body"></tbody>
                    </table>
                </div>
            </div>