<?php

namespace App\Http\Controllers;

use App\Models\Log;
use Illuminate\Http\Request;

class LogController extends Controller
{
    public function index(Request $request)
    {
        $perPage = $request->input('per_page', 15);
        $search = $request->input('search');

        $query = Log::with(['user' => function($query) {
            $query->select('id', 'name', 'email');
        }])
        ->orderBy('SearchDate', 'desc');

        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('SearchQuery', 'like', "%{$search}%")
                  ->orWhere('IPAddress', 'like', "%{$search}%")
                  ->orWhereHas('user', function($q) use ($search) {
                      $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                  });
            });
        }

        return $query->paginate($perPage);
    }
}
