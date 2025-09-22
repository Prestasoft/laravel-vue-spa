<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Log extends Model
{
    use HasFactory;

    protected $connection = 'sqlsrv_db1';
    protected $table = 'UserSearchLogs';

    protected $fillable = [
        'UserID', 
        'SearchQuery', 
        'SearchDate', 
        'IPAddress',
        'DeviceInfo',
        'SearchResultCount',
        'DurationMs'
    ];

    protected $dates = ['SearchDate'];

    protected $appends = [
        'formatted_search_date',
        'duration_seconds',
    ];
        
    public $timestamps = false;

    public function user()
    {
        return $this->belongsTo(User::class, 'UserID', 'id');
    }

    public function getFormattedSearchDateAttribute()
    {
        return $this->SearchDate->format('d/m/Y H:i:s');
    }

    public function getDurationSecondsAttribute()
    {
        return $this->DurationMs / 1000;
    }
}
