// ==UserScript==
// @name         ContainsCredentialsAlert
// @namespace    github.com/go-zen-chu
// @version      0.3
// @description  Watch out! You might input credentials!
// @author       go-zen-chu
// @licence      MIT
// @match        https://*/*
// @icon         https://img.icons8.com/?size=64&id=82753&format=png
// @grant        none
// @updateURL https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/CredentialsAlert/CredentialsAlert.user.js
// @downloadURL https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/CredentialsAlert/CredentialsAlert.user.js
// ==/UserScript==

(function () {
    'use strict';

    // Pre-compile detection patterns for better performance
    const detectWords = ["password", "token", "secret"];
    const doubtfulWords = [
        // private key
        "begin private key", "begin rsa private key", "begin openssh private key",
        // jwt
        "eyjhbgci",
        // base64 encoded string (easily decoded)
        "ls0tls1", "cg==",
        "api_key", "secret_key",
        "connection_string",
    ];

    // Combine and pre-process all detection patterns
    const allPatterns = detectWords.concat(doubtfulWords);

    // Create reusable alert element
    const body = document.querySelector("body");
    const alertElement = document.createElement('div');
    alertElement.textContent = 'WARNING!!! : Your input might contain ' + JSON.stringify(detectWords);
    alertElement.id = "credential-alert";
    alertElement.className = "credential-alert";
    alertElement.style.cssText = "font-weight: bold;"
        + "font-size: 12pt;"
        + "background-color: #FF0000;"
        + "color: #FFFFFF;"
        + "padding: 5px;"
        + "display: none;"; // Initially hidden

    // Insert alert element once at initialization
    body.insertBefore(alertElement, body.firstChild);

    // Debounce function to limit processing frequency
    function debounce(func, delay) {
        let timeoutId;
        return function (...args) {
            clearTimeout(timeoutId);
            timeoutId = setTimeout(() => func.apply(this, args), delay);
        };
    }

    // Optimized detection function
    function detectCredentials(text) {
        if (!text || typeof text !== 'string') {
            return false;
        }

        const lowerText = text.toLowerCase();

        // Early return optimization - check most common patterns first
        for (let i = 0; i < allPatterns.length; i++) {
            if (lowerText.includes(allPatterns[i])) {
                return true;
            }
        }
        return false;
    }

    // Optimized alert display function
    function toggleAlert(show) {
        alertElement.style.display = show ? 'block' : 'none';
    }

    // Debounced input handler
    const handleInput = debounce((event) => {
        let text = "";

        // Optimized text extraction
        const target = event.target;
        if (target.value !== undefined) {
            text = target.value;
        } else if (target.innerText !== undefined) {
            text = target.innerText;
        } else {
            return;
        }

        // Skip processing for very short inputs
        if (text.length < 3) {
            toggleAlert(false);
            return;
        }

        const hasCredentials = detectCredentials(text);
        toggleAlert(hasCredentials);
    }, 300); // 300ms debounce delay

    // Use event delegation for better performance
    body.addEventListener("input", handleInput, true);

    // Cleanup function for potential memory leaks
    window.addEventListener('beforeunload', () => {
        body.removeEventListener("input", handleInput, true);
    });
})();
