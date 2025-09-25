<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ForceHttps
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // Solo forzar HTTPS si no estamos en localhost y no es ya HTTPS
        if (!$request->secure() && $request->getHost() !== 'localhost') {
            return redirect()->secure($request->getRequestUri());
        }

        return $next($request);
    }
}