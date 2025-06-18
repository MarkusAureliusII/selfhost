<?php
session_start();

const SESSION_TIMEOUT = 3600; // 1 hour
const REMEMBER_ME_TIMEOUT = 86400 * 30; // 30 days
const ADMIN_USERNAME = 'admin';

// Check for remember me cookie and restore session
function checkRememberMe() {
    if (!isset($_SESSION['authenticated']) && isset($_COOKIE['remember_me'])) {
        $remember_token = $_COOKIE['remember_me'];
        if ($remember_token === hash('sha256', ADMIN_USERNAME . 'remember_token')) {
            $_SESSION['authenticated'] = true;
            $_SESSION['username'] = ADMIN_USERNAME;
            $_SESSION['login_time'] = time();
            $_SESSION['last_activity'] = time();
            $_SESSION['remember_me'] = true;
            return true;
        }
    }
    return false;
}

// Check if user is authenticated
function isAuthenticated() {
    // First check remember me cookie
    checkRememberMe();
    
    if (!isset($_SESSION['authenticated']) || $_SESSION['authenticated'] !== true) {
        return false;
    }
    
    // Use extended timeout for remember me sessions
    $timeout = isset($_SESSION['remember_me']) ? REMEMBER_ME_TIMEOUT : SESSION_TIMEOUT;
    
    // Check session timeout
    if (!isset($_SESSION['last_activity']) || (time() - $_SESSION['last_activity']) > $timeout) {
        // Session expired
        session_destroy();
        // Clear remember me cookie if session expired
        if (isset($_COOKIE['remember_me'])) {
            setcookie('remember_me', '', time() - 3600, '/');
        }
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
    // Clear remember me cookie
    if (isset($_COOKIE['remember_me'])) {
        setcookie('remember_me', '', time() - 3600, '/');
    }
    header('Location: login.php');
    exit;
}

// Handle logout request
if (isset($_GET['logout'])) {
    logout();
}
?>