<?php
session_start();

// Simple authentication - in production, use proper password hashing
const ADMIN_USERNAME = 'admin';
const ADMIN_PASSWORD = 'admin123';
const SESSION_TIMEOUT = 3600; // 1 hour

// Check if already logged in
if (isset($_SESSION['authenticated']) && $_SESSION['authenticated'] === true) {
    // Check session timeout
    if (isset($_SESSION['last_activity']) && (time() - $_SESSION['last_activity']) < SESSION_TIMEOUT) {
        $_SESSION['last_activity'] = time();
        header('Location: index.php');
        exit;
    } else {
        // Session expired
        session_destroy();
        session_start();
    }
}

$error_message = '';

// Handle login form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    
    if ($username === ADMIN_USERNAME && $password === ADMIN_PASSWORD) {
        $_SESSION['authenticated'] = true;
        $_SESSION['username'] = $username;
        $_SESSION['login_time'] = time();
        $_SESSION['last_activity'] = time();
        
        // Redirect to dashboard
        header('Location: index.php');
        exit;
    } else {
        $error_message = 'Invalid username or password';
    }
}
?>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Stack Login</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root[data-theme="light"] {
            --primary-bg: #ffffff;
            --secondary-bg: #f8fafc;
            --tertiary-bg: #f1f5f9;
            --card-bg: #ffffff;
            --text-primary: #0f172a;
            --text-secondary: #475569;
            --text-muted: #94a3b8;
            --accent-color: #3b82f6;
            --accent-hover: #2563eb;
            --accent-light: #dbeafe;
            --border-primary: #e2e8f0;
            --error-color: #ef4444;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        :root[data-theme="dark"] {
            --primary-bg: #0f172a;
            --secondary-bg: #1e293b;
            --tertiary-bg: #334155;
            --card-bg: #1e293b;
            --text-primary: #f8fafc;
            --text-secondary: #cbd5e1;
            --text-muted: #64748b;
            --accent-color: #60a5fa;
            --accent-hover: #3b82f6;
            --accent-light: #1e3a8a;
            --border-primary: #334155;
            --error-color: #f87171;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.3);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.4), 0 2px 4px -1px rgba(0, 0, 0, 0.3);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 4px 6px -2px rgba(0, 0, 0, 0.3);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            background: linear-gradient(135deg, var(--primary-bg) 0%, var(--secondary-bg) 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 1rem;
            transition: all 0.3s ease;
        }

        .login-container {
            width: 100%;
            max-width: 400px;
            background: var(--card-bg);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border-primary);
            position: relative;
            overflow: hidden;
        }

        .login-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, var(--accent-color), var(--accent-hover));
        }

        .logo-section {
            text-align: center;
            margin-bottom: 2rem;
        }

        .logo-icon {
            width: 64px;
            height: 64px;
            background: linear-gradient(135deg, var(--accent-color), var(--accent-hover));
            border-radius: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.75rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .login-title {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .login-subtitle {
            color: var(--text-secondary);
            font-size: 0.875rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            display: block;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .form-input {
            width: 100%;
            padding: 0.75rem 1rem;
            font-family: inherit;
            font-size: 1rem;
            color: var(--text-primary);
            background-color: var(--secondary-bg);
            border: 1px solid var(--border-primary);
            border-radius: 12px;
            transition: all 0.2s ease;
        }

        .form-input:focus {
            outline: none;
            border-color: var(--accent-color);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            background-color: var(--card-bg);
        }

        .form-input::placeholder {
            color: var(--text-muted);
        }

        .login-button {
            width: 100%;
            padding: 0.875rem;
            font-size: 1rem;
            font-weight: 600;
            background: linear-gradient(135deg, var(--accent-color), var(--accent-hover));
            color: white;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-bottom: 1.5rem;
        }

        .login-button:hover {
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        .login-button:active {
            transform: translateY(0);
        }

        .login-button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        .error-message {
            background-color: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: var(--error-color);
            padding: 0.75rem 1rem;
            border-radius: 12px;
            margin-bottom: 1rem;
            font-size: 0.875rem;
            text-align: center;
        }

        .theme-toggle {
            position: absolute;
            top: 1rem;
            right: 1rem;
            background: var(--secondary-bg);
            border: 1px solid var(--border-primary);
            border-radius: 8px;
            padding: 0.5rem;
            cursor: pointer;
            transition: all 0.2s ease;
            color: var(--text-secondary);
        }

        .theme-toggle:hover {
            background: var(--tertiary-bg);
            color: var(--text-primary);
        }

        .info-section {
            text-align: center;
            padding-top: 1.5rem;
            border-top: 1px solid var(--border-primary);
            color: var(--text-muted);
            font-size: 0.75rem;
        }

        .fade-in {
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive Design */
        @media (max-width: 480px) {
            .login-container {
                padding: 1.5rem;
                margin: 1rem;
            }

            .logo-icon {
                width: 48px;
                height: 48px;
                font-size: 1.5rem;
            }

            .login-title {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <button class="theme-toggle" onclick="toggleTheme()">
        <span id="theme-icon">🌙</span>
    </button>

    <div class="login-container fade-in">
        <div class="logo-section">
            <div class="logo-icon">AI</div>
            <h1 class="login-title">AI Stack Login</h1>
            <p class="login-subtitle">Access your AI management dashboard</p>
        </div>

        <?php if ($error_message): ?>
            <div class="error-message">
                <?php echo htmlspecialchars($error_message); ?>
            </div>
        <?php endif; ?>

        <form method="POST">
            <div class="form-group">
                <label for="username" class="form-label">Username</label>
                <input 
                    type="text" 
                    id="username" 
                    name="username" 
                    class="form-input" 
                    placeholder="Enter your username"
                    value="admin"
                    required
                    autofocus
                >
            </div>

            <div class="form-group">
                <label for="password" class="form-label">Password</label>
                <input 
                    type="password" 
                    id="password" 
                    name="password" 
                    class="form-input" 
                    placeholder="Enter your password"
                    required
                >
            </div>

            <button type="submit" class="login-button">
                Sign In to Dashboard
            </button>
        </form>

        <div class="info-section">
            <p>Default credentials: admin / admin123</p>
            <p style="margin-top: 0.5rem;">
                Once logged in, you'll have access to all AI services
            </p>
        </div>
    </div>

    <script>
        // Theme Management
        function toggleTheme() {
            const html = document.documentElement;
            const currentTheme = html.getAttribute('data-theme');
            const newTheme = currentTheme === 'light' ? 'dark' : 'light';
            const themeIcon = document.getElementById('theme-icon');
            
            html.setAttribute('data-theme', newTheme);
            themeIcon.textContent = newTheme === 'light' ? '🌙' : '☀️';
            
            localStorage.setItem('theme', newTheme);
        }

        // Initialize theme from localStorage
        function initTheme() {
            const savedTheme = localStorage.getItem('theme') || 'light';
            const html = document.documentElement;
            const themeIcon = document.getElementById('theme-icon');
            
            html.setAttribute('data-theme', savedTheme);
            themeIcon.textContent = savedTheme === 'light' ? '🌙' : '☀️';
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', function() {
            initTheme();
            
            // Focus password field if username is prefilled
            const username = document.getElementById('username');
            const password = document.getElementById('password');
            
            if (username.value) {
                password.focus();
            }
        });

        // Enter key handling
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                const form = document.querySelector('form');
                form.submit();
            }
            
            if (e.ctrlKey && e.key === 'd') {
                e.preventDefault();
                toggleTheme();
            }
        });
    </script>
</body>
</html>