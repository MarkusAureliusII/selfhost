/**
 * AI Stack Unified Application Integration
 * This script creates a seamless experience across all applications
 */

class AIStackUnifier {
    constructor() {
        this.currentApp = this.detectCurrentApp();
        this.theme = localStorage.getItem('ai-theme') || 'light';
        this.init();
    }

    detectCurrentApp() {
        const hostname = window.location.hostname;
        const port = window.location.port;
        const pathname = window.location.pathname;

        if (port === '3000' || pathname.includes('/dashboard')) return 'dashboard';
        if (port === '3001') return 'chat';
        if (port === '5678' || pathname.includes('/n8n')) return 'n8n';
        if (port === '11434') return 'ollama';
        if (port === '6333') return 'qdrant';
        if (port === '8080') return 'traefik';

        return 'unknown';
    }

    init() {
        this.loadUnifiedTheme();
        this.injectAIStackHeader();
        this.injectThemeToggle();
        this.injectAppNavigation();
        this.syncThemeAcrossApps();
        this.addSeamlessTransitions();
        this.customizeAppSpecific();
    }

    loadUnifiedTheme() {
        // Inject unified CSS if not already present
        if (!document.getElementById('ai-unified-theme')) {
            const link = document.createElement('link');
            link.id = 'ai-unified-theme';
            link.rel = 'stylesheet';
            link.href = '/themes/css/unified-app-theme.css';
            document.head.appendChild(link);
        }

        // Apply theme to document
        document.documentElement.setAttribute('data-theme', this.theme);
        document.body.classList.add('ai-unified');
    }

    injectAIStackHeader() {
        // Check if header already exists
        if (document.querySelector('.ai-stack-header')) return;

        const header = document.createElement('div');
        header.className = 'ai-stack-header';
        header.innerHTML = `
            <div class="ai-stack-logo">AI</div>
            <div class="ai-stack-title">AI Stack - ${this.getAppDisplayName()}</div>
            <div class="ai-stack-breadcrumb">
                <a href="http://217.154.225.184:3000" style="color: var(--ai-text-secondary); text-decoration: none;">
                    ← Back to Dashboard
                </a>
            </div>
        `;

        // Insert at the beginning of body
        document.body.insertBefore(header, document.body.firstChild);
    }

    injectThemeToggle() {
        if (document.querySelector('.ai-theme-toggle')) return;

        const toggle = document.createElement('button');
        toggle.className = 'ai-theme-toggle';
        toggle.innerHTML = this.theme === 'light' ? '🌙' : '☀️';
        toggle.title = 'Toggle theme';
        toggle.onclick = () => this.toggleTheme();

        document.body.appendChild(toggle);
    }

    injectAppNavigation() {
        if (document.querySelector('.ai-app-nav')) return;

        const nav = document.createElement('div');
        nav.className = 'ai-app-nav';

        const apps = [
            { name: 'Dashboard', url: 'http://217.154.225.184:3000', icon: '🏠', key: 'dashboard' },
            { name: 'Chat', url: 'http://217.154.225.184:3001', icon: '💬', key: 'chat' },
            { name: 'Workflows', url: 'http://217.154.225.184:5678', icon: '🔄', key: 'n8n' },
            { name: 'Models', url: 'http://217.154.225.184:11434', icon: '🧠', key: 'ollama' },
            { name: 'Vectors', url: 'http://217.154.225.184:6333', icon: '🗄️', key: 'qdrant' }
        ];

        apps.forEach(app => {
            const item = document.createElement('a');
            item.className = `ai-app-nav-item ${app.key === this.currentApp ? 'active' : ''}`;
            item.href = app.url;
            item.innerHTML = `${app.icon} ${app.name}`;
            item.title = `Switch to ${app.name}`;
            nav.appendChild(item);
        });

        document.body.appendChild(nav);
    }

    toggleTheme() {
        this.theme = this.theme === 'light' ? 'dark' : 'light';
        localStorage.setItem('ai-theme', this.theme);
        document.documentElement.setAttribute('data-theme', this.theme);
        
        const toggle = document.querySelector('.ai-theme-toggle');
        if (toggle) {
            toggle.innerHTML = this.theme === 'light' ? '🌙' : '☀️';
        }

        // Sync theme across all apps
        this.syncThemeAcrossApps();
    }

    syncThemeAcrossApps() {
        // Broadcast theme change to other tabs/windows
        if (window.BroadcastChannel) {
            const channel = new BroadcastChannel('ai-stack-theme');
            channel.postMessage({ type: 'themeChange', theme: this.theme });
            
            channel.onmessage = (event) => {
                if (event.data.type === 'themeChange') {
                    this.theme = event.data.theme;
                    document.documentElement.setAttribute('data-theme', this.theme);
                    const toggle = document.querySelector('.ai-theme-toggle');
                    if (toggle) {
                        toggle.innerHTML = this.theme === 'light' ? '🌙' : '☀️';
                    }
                }
            };
        }
    }

    addSeamlessTransitions() {
        // Add smooth transitions to all elements
        const style = document.createElement('style');
        style.textContent = `
            * {
                transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease !important;
            }
            
            .ai-seamless-fade {
                opacity: 0;
                animation: aiSeamlessFadeIn 0.5s ease-out forwards;
            }
            
            @keyframes aiSeamlessFadeIn {
                to { opacity: 1; }
            }
        `;
        document.head.appendChild(style);

        // Apply fade-in to main content
        setTimeout(() => {
            const mainContent = document.querySelector('main, .main, .content, #app, #root');
            if (mainContent) {
                mainContent.classList.add('ai-seamless-fade');
            }
        }, 100);
    }

