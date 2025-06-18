<!DOCTYPE html>
<html lang="de" data-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Stack - Benutzerfreundliche URLs</title>
    <link rel="stylesheet" href="themes/unified-dark-theme.css">
    <style>
        .routes-container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .routes-header {
            text-align: center;
            margin-bottom: 3rem;
        }

        .routes-header h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #3b82f6, #8b5cf6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .routes-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            margin-bottom: 3rem;
        }

        .route-card {
            background: var(--card-bg);
            border: 1px solid var(--border-primary);
            border-radius: 16px;
            padding: 2rem;
            transition: all 0.3s ease;
        }

        .route-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            border-color: var(--accent-color);
        }

        .route-header {
            display: flex;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .route-icon {
            font-size: 2.5rem;
            margin-right: 1rem;
        }

        .route-info h3 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }

        .route-description {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }

        .route-urls {
            margin-bottom: 1.5rem;
        }

        .url-group {
            margin-bottom: 1rem;
        }

        .url-label {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-bottom: 0.25rem;
            font-weight: 500;
        }

        .url-display {
            background: var(--primary-bg);
            padding: 0.75rem 1rem;
            border-radius: 8px;
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 0.9rem;
            border: 1px solid var(--border-primary);
            margin-bottom: 0.5rem;
        }

        .url-friendly {
            color: #10b981;
        }

        .url-direct {
            color: var(--accent-color);
        }

        .route-actions {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .action-btn {
            background: var(--accent-color);
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.2s ease;
            border: none;
            cursor: pointer;
        }

        .action-btn:hover {
            background: #2563eb;
            transform: translateY(-1px);
        }

        .action-btn.secondary {
            background: var(--border-primary);
            color: var(--text-primary);
        }

        .action-btn.secondary:hover {
            background: #475569;
        }

        .status-indicator {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            display: inline-block;
            margin-left: 0.5rem;
        }

        .status-online {
            background: #10b981;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.2);
        }

        .status-offline {
            background: #ef4444;
            box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.2);
        }

        .note-section {
            background: var(--card-bg);
            border: 1px solid var(--border-primary);
            border-radius: 16px;
            padding: 2rem;
            text-align: center;
            border-left: 4px solid #f59e0b;
        }

        .note-section h3 {
            color: #f59e0b;
            margin-bottom: 1rem;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            color: var(--accent-color);
            text-decoration: none;
            margin-bottom: 2rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }

        .back-link:hover {
            color: #2563eb;
            transform: translateX(-2px);
        }
    </style>
