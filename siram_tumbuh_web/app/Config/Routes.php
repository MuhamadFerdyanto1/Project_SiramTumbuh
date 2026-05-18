<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');

// Route Darurat Setup DB Chat
$routes->get('setup-db', function() {
    $db = \Config\Database::connect();
    $forge = \Config\Database::forge();

    $fields = [
        'id' => ['type' => 'INT', 'constraint' => 11, 'unsigned' => true, 'auto_increment' => true],
        'project_id' => ['type' => 'INT', 'constraint' => 11, 'unsigned' => true, 'null' => true],
        'customer_name' => ['type' => 'VARCHAR', 'constraint' => 100, 'null' => true],
        'sender_role' => ['type' => 'ENUM', 'constraint' => ['customer', 'admin', 'bot'], 'default' => 'customer'],
        'message' => ['type' => 'TEXT'],
        'is_read' => ['type' => 'TINYINT', 'constraint' => 1, 'default' => 0],
        'created_at' => ['type' => 'DATETIME', 'null' => true],
        'updated_at' => ['type' => 'DATETIME', 'null' => true],
    ];

    $forge->addField($fields);
    $forge->addKey('id', true);
    
    if ($forge->createTable('messages', true)) {
        return "<h1>Sukses! Tabel 'messages' berhasil dibuat.</h1><p>Silakan coba chat kembali.</p>";
    } else {
        return "<h1>Gagal membuat tabel.</h1>";
    }
});

// Catch-all OPTIONS for CORS preflight
$routes->options('(:any)', static function () {
    $response = response();
    $response->setStatusCode(200);
    $response->setHeader('Access-Control-Allow-Origin', '*');
    $response->setHeader('Access-Control-Allow-Headers', 'X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method, Authorization, X-Worker-ID');
    $response->setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
    return $response;
});

$routes->group('api', ['namespace' => 'App\Controllers\Api'], static function ($routes) {
    // Existing routes
    $routes->resource('projects');
    $routes->resource('catalogs');
    $routes->resource('inventory');
    $routes->resource('testimonials');
    
    // Chat API
    $routes->get('chat', 'Chat::index');
    $routes->post('chat/send', 'Chat::send');
    $routes->get('chat/unread-count', 'Chat::unreadCount');
    $routes->post('chat/mark-as-read', 'Chat::markAsRead');
    
    // File upload
    $routes->post('upload', 'Upload::index');
    $routes->get('uploads/(:any)', 'Upload::serve/$1');

    // Worker App - Auth
    $routes->post('auth/login', 'Auth::login');
    $routes->post('auth/register_worker', 'Auth::register_worker');
    $routes->post('auth/logout', 'Auth::logout');

    // Worker App - Assignments
    $routes->resource('assignments');
    $routes->post('assignments/(:num)/progress', 'Assignments::submitProgress/$1');
    $routes->get('assignments/(:num)/progress', 'Assignments::getProgress/$1');

    // Worker App - Attendance
    $routes->post('attendance/clock-in', 'Attendance::clockIn');
    $routes->post('attendance/clock-out', 'Attendance::clockOut');
    $routes->get('attendance/today', 'Attendance::getToday');
    $routes->get('attendance', 'Attendance::index');

    // Worker App - Material Requests
    $routes->resource('material-requests');
    $routes->post('material-requests/(:num)/approve', 'MaterialRequests::approve/$1');
    $routes->post('material-requests/(:num)/reject', 'MaterialRequests::reject/$1');
});
