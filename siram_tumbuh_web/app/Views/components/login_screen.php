<!-- LAYAR LOGIN -->
    <div id="login-screen" class="fixed inset-0 bg-green-900 z-50 flex flex-col items-center justify-center p-4 print-hidden">
        <div class="w-full max-w-md bg-white rounded-3xl shadow-2xl overflow-hidden">
            <div class="p-8 text-center bg-green-50 border-b border-green-100">
                <i data-lucide="leaf" class="w-12 h-12 text-green-600 mx-auto mb-3"></i>
                <h1 class="text-2xl font-black text-green-900 leading-tight">Mitra Rizki Admin</h1>
                <p class="text-green-600 text-sm font-medium">Sistem Manajemen Landscape & Inventory</p>
            </div>
            
            <div class="p-8 space-y-5">
                <div id="login-error" class="hidden p-3 bg-red-50 border border-red-100 text-red-600 text-xs font-bold rounded-xl flex items-center">
                    <i data-lucide="alert-circle" class="w-4 h-4 mr-2"></i>
                    <span id="error-msg">Email atau password salah!</span>
                </div>
                <div>
                    <label class="block text-xs uppercase font-black text-gray-400 mb-1 ml-1">Email Admin</label>
                    <input type="email" id="login-email" class="w-full bg-gray-50 border border-gray-200 rounded-2xl py-3 px-4 outline-none focus:ring-2 focus:ring-green-500 transition-all" placeholder="admin@mitrarizki.com">
                </div>
                <div>
                    <label class="block text-xs uppercase font-black text-gray-400 mb-1 ml-1">Password</label>
                    <input type="password" id="login-pass" class="w-full bg-gray-50 border border-gray-200 rounded-2xl py-3 px-4 outline-none focus:ring-2 focus:ring-green-500 transition-all" placeholder="••••••••">
                </div>
                <button id="btn-do-login" class="w-full bg-green-600 hover:bg-green-700 text-white py-4 rounded-2xl font-black shadow-lg transition-all flex justify-center items-center group">
                    <span>Masuk ke Panel</span>
                    <i data-lucide="arrow-right" class="ml-2 w-5 h-5 group-hover:translate-x-1 transition-transform"></i>
                </button>
            </div>
        </div>
    </div>