<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class CreateProgressUpdatesTable extends Migration
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
            'assignment_id' => [
                'type'       => 'INT',
                'constraint' => 11,
                'unsigned'   => true,
            ],
            'progress_percentage' => [
                'type'       => 'DECIMAL',
                'constraint' => '5,2',
                'comment'    => '0.00 to 100.00',
            ],
            'notes' => [
                'type'       => 'TEXT',
                'null'       => true,
                'comment'    => 'Laporan harian / catatan progres',
            ],
            'photos' => [
                'type'       => 'JSON',
                'null'       => true,
                'comment'    => 'Array: [{photo_url, timestamp, latitude, longitude}, ...]',
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
        $this->forge->addForeignKey('assignment_id', 'assignments', 'id', '', 'CASCADE');
        $this->forge->createTable('progress_updates');
    }

    public function down()
    {
        $this->forge->dropTable('progress_updates');
    }
}
