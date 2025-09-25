<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddGpsFieldsToVotantesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('votantes', function (Blueprint $table) {
            $table->decimal('latitud', 10, 8)->nullable()->after('direccion');
            $table->decimal('longitud', 11, 8)->nullable()->after('latitud');
            $table->string('direccion_gps', 500)->nullable()->after('longitud');
            $table->timestamp('gps_capturado_en')->nullable()->after('direccion_gps');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('votantes', function (Blueprint $table) {
            $table->dropColumn(['latitud', 'longitud', 'direccion_gps', 'gps_capturado_en']);
        });
    }
}
