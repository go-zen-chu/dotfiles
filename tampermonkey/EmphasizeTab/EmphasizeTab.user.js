// ==UserScript==
// @name         EmphasizeTab
// @namespace    https://github.com/go-zen-chu
// @version      0.1
// @description  Emphasize tab title on edit pages to avoid accidental close
// @author       go-zen-chu
// @match        https://*/*
// @grant        none
// @updateURL    https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/EmphasizeTab/EmphasizeTab.user.js
// @downloadURL  https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/EmphasizeTab/EmphasizeTab.user.js
// ==/UserScript==

(function () {
    'use strict';

    const PREFIX = '🟥 ';

    let rawTitle = document.title || '';
    let isDecoratedByUs = false;
    let isApplyingTitle = false;

    function isEditPath() {
        try {
            return typeof window !== 'undefined'
                && window.location
                && typeof window.location.pathname === 'string'
                && window.location.pathname.includes('/edit');
        } catch (_) {
            return false;
        }
    }

    function ensureTitleElement() {
        let titleElement = document.querySelector('title');
        if (titleElement) {
            return titleElement;
        }

        const head = document.head || document.getElementsByTagName('head')[0];
        if (!head) {
            return null;
        }

        titleElement = document.createElement('title');
        titleElement.textContent = document.title || '';
        head.appendChild(titleElement);
        return titleElement;
    }

    function decorateTitle(title) {
        if (!title) {
            return PREFIX;
        }
        return title.startsWith(PREFIX) ? title : PREFIX + title;
    }

    function updateRawTitleFromCurrentTitle() {
        const currentTitle = document.title || '';
        if (isDecoratedByUs && currentTitle.startsWith(PREFIX)) {
            rawTitle = currentTitle.slice(PREFIX.length);
        } else {
            rawTitle = currentTitle;
        }
    }

    function applyTitle() {
        if (isApplyingTitle) {
            return;
        }

        updateRawTitleFromCurrentTitle();

        const shouldDecorate = isEditPath();
        const desiredTitle = shouldDecorate ? decorateTitle(rawTitle) : rawTitle;

        if ((document.title || '') === desiredTitle) {
            return;
        }

        isApplyingTitle = true;
        document.title = desiredTitle;
        // Only mark as "decorated by us" when we actually added the prefix.
        isDecoratedByUs = shouldDecorate && !rawTitle.startsWith(PREFIX) && desiredTitle.startsWith(PREFIX);
        isApplyingTitle = false;
    }

    function patchHistoryMethod(methodName) {
        const original = window.history[methodName];
        if (typeof original !== 'function') {
            return;
        }

        window.history[methodName] = function (...args) {
            const result = original.apply(this, args);
            applyTitle();
            return result;
        };
    }

    function setupTitleObserver() {
        const titleElement = ensureTitleElement();
        if (!titleElement || typeof MutationObserver === 'undefined') {
            return;
        }

        const observer = new MutationObserver(() => {
            if (isApplyingTitle) {
                return;
            }
            applyTitle();
        });

        observer.observe(titleElement, {
            childList: true,
            characterData: true,
            subtree: true,
        });
    }

    // For Single Page Applications like React, we need to monitor history changes
    patchHistoryMethod('pushState');
    patchHistoryMethod('replaceState');
    // For back/forward navigation
    window.addEventListener('popstate', applyTitle);
    // For hash change type navigation
    window.addEventListener('hashchange', applyTitle);
    // Monitor direct title changes by the web page application
    setupTitleObserver();
    applyTitle();
})();

