<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateVotantesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::connection('sqlsrv_db1')->create('votantes', function (Blueprint $table) {
            $table->id();
            $table->string('cedula', 11);
            $table->unsignedBigInteger('dirigente_id');
            $table->unsignedBigInteger('colegio_id')->nullable();
            $table->string('mesa', 10)->nullable();
            $table->string('telefono', 20)->nullable();
            $table->text('direccion')->nullable();
            $table->text('observaciones')->nullable();
            $table->timestamp('fecha_registro')->useCurrent();
            $table->boolean('activo')->default(true);

            $table->foreign('dirigente_id')->references('id')->on('users')->onDelete('cascade');
            $table->unique(['cedula', 'dirigente_id']);
            $table->index(['dirigente_id', 'activo']);
            $table->index('colegio_id');
            $table->index('mesa');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::connection('sqlsrv_db1')->dropIfExists('votantes');
    }
}
