<div id="paket-content" class="hidden p-8 fade-in flex-col">
    <div class="flex justify-between items-center mb-8">
        <div>
            <h1 class="text-2xl font-bold text-gray-800">Manajemen Paket Layanan</h1>
            <p class="text-gray-500 text-sm mt-1">Katalog paket layanan yang ditampilkan pada aplikasi customer B2C.</p>
        </div>
        <button id="btn-tambah-paket" class="bg-green-600 text-white px-6 py-3 rounded-xl font-bold shadow hover:bg-green-700 transition flex items-center">
            <i data-lucide="plus" class="w-5 h-5 mr-2"></i> Tambah Paket
        </button>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" id="paket-list-container">
        <!-- Paket Cards will be rendered here -->
    </div>
</div>
