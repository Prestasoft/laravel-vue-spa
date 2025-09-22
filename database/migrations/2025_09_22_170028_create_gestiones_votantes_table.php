<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateGestionesVotantesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::connection('sqlsrv_db1')->create('gestiones_votantes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('votante_id');
            $table->unsignedBigInteger('dirigente_id');
            $table->string('tipo_gestion', 50);
            $table->text('nota')->nullable();
            $table->timestamp('fecha')->useCurrent();

            $table->foreign('votante_id')->references('id')->on('votantes')->onDelete('cascade');
            $table->foreign('dirigente_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['votante_id', 'fecha']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::connection('sqlsrv_db1')->dropIfExists('gestiones_votantes');
    }
}
