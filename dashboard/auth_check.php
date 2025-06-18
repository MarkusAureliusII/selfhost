<?php
session_start();

const SESSION_TIMEOUT = 3600; // 1 hour

// Check if user is authenticated
function isAuthenticated() {
    if (!isset($_SESSION['authenticated']) || $_SESSION['authenticated'] !== true) {
        return false;
    }
    
    // Check session timeout
    if (!isset($_SESSION['last_activity']) || (time() - $_SESSION['last_activity']) > SESSION_TIMEOUT) {
        // Session expired
        session_destroy();
        return false;
    }
    
    // Update last activity
    $_SESSION['last_activity'] = time();
    return true;
}

// Redirect to login if not authenticated
function requireAuth() {
    if (!isAuthenticated()) {
        header('Location: login.php');
        exit;
    }
}

// Get current user info
function getCurrentUser() {
    if (isAuthenticated()) {
        return [
            'username' => $_SESSION['username'] ?? 'Unknown',
            'login_time' => $_SESSION['login_time'] ?? time(),
            'last_activity' => $_SESSION['last_activity'] ?? time()
        ];
    }
    return null;
}

// Logout function
function logout() {
    session_destroy();
    header('Location: login.php');
    exit;
}

// Handle logout request
if (isset($_GET['logout'])) {
    logout();
}
?>