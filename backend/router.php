<?php
// Determine allowed origin
$allowed_origins = [
    'http://localhost:5173',
    'http://localhost:3000',
    'http://localhost:8000',
    'http://localhost:8080',
    'https://seratif2026-production.up.railway.app',
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$allowed_origin = in_array($origin, $allowed_origins, true) ? $origin : 'https://seratif2026-production.up.railway.app';

// Set CORS headers
header('Access-Control-Allow-Origin: ' . $allowed_origin);
header('Access-Control-Allow-Credentials: true');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

// Set environment variables
$_ENV['DB_HOST'] = getenv('DB_HOST') ?: 'localhost';
$_ENV['DB_NAME'] = getenv('DB_NAME') ?: 'seratif2026';
$_ENV['DB_USER'] = getenv('DB_USER') ?: 'root';
$_ENV['DB_PASS'] = getenv('DB_PASS') ?: '';

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// API routes - load backend router
if (preg_match('#^/(api|auth|ticket|validate|admin|upload-payment)#', $uri)) {
    $_SERVER['REQUEST_URI'] = $uri;
    $_SERVER['SCRIPT_FILENAME'] = __DIR__ . '/backend/index.php';
    chdir(__DIR__ . '/backend');
    require __DIR__ . '/backend/index.php';
    exit;
}

// Static files from dist
$file = __DIR__ . '/dist' . $uri;
if ($uri !== '/' && is_file($file)) {
    return false;
}

// SPA routing - serve index.html
if (file_exists(__DIR__ . '/dist/index.html')) {
    require __DIR__ . '/dist/index.html';
} else {
    http_response_code(404);
    echo 'Application not found';
}

