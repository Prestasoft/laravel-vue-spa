<?php

namespace App\Http\Controllers;

use App\Models\Votante;
use App\Models\GestionVotante;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class VotanteController extends Controller
{
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Votante::with(['gestiones' => function($q) {
            $q->orderBy('fecha', 'desc')->limit(1);
        }]);

        if (!$user->isAdmin()) {
            $query->delDirigente($user->id);
        }

        if ($request->has('colegio_id')) {
            $query->porColegio($request->colegio_id);
        }

        if ($request->has('mesa')) {
            $query->porMesa($request->mesa);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('cedula', 'LIKE', "%$search%")
                  ->orWhere('telefono', 'LIKE', "%$search%");
            });
        }

        if ($request->has('activo')) {
            $query->where('activo', $request->activo);
        } else {
            $query->activos();
        }

        $orderBy = $request->get('order_by', 'fecha_registro');
        $orderDir = $request->get('order_dir', 'desc');
        $query->orderBy($orderBy, $orderDir);

        $votantes = $query->paginate($request->get('per_page', 20));

        return response()->json($votantes);
    }

    public function store(Request $request)
    {
        $request->validate([
            'cedula' => 'required|string|max:11',
            'colegio_id' => 'nullable|integer',
            'mesa' => 'nullable|string|max:10',
            'telefono' => 'nullable|string|max:20',
            'direccion' => 'nullable|string',
            'observaciones' => 'nullable|string'
        ]);

        $user = auth()->user();

        $existente = Votante::where('cedula', $request->cedula)
            ->where('dirigente_id', $user->id)
            ->first();

        if ($existente) {
            return response()->json([
                'message' => 'Este votante ya está en tu lista'
            ], 422);
        }

        $padron = DB::connection('sqlsrv_db1')
            ->table('Padron')
            ->where('Cedula', $request->cedula)
            ->first();

        if (!$padron) {
            return response()->json([
                'message' => 'Cédula no encontrada en el padrón'
            ], 404);
        }

        $votante = Votante::create([
            'cedula' => $request->cedula,
            'dirigente_id' => $user->id,
            'colegio_id' => $request->colegio_id,
            'mesa' => $request->mesa,
            'telefono' => $request->telefono,
            'direccion' => $request->direccion,
            'observaciones' => $request->observaciones,
            'fecha_registro' => Carbon::now()
        ]);

        return response()->json([
            'message' => 'Votante agregado exitosamente',
            'votante' => $votante->load('gestiones')
        ], 201);
    }

    public function show($id)
    {
        $user = auth()->user();

        $votante = Votante::with('gestiones.dirigente')
            ->when(!$user->isAdmin(), function($q) use ($user) {
                $q->delDirigente($user->id);
            })
            ->findOrFail($id);

        return response()->json($votante);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'colegio_id' => 'nullable|integer',
            'mesa' => 'nullable|string|max:10',
            'telefono' => 'nullable|string|max:20',
            'direccion' => 'nullable|string',
            'observaciones' => 'nullable|string',
            'activo' => 'boolean'
        ]);

        $user = auth()->user();

        $votante = Votante::when(!$user->isAdmin(), function($q) use ($user) {
            $q->delDirigente($user->id);
        })->findOrFail($id);

        $votante->update($request->only([
            'colegio_id', 'mesa', 'telefono',
            'direccion', 'observaciones', 'activo'
        ]));

        return response()->json([
            'message' => 'Votante actualizado exitosamente',
            'votante' => $votante
        ]);
    }

    public function destroy($id)
    {
        $user = auth()->user();

        $votante = Votante::when(!$user->isAdmin(), function($q) use ($user) {
            $q->delDirigente($user->id);
        })->findOrFail($id);

        $votante->delete();

        return response()->json([
            'message' => 'Votante eliminado exitosamente'
        ]);
    }

    public function buscar($cedula)
    {
        $padron = DB::connection('sqlsrv_db1')
            ->table('Padron as p')
            ->leftJoin('Nacionalidad as nac', 'p.IdNacionalidad', '=', 'nac.ID')
            ->leftJoin('Sexo as sex', 'p.IdSexo', '=', 'sex.IdSexo')
            ->leftJoin('EstadoCivil as ec', 'p.IdEstadoCivil', '=', 'ec.Id')
            ->leftJoin('Colegio as co', 'p.IdColegio', '=', 'co.IDColegio')
            ->leftJoin('Municipio as mu', 'p.IdMunicipio', '=', 'mu.ID')
            ->leftJoin('Provincia as pro', 'mu.IDProvincia', '=', 'pro.ID')
            ->where('p.Cedula', $cedula)
            ->select([
                'p.*',
                'nac.Descripcion as nacionalidad',
                'sex.Descripcion as sexo',
                'ec.Descripcion as estado_civil',
                'co.Descripcion as colegio',
                'co.IDColegio as colegio_id',
                'mu.Descripcion as municipio',
                'pro.Descripcion as provincia',
            ])
            ->first();

        if (!$padron) {
            return response()->json([
                'message' => 'Cédula no encontrada en el padrón'
            ], 404);
        }

        $user = auth()->user();
        $yaRegistrado = Votante::where('cedula', $cedula)
            ->where('dirigente_id', $user->id)
            ->exists();

        return response()->json([
            'padron' => $padron,
            'ya_registrado' => $yaRegistrado
        ]);
    }

    public function estadisticas(Request $request)
    {
        $user = auth()->user();
        $query = Votante::query();

        if (!$user->isAdmin()) {
            $query->delDirigente($user->id);
        }

        $total = $query->count();
        $activos = (clone $query)->activos()->count();

        $porColegio = (clone $query)->activos()
            ->select('colegio_id', DB::raw('count(*) as total'))
            ->groupBy('colegio_id')
            ->get()
            ->map(function($item) {
                $colegio = DB::connection('sqlsrv_db1')
                    ->table('Colegio')
                    ->where('IDColegio', $item->colegio_id)
                    ->value('Descripcion');

                return [
                    'colegio_id' => $item->colegio_id,
                    'colegio' => $colegio,
                    'total' => $item->total
                ];
            });

        $porMesa = (clone $query)->activos()
            ->whereNotNull('mesa')
            ->select('mesa', DB::raw('count(*) as total'))
            ->groupBy('mesa')
            ->get();

        $ultimosDias = (clone $query)
            ->where('fecha_registro', '>=', Carbon::now()->subDays(30))
            ->select(DB::raw('CAST(fecha_registro AS DATE) as fecha'), DB::raw('count(*) as total'))
            ->groupBy(DB::raw('CAST(fecha_registro AS DATE)'))
            ->orderBy('fecha')
            ->get();

        return response()->json([
            'total' => $total,
            'activos' => $activos,
            'inactivos' => $total - $activos,
            'por_colegio' => $porColegio,
            'por_mesa' => $porMesa,
            'ultimos_30_dias' => $ultimosDias
        ]);
    }

    public function agregarGestion(Request $request, $id)
    {
        $request->validate([
            'tipo_gestion' => 'required|string|in:llamada,visita,mensaje,otro',
            'nota' => 'nullable|string'
        ]);

        $user = auth()->user();

        $votante = Votante::when(!$user->isAdmin(), function($q) use ($user) {
            $q->delDirigente($user->id);
        })->findOrFail($id);

        $gestion = GestionVotante::create([
            'votante_id' => $votante->id,
            'dirigente_id' => $user->id,
            'tipo_gestion' => $request->tipo_gestion,
            'nota' => $request->nota,
            'fecha' => Carbon::now()
        ]);

        return response()->json([
            'message' => 'Gestión agregada exitosamente',
            'gestion' => $gestion
        ], 201);
    }

    public function exportar(Request $request)
    {
        $user = auth()->user();
        $formato = $request->get('formato', 'excel');

        $votantes = Votante::with('gestiones')
            ->when(!$user->isAdmin(), function($q) use ($user) {
                $q->delDirigente($user->id);
            })
            ->activos()
            ->get();

        if ($formato === 'json') {
            return response()->json($votantes);
        }

        $csv = "Cédula,Nombres,Apellidos,Teléfono,Colegio,Mesa,Dirección,Observaciones\n";

        foreach ($votantes as $votante) {
            $padron = $votante->padron_data;
            $csv .= sprintf(
                "%s,%s,%s,%s,%s,%s,%s,%s\n",
                $votante->cedula,
                $padron->Nombres ?? '',
                ($padron->Apellido1 ?? '') . ' ' . ($padron->Apellido2 ?? ''),
                $votante->telefono ?? '',
                $votante->colegio_nombre ?? '',
                $votante->mesa ?? '',
                $votante->direccion ?? '',
                $votante->observaciones ?? ''
            );
        }

        return response($csv, 200, [
            'Content-Type' => 'text/csv',
            'Content-Disposition' => 'attachment; filename="votantes.csv"'
        ]);
    }
}