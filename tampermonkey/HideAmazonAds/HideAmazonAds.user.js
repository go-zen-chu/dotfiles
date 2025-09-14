// ==UserScript==
// @name         Hide Amazon sponser link
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Hide sponser ads from amazon list
// @author       go-zen-chu
// @match        https://www.amazon.co.jp/*
// @match        https://amazon.co.jp/*
// @grant        none
// @updateURL    https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/HideAmazonAds/HideAmazonAds.user.js
// @downloadURL  https://github.com/go-zen-chu/dotfiles/raw/refs/heads/master/tampermonkey/HideAmazonAds/HideAmazonAds.user.js
// ==/UserScript==

(function () {
    'use strict';

    function removeSponsoredAds() {
        let removedCount = 0;

        // Find sponsored labels and remove their parent containers
        const sponsoredLabels = document.querySelectorAll('.puis-sponsored-label-text, [aria-label*="スポンサー"]');
        sponsoredLabels.forEach(label => {
            // Try to find the topmost parent container (role="listitem" or AdHolder)
            let parent = label.closest('[role="listitem"], .AdHolder, [data-component-type="s-search-result"], .s-result-item, .s-widget-container');
            if (parent) {
                parent.remove();
                removedCount++;
            }
        });

        // Find elements containing "スポンサー" text and remove their parent containers
        const allElements = document.querySelectorAll('[data-component-type="s-search-result"], .s-result-item, .s-widget-container, [role="listitem"]');
        allElements.forEach(element => {
            const text = element.textContent || '';
            if (text.includes('スポンサー') && element.offsetParent !== null) {
                // Find the topmost parent container
                let topParent = element.closest('[role="listitem"], .AdHolder') || element;
                topParent.remove();
                removedCount++;
            }
        });

        // Clean up empty listitem containers that might be left behind
        const emptyListItems = document.querySelectorAll('[role="listitem"]');
        emptyListItems.forEach(item => {
            // Check if the listitem is empty or only contains empty sg-col-inner
            const innerContent = item.querySelector('.sg-col-inner');
            if (innerContent && (!innerContent.children.length || innerContent.textContent.trim() === '')) {
                item.remove();
                removedCount++;
            }
        });

        // Remove AdHolder elements that are empty or contain only sponsored content
        const adHolders = document.querySelectorAll('.AdHolder');
        adHolders.forEach(holder => {
            const innerContent = holder.querySelector('.sg-col-inner');
            if (!innerContent || innerContent.children.length === 0 || innerContent.textContent.trim() === '') {
                holder.remove();
                removedCount++;
            }
        });

        if (removedCount > 0) {
            console.log(`Removed ${removedCount} sponsored ads and empty containers`);
        }
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', removeSponsoredAds);
    } else {
        removeSponsoredAds();
    }

    const observer = new MutationObserver((mutations) => {
        let shouldRun = false;


        mutations.forEach((mutation) => {
            mutation.addedNodes.forEach((node) => {
                if (node.nodeType === 1 && node.matches && (
                    node.matches('.s-result-item') ||
                    node.matches('.s-widget-container') ||
                    node.matches('[data-component-type="s-search-result"]') ||
                    node.textContent.includes('スポンサー')
                )) {
                    shouldRun = true;
                }
            });
        });

        if (shouldRun) {
            setTimeout(removeSponsoredAds, 100);
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
})();