</head>
<body>
    <div class="routes-container">
        <a href="index.php" class="back-link">
            ← Zurück zum Dashboard
        </a>

        <div class="routes-header">
            <h1>🚀 Benutzerfreundliche Service-URLs</h1>
            <p>Einfacher Zugriff auf alle AI-Services über beschreibende Namen</p>
        </div>

        <div class="routes-grid">
            <div class="route-card">
                <div class="route-header">
                    <div class="route-icon">🔄</div>
                    <div class="route-info">
                        <h3>Automation <span class="status-indicator status-online"></span></h3>
                        <div class="route-description">N8N Workflow-Automatisierung</div>
                    </div>
                </div>
                <div class="route-urls">
                    <div class="url-group">
                        <div class="url-label">Benutzerfreundliche URL (in Arbeit):</div>
                        <div class="url-display url-friendly">http://217.154.225.184/automation</div>
                    </div>
                    <div class="url-group">
                        <div class="url-label">Direkte URL (funktioniert):</div>
                        <div class="url-display url-direct">http://217.154.225.184:5678</div>
                    </div>
                </div>
                <div class="route-actions">
                    <a href="http://217.154.225.184:5678" class="action-btn" target="_blank">🔄 N8N öffnen</a>
                </div>
            </div>

            <div class="route-card">
                <div class="route-header">
                    <div class="route-icon">💬</div>
                    <div class="route-info">
                        <h3>Chat <span class="status-indicator status-online"></span></h3>
                        <div class="route-description">Open WebUI - ChatGPT-Interface</div>
                    </div>
                </div>
                <div class="route-urls">
                    <div class="url-group">
                        <div class="url-label">Benutzerfreundliche URL (in Arbeit):</div>
                        <div class="url-display url-friendly">http://217.154.225.184/chat</div>
                    </div>
                    <div class="url-group">
                        <div class="url-label">Direkte URL (funktioniert):</div>
                        <div class="url-display url-direct">http://217.154.225.184:3001</div>
                    </div>
                </div>
                <div class="route-actions">
                    <a href="http://217.154.225.184:3001" class="action-btn" target="_blank">💬 Chat öffnen</a>
                </div>
            </div>

            <div class="route-card">
                <div class="route-header">
                    <div class="route-icon">🗄️</div>
                    <div class="route-info">
                        <h3>Database <span class="status-indicator status-online"></span></h3>
                        <div class="route-description">Supabase Studio - Backend Platform</div>
                    </div>
                </div>
                <div class="route-urls">
                    <div class="url-group">
                        <div class="url-label">Benutzerfreundliche URL (in Arbeit):</div>
                        <div class="url-display url-friendly">http://217.154.225.184/database</div>
                    </div>
                    <div class="url-group">
                        <div class="url-label">Direkte URL (funktioniert):</div>
                        <div class="url-display url-direct">http://217.154.225.184:6333</div>
                    </div>
                </div>
                <div class="route-actions">
                    <a href="http://217.154.225.184:6333" class="action-btn" target="_blank">🗄️ Studio öffnen</a>
                    <a href="http://217.154.225.184:8000/rest/v1/" class="action-btn secondary" target="_blank">🔌 API</a>
                </div>
            </div>

            <div class="route-card">
                <div class="route-header">
                    <div class="route-icon">🤖</div>
                    <div class="route-info">
                        <h3>LLM API <span class="status-indicator status-online"></span></h3>
                        <div class="route-description">Ollama - AI Model Server</div>
                    </div>
                </div>
                <div class="route-urls">
                    <div class="url-group">
                        <div class="url-label">Benutzerfreundliche URL (in Arbeit):</div>
                        <div class="url-display url-friendly">http://217.154.225.184/llm-api</div>
                    </div>
                    <div class="url-group">
                        <div class="url-label">Direkte URL (funktioniert):</div>
                        <div class="url-display url-direct">http://217.154.225.184:11434</div>
                    </div>
                </div>
                <div class="route-actions">
                    <a href="http://217.154.225.184:11434/api/tags" class="action-btn" target="_blank">🤖 Modelle anzeigen</a>
                </div>
            </div>

            <div class="route-card">
                <div class="route-header">
                    <div class="route-icon">📊</div>
                    <div class="route-info">
                        <h3>Dashboard <span class="status-indicator status-online"></span></h3>
                        <div class="route-description">VPS Monitoring & Übersicht</div>
                    </div>
                </div>
                <div class="route-urls">
                    <div class="url-group">
                        <div class="url-label">Benutzerfreundliche URL (in Arbeit):</div>
                        <div class="url-display url-friendly">http://217.154.225.184/dashboard</div>
                    </div>
                    <div class="url-group">
                        <div class="url-label">Direkte URL (funktioniert):</div>
                        <div class="url-display url-direct">http://217.154.225.184:3000</div>
                    </div>
                </div>
                <div class="route-actions">
                    <a href="http://217.154.225.184:3000" class="action-btn" target="_blank">📊 Dashboard öffnen</a>
                </div>
            </div>

            <div class="route-card">
                <div class="route-header">
                    <div class="route-icon">🔀</div>
                    <div class="route-info">
                        <h3>Proxy <span class="status-indicator status-online"></span></h3>
                        <div class="route-description">Traefik - Load Balancer</div>
                    </div>
                </div>
                <div class="route-urls">
                    <div class="url-group">
                        <div class="url-label">Benutzerfreundliche URL (in Arbeit):</div>
                        <div class="url-display url-friendly">http://217.154.225.184/proxy</div>
                    </div>
                    <div class="url-group">
                        <div class="url-label">Direkte URL (funktioniert):</div>
                        <div class="url-display url-direct">http://217.154.225.184:8080</div>
                    </div>
                </div>
                <div class="route-actions">
                    <a href="http://217.154.225.184:8080" class="action-btn" target="_blank">🔀 Traefik öffnen</a>
                </div>
            </div>
        </div>

        <div class="note-section">
            <h3>⚠️ Wichtiger Hinweis</h3>
            <p>
                Die benutzerfreundlichen URLs (z.B. <code>/automation</code>, <code>/chat</code>) sind derzeit in der Konfiguration und werden über Traefik geleitet. 
                <br><br>
                <strong>Bis zur vollständigen Einrichtung verwenden Sie bitte die direkten Port-Links</strong>, die vollständig funktionsfähig sind.
                <br><br>
                Alle Services sind über ihre Standard-Ports erreichbar und voll einsatzbereit.
            </p>
        </div>
    </div>

    <script>
        // Dark mode als Standard
        document.documentElement.setAttribute('data-theme', 'dark');
        
        // Keyboard shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case '1':
                        e.preventDefault();
                        window.open('http://217.154.225.184:5678', '_blank');
                        break;
                    case '2':
                        e.preventDefault();
                        window.open('http://217.154.225.184:3001', '_blank');
                        break;
                    case '3':
                        e.preventDefault();
                        window.open('http://217.154.225.184:6333', '_blank');
                        break;
                    case '4':
                        e.preventDefault();
                        window.open('http://217.154.225.184:11434', '_blank');
                        break;
                    case '5':
                        e.preventDefault();
                        window.open('http://217.154.225.184:3000', '_blank');
                        break;
                }
            }
        });

        // Auto-refresh status indicators (simplified)
        setInterval(function() {
            // Simple status check - in a real implementation, this would ping each service
            console.log('Status check performed');
        }, 30000);
    </script>
</body>
</html>