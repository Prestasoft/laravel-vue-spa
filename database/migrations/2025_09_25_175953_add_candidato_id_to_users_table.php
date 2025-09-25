<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

class AddCandidatoIdToUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->unsignedBigInteger('candidato_id')->nullable()->after('type');
            $table->index('candidato_id');
        });

        // Agregar foreign key sin cascade para evitar ciclos en SQL Server
        DB::statement('ALTER TABLE users ADD CONSTRAINT users_candidato_id_foreign FOREIGN KEY (candidato_id) REFERENCES users (id) ON DELETE NO ACTION');
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        DB::statement('ALTER TABLE users DROP CONSTRAINT users_candidato_id_foreign');
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('candidato_id');
        });
    }
}
