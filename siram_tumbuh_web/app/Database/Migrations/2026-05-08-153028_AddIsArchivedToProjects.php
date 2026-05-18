<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddIsArchivedToProjects extends Migration
{
    public function up()
    {
        $this->forge->addColumn('projects', [
            'is_archived' => [
                'type'       => 'TINYINT',
                'constraint' => 1,
                'default'    => 0,
                'after'      => 'status'
            ],
        ]);
    }

    public function down()
    {
        $this->forge->dropColumn('projects', 'is_archived');
    }
}
