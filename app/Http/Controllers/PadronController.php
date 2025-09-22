<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Padron;
use App\Models\Foto;
use App\Models\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Carbon;

class PadronController extends Controller
{
    public function search(Request $request)
    {
        $startTime = microtime(true);

        $request->validate([
            'cedula' => 'required|string|max:11',
        ]);

        $cedula = $request->input('cedula');
        $user = auth()->user();

        try {
            $padron = DB::connection('sqlsrv_db1')
                ->table('Padron as p')
                ->leftJoin('Nacionalidad as nac', 'p.IdNacionalidad', '=', 'nac.ID')
                ->leftJoin('Sexo as sex', 'p.IdSexo', '=', 'sex.IdSexo')
                ->leftJoin('EstadoCivil as ec', 'p.IdEstadoCivil', '=', 'ec.Id')
                ->leftJoin('Colegio as co', 'p.IdColegio', '=', 'co.IDColegio')
                ->leftJoin('Municipio as mu', 'p.IdMunicipio', '=', 'mu.ID')
                ->leftJoin('Provincia as pro', 'mu.IDProvincia', '=', 'pro.ID')
                ->leftJoin('Zona as zo', 'pro.Zona', '=', 'zo.ID')
                ->where('p.Cedula', $cedula)
                ->select([
                    'p.*',
                    'nac.Descripcion as nacionalidad',
                    'sex.Descripcion as sexo',
                    'ec.Descripcion as estado_civil',
                    'co.Descripcion as colegio',
                    'mu.Descripcion as municipio',
                    'pro.Descripcion as provincia',
                    'zo.Descripcion as zona',
                ])
                ->first();

            $foto = Foto::where('Cedula', $cedula)->first();
            
            $duration = round((microtime(true) - $startTime) * 1000);

            $this->logSearch(
                $user ? $user->id : null,
                $cedula,
                $request->ip(),
                $request->userAgent(),
                $padron ? 1 : 0,
                $duration
            );

            if (!$padron) {
                return response()->json(['message' => 'No se encontró el registro en el padrón'], 404);
            }

            return response()->json([
                'padron' => $padron,
                'foto' => $foto ? ['Cedula' => $foto->Cedula, 'Imagen' => base64_encode($foto->Imagen)] : null,
            ]);

        } catch (\Exception $e) {
            $this->logSearch(
                $user ? $user->id : null,
                $cedula,
                $request->ip(),
                $request->userAgent(),
                0,
                round((microtime(true) - $startTime) * 1000)
            );
            
            throw $e;
        }
    }

    protected function logSearch($userId, $searchQuery, $ipAddress, $deviceInfo, $resultCount, $durationMs)
    {
        try {
            Log::create([
                'UserID' => $userId,
                'SearchQuery' => $searchQuery,
                'SearchDate' => Carbon::now(),
                'IPAddress' => $ipAddress,
                'DeviceInfo' => substr($deviceInfo, 0, 255),
                'SearchResultCount' => $resultCount,
                'DurationMs' => $durationMs
            ]);
        } catch (\Exception $e) {
            \Log::error('Error al registrar log de búsqueda: ' . $e->getMessage());
        }
    }

    public function dniPhoto(Request $request)
    {
        $request->validate([
            'cedulas' => 'required|array',
            'cedulas.*' => 'string',
        ]);

        $fotos = DB::connection('sqlsrv_db2')
        ->table(DB::raw("
            (SELECT Cedula AS gst_no FROM (
                VALUES " . implode(',', array_map(fn($cedula) => "('$cedula')", $request->cedulas)) . "
            ) AS Cedulas(Cedula)) AS todas_cedulas
        "))
        ->leftJoin('FOTOS_PRM_PRM', 'todas_cedulas.gst_no', '=', 'FOTOS_PRM_PRM.Cedula')
        ->select(
            'todas_cedulas.gst_no',
            DB::raw("
                CASE
                    WHEN FOTOS_PRM_PRM.Imagen IS NOT NULL THEN CAST('data:image/jpeg;base64,' AS varchar) +
                        CAST('' AS xml).value('xs:base64Binary(sql:column(\"FOTOS_PRM_PRM.Imagen\"))', 'varchar(MAX)')
                    ELSE NULL
                END AS imagen
            ")
        )
        ->get();

        return response()->json($fotos);
    }
}