    customizeAppSpecific() {
        switch (this.currentApp) {
            case 'n8n':
                this.customizeN8N();
                break;
            case 'chat':
                this.customizeOpenWebUI();
                break;
            case 'ollama':
                this.customizeOllama();
                break;
            case 'qdrant':
                this.customizeQdrant();
                break;
        }
    }

    customizeN8N() {
        // Wait for N8N to load, then apply customizations
        const waitForN8N = () => {
            // Hide N8N's default header if present
            const n8nHeader = document.querySelector('.header, .top-bar, [class*="header"]');
            if (n8nHeader && !n8nHeader.classList.contains('ai-stack-header')) {
                n8nHeader.style.display = 'none';
            }

            // Style N8N specific elements
            const style = document.createElement('style');
            style.textContent = `
                /* N8N Specific Overrides */
                .el-container {
                    background-color: var(--ai-primary-bg) !important;
                }
                
                .el-aside {
                    background-color: var(--ai-secondary-bg) !important;
                    border-right: 1px solid var(--ai-border-primary) !important;
                }
                
                .el-main {
                    background-color: var(--ai-primary-bg) !important;
                    padding-top: 0 !important;
                }
                
                .node-view, .workflow-canvas {
                    background-color: var(--ai-primary-bg) !important;
                }
                
                .n8n-button, .el-button {
                    font-family: var(--ai-font-family) !important;
                    border-radius: 8px !important;
                }
                
                .n8n-button--primary, .el-button--primary {
                    background-color: var(--ai-accent-color) !important;
                    border-color: var(--ai-accent-color) !important;
                }
                
                .n8n-input, .el-input__inner {
                    background-color: var(--ai-secondary-bg) !important;
                    border: 1px solid var(--ai-border-primary) !important;
                    color: var(--ai-text-primary) !important;
                    border-radius: 8px !important;
                }
                
                /* Hide N8N branding */
                .logo, [class*="logo"], .branding {
                    opacity: 0.3 !important;
                }
                
                /* Make workflow canvas blend */
                .workflow-canvas, .jsplumb-surface {
                    background: var(--ai-primary-bg) !important;
                }
            `;
            document.head.appendChild(style);
        };

        // Wait for DOM and then for N8N to initialize
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                setTimeout(waitForN8N, 1000);
            });
        } else {
            setTimeout(waitForN8N, 1000);
        }
    }

    customizeOpenWebUI() {
        // Wait for Open WebUI to load
        const waitForWebUI = () => {
            // Style Open WebUI specific elements
            const style = document.createElement('style');
            style.textContent = `
                /* Open WebUI Specific Overrides */
                .chat-container, .main-layout {
                    background-color: var(--ai-primary-bg) !important;
                }
                
                .sidebar, .left-panel {
                    background-color: var(--ai-secondary-bg) !important;
                    border-right: 1px solid var(--ai-border-primary) !important;
                }
                
                .chat-message {
                    background-color: var(--ai-card-bg) !important;
                    border: 1px solid var(--ai-border-primary) !important;
                    border-radius: 12px !important;
                    color: var(--ai-text-primary) !important;
                }
                
                .chat-message.user {
                    background-color: var(--ai-accent-color) !important;
                    color: white !important;
                }
                
                .chat-input, .message-input {
                    background-color: var(--ai-secondary-bg) !important;
                    border: 1px solid var(--ai-border-primary) !important;
                    color: var(--ai-text-primary) !important;
                    border-radius: 12px !important;
                }
                
                .send-button, .submit-button {
                    background-color: var(--ai-accent-color) !important;
                    border-radius: 8px !important;
                }
                
                /* Hide WebUI branding */
                .logo, [class*="logo"], .title {
                    opacity: 0.5 !important;
                }
                
                /* Model selector */
                .model-selector, .dropdown {
                    background-color: var(--ai-secondary-bg) !important;
                    border: 1px solid var(--ai-border-primary) !important;
                    border-radius: 8px !important;
                }
            `;
            document.head.appendChild(style);
        };

        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                setTimeout(waitForWebUI, 1000);
            });
        } else {
            setTimeout(waitForWebUI, 1000);
        }
    }

    customizeOllama() {
        const style = document.createElement('style');
        style.textContent = `
            /* Ollama API Interface */
            pre, code {
                background-color: var(--ai-secondary-bg) !important;
                color: var(--ai-text-primary) !important;
                border-radius: 8px !important;
                padding: 1rem !important;
            }
        `;
        document.head.appendChild(style);
    }

    customizeQdrant() {
        const style = document.createElement('style');
        style.textContent = `
            /* Qdrant Dashboard */
            .dashboard, .main-content {
                background-color: var(--ai-primary-bg) !important;
            }
        `;
        document.head.appendChild(style);
    }

    getAppDisplayName() {
        const names = {
            'dashboard': 'Dashboard',
            'chat': 'AI Chat',
            'n8n': 'Workflows',
            'ollama': 'AI Models',
            'qdrant': 'Vector Database',
            'traefik': 'Proxy'
        };
        return names[this.currentApp] || 'AI Stack';
    }
}

// Initialize the unifier when the page loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new AIStackUnifier();
    });
} else {
    new AIStackUnifier();
}

// Also initialize on subsequent navigations (for SPAs)
window.addEventListener('popstate', () => {
    setTimeout(() => new AIStackUnifier(), 100);
});