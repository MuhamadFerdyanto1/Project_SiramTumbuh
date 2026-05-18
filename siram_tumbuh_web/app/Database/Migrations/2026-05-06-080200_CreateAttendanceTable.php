<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class CreateAttendanceTable extends Migration
{
    public function up()
    {
        $this->forge->addField([
            'id' => [
                'type'           => 'INT',
                'constraint'     => 11,
                'unsigned'       => true,
                'auto_increment' => true,
            ],
            'worker_id' => [
                'type'       => 'INT',
                'constraint' => 11,
                'unsigned'   => true,
            ],
            'clock_in_time' => [
                'type' => 'DATETIME',
            ],
            'clock_in_location' => [
                'type'       => 'JSON',
                'null'       => true,
                'comment'    => 'JSON: {latitude, longitude, address}',
            ],
            'clock_in_photo' => [
                'type'       => 'VARCHAR',
                'constraint' => '255',
                'null'       => true,
                'comment'    => 'File path/URL to selfie photo',
            ],
            'clock_out_time' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
            'clock_out_location' => [
                'type'       => 'JSON',
                'null'       => true,
                'comment'    => 'JSON: {latitude, longitude, address}',
            ],
            'clock_out_photo' => [
                'type'       => 'VARCHAR',
                'constraint' => '255',
                'null'       => true,
                'comment'    => 'File path/URL to selfie photo',
            ],
            'status' => [
                'type'       => 'ENUM',
                'constraint' => ['clock_in', 'clocked_out'],
                'default'    => 'clock_in',
            ],
            'created_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
            'updated_at' => [
                'type' => 'DATETIME',
                'null' => true,
            ],
        ]);
        $this->forge->addKey('id', true);
        $this->forge->addForeignKey('worker_id', 'users', 'id', '', 'CASCADE');
        $this->forge->addKey('clock_in_time');
        $this->forge->createTable('attendance');
    }

    public function down()
    {
        $this->forge->dropTable('attendance');
    }
}
