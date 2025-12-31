<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Reverb Server
    |--------------------------------------------------------------------------
    |
    | This option controls the default Reverb server that will be used by the
    | framework when broadcasting events. You may set this to any of the
    | connections defined in the "connections" array below.
    |
    */

    'default' => env('REVERB_APP_ID', 'reverb'),

    /*
    |--------------------------------------------------------------------------
    | Reverb Servers
    |--------------------------------------------------------------------------
    |
    | Here you may define all of the Reverb servers that will be used to broadcast
    | events to other systems or over websockets. Samples of each available
    | type of connection are provided inside this array.
    |
    */

    'apps' => [
        'reverb' => [
            'key' => env('REVERB_APP_KEY'),
            'secret' => env('REVERB_APP_SECRET'),
            'app_id' => env('REVERB_APP_ID'),
            'options' => [
                'host' => env('REVERB_HOST', '127.0.0.1'),
                'port' => env('REVERB_PORT', 8080),
                'scheme' => env('REVERB_SCHEME', 'http'),
                'useTLS' => env('REVERB_SCHEME', 'https') === 'https',
            ],
            'allowed_origins' => [
                env('FRONTEND_URL', 'http://localhost:3000'),
                env('APP_URL', 'http://localhost:8000'),
            ],
            'ping_interval' => env('REVERB_PING_INTERVAL', 30),
            'max_message_size' => env('REVERB_MAX_MESSAGE_SIZE', 10000),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Reverb Logging
    |--------------------------------------------------------------------------
    |
    | Here you may configure the logging system used by Reverb. Reverb includes
    | support for the "single", "daily", "syslog", and "errorlog" log drivers.
    | You may also specify additional log drivers as needed.
    |
    */

    'logging' => [
        'driver' => env('REVERB_LOG_DRIVER', 'single'),
        'level' => env('REVERB_LOG_LEVEL', 'debug'),
        'path' => env('REVERB_LOG_PATH', storage_path('logs/reverb.log')),
    ],

];
