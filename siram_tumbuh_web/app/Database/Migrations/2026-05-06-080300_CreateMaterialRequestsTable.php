<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class CreateMaterialRequestsTable extends Migration
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
            'assignment_id' => [
                'type'       => 'INT',
                'constraint' => 11,
                'unsigned'   => true,
                'null'       => true,
            ],
            'items' => [
                'type'       => 'JSON',
                'comment'    => 'Array: [{catalog_id, quantity_used, reason}, ...]',
            ],
            'requested_date' => [
                'type' => 'DATE',
            ],
            'status' => [
                'type'       => 'ENUM',
                'constraint' => ['pending', 'approved', 'rejected'],
                'default'    => 'pending',
            ],
            'approved_by' => [
                'type'       => 'INT',
                'constraint' => 11,
                'unsigned'   => true,
                'null'       => true,
                'comment'    => 'User ID of approver (admin/supervisor)',
            ],
            'notes' => [
                'type'       => 'TEXT',
                'null'       => true,
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
        $this->forge->addForeignKey('assignment_id', 'assignments', 'id', '', 'SET NULL');
        $this->forge->createTable('material_requests');
    }

    public function down()
    {
        $this->forge->dropTable('material_requests');
    }
}
