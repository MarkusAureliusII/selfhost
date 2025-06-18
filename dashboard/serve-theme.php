<?php
// Serve unified theme files to all applications
$request = $_GET['file'] ?? '';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

switch ($request) {
    case 'unified-css':
        header('Content-Type: text/css');
        echo file_get_contents('../themes/css/unified-app-theme.css');
        break;
        
    case 'unified-js':
        header('Content-Type: application/javascript');
        echo file_get_contents('../themes/js/unified-app-integration.js');
        break;
        
    case 'inject-html':
        header('Content-Type: text/html');
        echo getInjectionHTML();
        break;
        
    default:
        header('HTTP/1.1 404 Not Found');
        echo 'Theme file not found';
}

function getInjectionHTML() {
    return '<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="http://217.154.225.184:3000/serve-theme.php?file=unified-css">
    <script src="http://217.154.225.184:3000/serve-theme.php?file=unified-js"></script>
    <style>
        /* Immediate theme application */
        body { 
            background-color: #ffffff !important; 
            color: #0f172a !important; 
            font-family: "Inter", sans-serif !important;
        }
        [data-theme="dark"] body { 
            background-color: #0f172a !important; 
            color: #f8fafc !important; 
        }
    </style>
</head>
<body>
    <script>
        // Apply theme immediately
        const theme = localStorage.getItem("ai-theme") || "light";
        document.documentElement.setAttribute("data-theme", theme);
        
        // Auto-redirect parent frame if in iframe
        if (window.parent !== window) {
            window.parent.postMessage({type: "aiTheme", theme: theme}, "*");
        }
    </script>
</body>
</html>';
}
?>