<?= $this->extend('layouts/admin') ?>

<?= $this->section('content') ?>

    <!-- DASHBOARD -->
    <?= $this->include('sections/dashboard_content') ?>

    <!-- DATABASE MASTER -->
    <?= $this->include('sections/database_content') ?>

    <!-- PROYEK -->
    <?= $this->include('sections/main_content') ?>

    <!-- JADWAL -->
    <?= $this->include('sections/jadwal_content') ?>

    <!-- LAPORAN -->
    <?= $this->include('sections/laporan_content') ?>

    <!-- STOK -->
    <?= $this->include('sections/stok_content') ?>

    <!-- KATALOG -->
    <?= $this->include('sections/katalog_content') ?>

    <!-- PAKET LAYANAN (B2C) -->
    <?= $this->include('sections/paket_content') ?>

    <!-- ARTIKEL INSPIRASI (B2C) -->
    <?= $this->include('sections/artikel_content') ?>

    <!-- PROMO BANNER (B2C) -->
    <?= $this->include('sections/promo_content') ?>

    <!-- CHAT KONSULTASI -->
    <?= $this->include('sections/chat_content') ?>

    <!-- DETAIL -->
    <?= $this->include('sections/detail_content') ?>

    <!-- PRINT -->
    <?= $this->include('sections/print_content') ?>

<?= $this->endSection() ?>