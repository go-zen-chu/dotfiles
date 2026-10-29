// ==UserScript==
// @name         Html2md
// @namespace    https://github.com/go-zen-chu
// @version      0.3
// @description  Convert html page to markdown and store to clipboard
// @author       go-zen-chu
// @match        https://*/*
// @icon         https://img.icons8.com/?size=160&id=50145&format=png
// @run-at       context-menu
// @grant        GM_setClipboard
// @require      https://unpkg.com/turndown@7.2.4/dist/turndown.js#sha256=c97187f436d41638bf7acf346a39d9d42f2f2c02af18245a297c09e796f8e46f
// @updateURL    https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/Html2md/Html2md.user.js
// @downloadURL  https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/Html2md/Html2md.user.js
// ==/UserScript==

(function () {
    'use strict';

    function convertContentToMarkdown(turndownService, html) {
        turndownService.remove('script');
        turndownService.remove('style');
        var ignoreDivClass = new Set(['header', 'footer']);
        turndownService.remove(function (node, options) {
            if (node.nodeName === 'DIV') {
                const divcls = node.getAttribute('class');
                if (divcls && ignoreDivClass.has(divcls)) {
                    return true;
                }
            }
            return false;
        });
        var md = turndownService.turndown(html);
        const lines = md.split('\n');
        const spaceTrimmedLines = lines.map((line) => line.trimEnd());
        return spaceTrimmedLines.join('\n');
    }

    // This part of the script runs in the browser when the userscript is executed
    if (typeof window !== 'undefined' && window.GM_setClipboard) {
        // If there is a selection, convert it. Otherwise, convert the whole body.
        const selection = window.getSelection().toString();
        let markdownContent;
        const turndownService = new TurndownService();

        if (selection) {
            markdownContent = turndownService.turndown(selection);
        } else {
            const mainContent = document.getElementById('content') || document.body;
            markdownContent = convertContentToMarkdown(turndownService, mainContent.innerHTML);
        }

        if (markdownContent) {
            GM_setClipboard(markdownContent, "text");
            console.log('Markdown content copied to clipboard.');
        } else {
            console.error('No content found to convert.');
        }
    }

    // Expose the function for testing
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = convertContentToMarkdown;
    }
})();
