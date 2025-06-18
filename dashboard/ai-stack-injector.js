// ==UserScript==
// @name         AI Stack Unified Theme
// @namespace    http://217.154.225.184/
// @version      1.0
// @description  Apply unified AI Stack theme to all applications
// @author       AI Stack
// @match        http://217.154.225.184:3001/*
// @match        http://217.154.225.184:5678/*
// @match        http://217.154.225.184:6333/*
// @match        http://217.154.225.184:8080/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';
    
    // Load unified theme CSS
    const cssLink = document.createElement('link');
    cssLink.rel = 'stylesheet';
    cssLink.href = 'http://217.154.225.184:3000/serve-theme.php?file=unified-css';
    document.head.appendChild(cssLink);
    
    // Load unified integration JS
    const jsScript = document.createElement('script');
    jsScript.src = 'http://217.154.225.184:3000/serve-theme.php?file=unified-js';
    document.head.appendChild(jsScript);
    
    // Apply immediate styling
    const immediateStyle = document.createElement('style');
    immediateStyle.textContent = `
        body { 
            background-color: #ffffff !important; 
            color: #0f172a !important; 
            font-family: "Inter", sans-serif !important;
            transition: all 0.3s ease !important;
        }
        [data-theme="dark"] body { 
            background-color: #0f172a !important; 
            color: #f8fafc !important; 
        }
    `;
    document.head.appendChild(immediateStyle);
    
    // Apply theme from localStorage
    const theme = localStorage.getItem('ai-theme') || 'light';
    document.documentElement.setAttribute('data-theme', theme);
})();