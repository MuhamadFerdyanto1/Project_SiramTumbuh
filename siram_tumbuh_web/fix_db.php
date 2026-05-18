<?php
require 'vendor/autoload.php';
// Need to bootstrap CI4
define('FCPATH', __DIR__ . '/public/');
require 'app/Config/Paths.php';
$paths = new Config\Paths();
require $paths->systemDirectory . '/bootstrap.php';

$db = \Config\Database::connect();
$forge = \Config\Database::forge();

try {
    echo "Checking columns...\n";
    $fields = $db->getFieldNames('projects');
    if (!in_array('timeline', $fields)) {
        echo "Adding timeline column...\n";
        $forge->addColumn('projects', [
            'timeline' => [
                'type' => 'JSON',
                'null' => true,
                'after' => 'progress'
            ],
        ]);
        echo "Column added successfully.\n";
    } else {
        echo "Timeline column already exists.\n";
    }
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
