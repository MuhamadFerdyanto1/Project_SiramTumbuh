<div id="database-content" class="hidden p-8 fade-in flex-col">
                <div class="flex justify-between items-center mb-8">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Database Master</h1>
                        <p class="text-gray-400 text-sm">Kelola informasi Klien dan Tim Pekerja Anda</p>
                    </div>
                    <div class="flex items-center space-x-3">
                        <select id="db-selector" class="border border-gray-200 bg-white rounded-xl p-2.5 outline-none focus:ring-2 focus:ring-blue-500 font-bold text-gray-700 cursor-pointer text-sm">
                            <option value="klien">Data Klien</option>
                            <option value="pekerja">Data Pekerja</option>
                        </select>
                        <button id="btn-tambah-db" class="bg-blue-600 text-white px-5 py-2.5 rounded-xl font-bold shadow-lg hover:bg-blue-700 transition flex items-center text-sm">
                            <i data-lucide="plus" class="mr-2 w-4 h-4"></i> Tambah Data
                        </button>
                    </div>
                </div>
                
                <!-- Tampilan Klien -->
                <div id="view-db-klien" class="bg-white rounded-3xl shadow-sm overflow-hidden border border-gray-100">
                    <table class="w-full text-left">
                        <thead class="bg-gray-50 border-b text-gray-400 text-xs uppercase font-black">
                            <tr class="p-4"><th class="p-4 text-gray-800">Nama Klien</th><th class="text-gray-800">Email</th><th class="text-gray-800">No. WhatsApp</th><th class="text-gray-800">Alamat Utama</th><th class="text-right p-4 text-gray-800">Aksi</th></tr>
                        </thead>
                        <tbody id="klien-table-body"></tbody>
                    </table>
                </div>

                <!-- Tampilan Pekerja -->
                <div id="view-db-pekerja" class="hidden bg-white rounded-3xl shadow-sm overflow-hidden border border-gray-100">
                    <table class="w-full text-left">
                        <thead class="bg-gray-50 border-b text-gray-400 text-xs uppercase font-black">
                            <tr class="p-4"><th class="p-4 text-gray-800">Nama Pekerja</th><th class="text-gray-800">Posisi / Keahlian</th><th class="text-gray-800">Kontak (HP)</th><th class="text-right p-4 text-gray-800">Aksi</th></tr>
                        </thead>
                        <tbody id="pekerja-table-body"></tbody>
                    </table>
                </div>
            </div>