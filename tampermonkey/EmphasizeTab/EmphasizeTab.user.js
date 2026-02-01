// ==UserScript==
// @name         EmphasizeTab
// @namespace    https://github.com/go-zen-chu
// @version      0.5
// @description  Blink tab title on edit pages to avoid accidental close
// @author       go-zen-chu
// @match        https://*/*
// @grant        none
// @updateURL    https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/EmphasizeTab/EmphasizeTab.user.js
// @downloadURL  https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/EmphasizeTab/EmphasizeTab.user.js
// ==/UserScript==

(function () {
    'use strict';

    const TITLE_BLINK_TEXT = '️🟥 Editing';
    const TITLE_BLINK_INTERVAL_MS = 1000;

    let originalTitle = null;
    let titleBlinkTimer = null;
    let titleBlinkVisible = false;
    let titleObserver = null;

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

    function startTitleBlink() {
        if (titleBlinkTimer) {
            return;
        }
        if (originalTitle === null) {
            originalTitle = document.title;
        }

        titleBlinkTimer = window.setInterval(() => {
            titleBlinkVisible = !titleBlinkVisible;
            document.title = titleBlinkVisible ? TITLE_BLINK_TEXT : originalTitle;
        }, TITLE_BLINK_INTERVAL_MS);
    }

    function stopTitleBlink() {
        if (titleBlinkTimer) {
            window.clearInterval(titleBlinkTimer);
            titleBlinkTimer = null;
        }
        if (originalTitle !== null) {
            document.title = originalTitle;
            originalTitle = null;
        }
        titleBlinkVisible = false;
    }

    function applyEmphasis() {
        if (isEditPath()) {
            startTitleBlink();
        } else {
            stopTitleBlink();
        }
    }

    function patchHistoryMethod(methodName) {
        const original = window.history[methodName];
        if (typeof original !== 'function') {
            return;
        }
        window.history[methodName] = function (...args) {
            const result = original.apply(this, args);
            applyEmphasis();
            return result;
        };
    }

    // For Single Page Applications like React, we need to monitor history changes
    patchHistoryMethod('pushState');
    patchHistoryMethod('replaceState');

    // For back/forward navigation
    window.addEventListener('popstate', applyEmphasis);
    // For hash change type navigation
    window.addEventListener('hashchange', applyEmphasis);

    // Re-apply after full load since some sites set title late.
    window.addEventListener('load', applyEmphasis, { once: true });
    applyEmphasis();
})();
