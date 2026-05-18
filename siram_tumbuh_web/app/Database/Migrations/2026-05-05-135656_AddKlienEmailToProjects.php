<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddKlienEmailToProjects extends Migration
{
    public function up()
    {
        $this->forge->addColumn('projects', [
            'klien_email' => [
                'type'       => 'VARCHAR',
                'constraint' => 255,
                'null'       => true,
                'default'    => null,
                'after'      => 'telepon',
            ],
            'progress' => [
                'type'       => 'DECIMAL',
                'constraint' => '5,2',
                'null'       => true,
                'default'    => 0.00,
                'after'      => 'klien_email',
            ],
        ]);
    }

    public function down()
    {
        $this->forge->dropColumn('projects', ['klien_email', 'progress']);
    }
}
