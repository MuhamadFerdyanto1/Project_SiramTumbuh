<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $title ?? 'Admin Mitra Rizki' ?></title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Ikon Lucide -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="bg-gray-100 font-sans flex h-screen overflow-hidden relative text-gray-800">

    <?= $this->include('components/login_screen') ?>

    <?= $this->include('components/sidebar') ?>

    <!-- MAIN CONTENT WRAPPER -->
    <main class="flex-1 flex flex-col relative bg-gray-100 overflow-hidden">
        
        <?= $this->include('components/topbar') ?>

        <!-- CONTENT SCROLL AREA -->
        <div class="flex-1 overflow-y-auto w-full relative">
            <?= $this->renderSection('content') ?>
        </div>
    </main>

    <?= $this->include('components/modals') ?>

    <script type="module" src="/assets/js/app.js"></script>
</body>
</html>