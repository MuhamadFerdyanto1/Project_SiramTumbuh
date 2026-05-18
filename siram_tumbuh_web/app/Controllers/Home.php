<?php

namespace App\Controllers;

class Home extends BaseController
{
    public function index()
    {
        // Akan memuat file view bernama 'dashboard.php'
        return view('dashboard');
    }
}
