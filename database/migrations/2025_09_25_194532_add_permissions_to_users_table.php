<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddPermissionsToUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            // Permisos para votantes
            $table->boolean('can_view_votantes')->default(true)->after('candidato_id');
            $table->boolean('can_add_votantes')->default(true)->after('can_view_votantes');
            $table->boolean('can_edit_votantes')->default(true)->after('can_add_votantes');
            $table->boolean('can_delete_votantes')->default(true)->after('can_edit_votantes');

            // Permisos para usuarios
            $table->boolean('can_view_users')->default(false)->after('can_delete_votantes');
            $table->boolean('can_add_users')->default(false)->after('can_view_users');
            $table->boolean('can_edit_users')->default(false)->after('can_add_users');
            $table->boolean('can_delete_users')->default(false)->after('can_edit_users');

            // Permisos para reportes
            $table->boolean('can_view_reports')->default(false)->after('can_delete_users');
            $table->boolean('can_export_data')->default(false)->after('can_view_reports');

            // Permisos especiales
            $table->boolean('can_view_all_votantes')->default(false)->after('can_export_data');
            $table->boolean('can_manage_dirigentes')->default(false)->after('can_view_all_votantes');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'can_view_votantes',
                'can_add_votantes',
                'can_edit_votantes',
                'can_delete_votantes',
                'can_view_users',
                'can_add_users',
                'can_edit_users',
                'can_delete_users',
                'can_view_reports',
                'can_export_data',
                'can_view_all_votantes',
                'can_manage_dirigentes'
            ]);
        });
    }
}
