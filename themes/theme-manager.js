// Unified AI Stack Theme Manager
class AIStackThemeManager {
    constructor() {
        this.currentTheme = 'dark';
        this.storageKey = 'ai-stack-theme';
        this.init();
    }

    init() {
        // Load saved theme or default to dark
        this.currentTheme = localStorage.getItem(this.storageKey) || 'dark';
        this.applyTheme(this.currentTheme);
        this.createThemeToggle();
        this.detectSystemTheme();
        
        // Listen for system theme changes
        if (window.matchMedia) {
            window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
                if (!localStorage.getItem(this.storageKey)) {
                    this.applyTheme(e.matches ? 'dark' : 'light');
                }
            });
        }
    }

    applyTheme(theme) {
        this.currentTheme = theme;
        
        // Set HTML data attribute
        document.documentElement.setAttribute('data-theme', theme);
        document.documentElement.setAttribute('data-ai-stack-theme', theme);
        
        // Set CSS custom properties
        document.documentElement.style.setProperty('--ai-stack-current-theme', theme);
        
        // Apply to body classes
        document.body.classList.remove('light-theme', 'dark-theme');
        document.body.classList.add(`${theme}-theme`);
        
        // Update meta theme-color
        this.updateMetaThemeColor(theme);
        
        // Dispatch custom event for other scripts to listen
        window.dispatchEvent(new CustomEvent('ai-stack-theme-changed', {
            detail: { theme: theme }
        }));
        
        // Save to localStorage
        localStorage.setItem(this.storageKey, theme);
        
        // Update toggle button if it exists
        this.updateToggleButton();
    }

    toggleTheme() {
        const newTheme = this.currentTheme === 'dark' ? 'light' : 'dark';
        this.applyTheme(newTheme);
    }

    createThemeToggle() {
        // Remove existing toggle if present
        const existingToggle = document.getElementById('ai-stack-theme-toggle');
        if (existingToggle) {
            existingToggle.remove();
        }

        // Create new toggle button
        const toggle = document.createElement('button');
        toggle.id = 'ai-stack-theme-toggle';
        toggle.className = 'theme-toggle-ai-stack';
        toggle.setAttribute('aria-label', 'Toggle theme');
        toggle.setAttribute('title', 'Toggle Dark/Light Mode');
        
        // Add to page
        document.body.appendChild(toggle);
        
        // Add click event
        toggle.addEventListener('click', () => this.toggleTheme());
        
        // Update button content
        this.updateToggleButton();
    }

    updateToggleButton() {
        const toggle = document.getElementById('ai-stack-theme-toggle');
        if (toggle) {
            toggle.innerHTML = this.currentTheme === 'dark' ? '☀️' : '🌙';
            toggle.setAttribute('title', 
                this.currentTheme === 'dark' ? 'Switch to Light Mode' : 'Switch to Dark Mode'
            );
        }
    }

    updateMetaThemeColor(theme) {
        let metaThemeColor = document.querySelector('meta[name="theme-color"]');
        if (!metaThemeColor) {
            metaThemeColor = document.createElement('meta');
            metaThemeColor.name = 'theme-color';
            document.getElementsByTagName('head')[0].appendChild(metaThemeColor);
        }
        
        metaThemeColor.content = theme === 'dark' ? '#0f172a' : '#ffffff';
    }

    detectSystemTheme() {
        if (!localStorage.getItem(this.storageKey)) {
            if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                this.applyTheme('dark');
            } else {
                this.applyTheme('light');
            }
        }
    }

    // Service-specific theme application
    applyServiceTheme(serviceName) {
        document.body.setAttribute('data-service', serviceName);
        
        switch (serviceName) {
            case 'openwebui':
                this.applyOpenWebUITheme();
                break;
            case 'n8n':
                this.applyN8NTheme();
                break;
            case 'traefik':
                this.applyTraefikTheme();
                break;
            case 'qdrant':
                this.applyQdrantTheme();
                break;
            default:
                this.applyDefaultTheme();
        }
    }

    applyOpenWebUITheme() {
        // Inject specific styles for Open WebUI
        this.injectCSS(`
            .chat-interface {
                background-color: var(--ai-stack-bg-primary) !important;
            }
            .message-container {
                background-color: var(--ai-stack-bg-card) !important;
                border: 1px solid var(--ai-stack-border-primary) !important;
            }
        `, 'openwebui-theme');
    }

    applyN8NTheme() {
        // Inject specific styles for N8N
        this.injectCSS(`
            .ndv-wrapper, .workflow-canvas {
                background-color: var(--ai-stack-bg-primary) !important;
            }
            .node-default {
                background-color: var(--ai-stack-bg-card) !important;
                border: 1px solid var(--ai-stack-border-primary) !important;
            }
        `, 'n8n-theme');
    }

    applyTraefikTheme() {
        // Inject specific styles for Traefik
        this.injectCSS(`
            body {
                background-color: var(--ai-stack-bg-primary) !important;
            }
            .card, .panel {
                background-color: var(--ai-stack-bg-card) !important;
                border: 1px solid var(--ai-stack-border-primary) !important;
            }
        `, 'traefik-theme');
    }

    applyQdrantTheme() {
        // Inject specific styles for Qdrant
        this.injectCSS(`
            .dashboard-container {
                background-color: var(--ai-stack-bg-primary) !important;
            }
            .metric-card {
                background-color: var(--ai-stack-bg-card) !important;
                border: 1px solid var(--ai-stack-border-primary) !important;
            }
        `, 'qdrant-theme');
    }

    applyDefaultTheme() {
        // Default theme application for unknown services
        console.log('Applying default AI Stack theme');
    }

    injectCSS(css, id) {
        // Remove existing style if present
        const existingStyle = document.getElementById(id);
        if (existingStyle) {
            existingStyle.remove();
        }

        // Create and inject new style
        const style = document.createElement('style');
        style.id = id;
        style.textContent = css;
        document.head.appendChild(style);
    }

    // Keyboard shortcut support
    setupKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // Ctrl/Cmd + Shift + T to toggle theme
            if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'T') {
                e.preventDefault();
                this.toggleTheme();
            }
        });
    }

    // Auto-detect service from URL or page content
    detectService() {
        const hostname = window.location.hostname;
        const port = window.location.port;
        const pathname = window.location.pathname;
        
        // Detect by port
        switch (port) {
            case '3001':
                return 'openwebui';
            case '5678':
                return 'n8n';
            case '8080':
                return 'traefik';
            case '6333':
                return 'qdrant';
            case '3000':
                return 'dashboard';
            default:
                // Detect by pathname or content
                if (pathname.includes('chat') || document.querySelector('.chat-interface')) {
                    return 'openwebui';
                }
                if (pathname.includes('workflow') || document.querySelector('.n8n-editor')) {
                    return 'n8n';
                }
                if (document.querySelector('.traefik') || pathname.includes('traefik')) {
                    return 'traefik';
                }
                return 'default';
        }
    }
}

// Auto-initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    const themeManager = new AIStackThemeManager();
    
    // Detect and apply service-specific theme
    const service = themeManager.detectService();
    themeManager.applyServiceTheme(service);
    
    // Setup keyboard shortcuts
    themeManager.setupKeyboardShortcuts();
    
    // Make available globally
    window.aiStackTheme = themeManager;
    
    console.log('AI Stack Theme Manager initialized for service:', service);
});

// Also initialize immediately if DOM is already ready
if (document.readyState === 'loading') {
    // DOM is still loading
} else {
    // DOM is already ready
    const themeManager = new AIStackThemeManager();
    const service = themeManager.detectService();
    themeManager.applyServiceTheme(service);
    themeManager.setupKeyboardShortcuts();
    window.aiStackTheme = themeManager;
}