/**
 * Test cases for HideAmazonAds.user.js
 * Tests sponsored ad removal functionality in various scenarios
 */

const path = require('path');
const { installDomGlobals } = require('../../test-suite/runner/dom-globals');
const { loadUserscriptBody, evalUserscript } = require('../../test-suite/runner/userscript-loader');

/**
 * Loads and prepares the HideAmazonAds script for testing
 */
const scriptBody = loadUserscriptBody(path.join(__dirname, '..', 'HideAmazonAds.user.js'));

describe('HideAmazonAds Script Tests', () => {
    let document, window, body;

    /**
     * Sets up DOM environment for testing using jsdom
     */
    function setupTestEnvironment() {
        const { JSDOM } = require('jsdom');
        const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>');

        installDomGlobals(dom.window);

        document = global.document;
        window = global.window;
        body = document.querySelector('body');

        return { document, window, body };
    }

    /**
     * Executes the HideAmazonAds script in the test environment
     */
    function executeHideAmazonAdsScript() {
        evalUserscript(scriptBody);
    }

    /**
     * Creates a sponsored ad element similar to Amazon's structure
     */
    function createSponsoredAdElement() {
        const listItem = document.createElement('div');
        listItem.setAttribute('role', 'listitem');
        listItem.setAttribute('data-asin', 'B0TEST123');
        listItem.setAttribute('data-index', '1');
        listItem.className = 'sg-col-4-of-4 sg-col-4-of-24 sg-col-4-of-12 s-result-item s-asin sg-col-4-of-16 AdHolder sg-col s-widget-spacing-small sg-col-4-of-8 sg-col-4-of-20';

        const innerDiv = document.createElement('div');
        innerDiv.className = 'sg-col-inner';

        const sponsoredLabel = document.createElement('span');
        sponsoredLabel.className = 'puis-sponsored-label-text';
        sponsoredLabel.textContent = 'スポンサー';

        innerDiv.appendChild(sponsoredLabel);
        listItem.appendChild(innerDiv);
        body.appendChild(listItem);

        return listItem;
    }

    /**
     * Creates a regular (non-sponsored) ad element
     */
    function createRegularAdElement() {
        const listItem = document.createElement('div');
        listItem.setAttribute('role', 'listitem');
        listItem.setAttribute('data-asin', 'B0REGULAR123');
        listItem.setAttribute('data-index', '2');
        listItem.className = 'sg-col-4-of-4 sg-col-4-of-24 sg-col-4-of-12 s-result-item s-asin sg-col-4-of-16 sg-col s-widget-spacing-small sg-col-4-of-8 sg-col-4-of-20';

        const innerDiv = document.createElement('div');
        innerDiv.className = 'sg-col-inner';

        const productTitle = document.createElement('h2');
        productTitle.textContent = 'Regular Product Title';

        innerDiv.appendChild(productTitle);
        listItem.appendChild(innerDiv);
        body.appendChild(listItem);

        return listItem;
    }

    /**
     * Creates an empty listitem element (like the one in removed.html)
     */
    function createEmptyListItemElement() {
        const listItem = document.createElement('div');
        listItem.setAttribute('role', 'listitem');
        listItem.setAttribute('data-asin', 'B0EMPTY123');
        listItem.setAttribute('data-index', '3');
        listItem.className = 'sg-col-4-of-4 sg-col-4-of-24 sg-col-4-of-12 s-result-item s-asin sg-col-4-of-16 AdHolder sg-col s-widget-spacing-small sg-col-4-of-8 sg-col-4-of-20';

        const innerDiv = document.createElement('div');
        innerDiv.className = 'sg-col-inner';
        // Empty inner div

        listItem.appendChild(innerDiv);
        body.appendChild(listItem);

        return listItem;
    }

    /**
     * Waits for script execution to complete
     */
    function waitForExecution(ms = 200) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    it('If sponsored ad with puis-sponsored-label-text exists, it should remove the entire listitem container', async () => {
        setupTestEnvironment();

        const sponsoredAd = createSponsoredAdElement();
        const regularAd = createRegularAdElement();

        executeHideAmazonAdsScript();
        await waitForExecution();

        // Sponsored ad should be removed
        assertNotExists(document.querySelector('[data-asin="B0TEST123"]'), 'Sponsored ad listitem should be completely removed');

        // Regular ad should remain
        assertExists(document.querySelector('[data-asin="B0REGULAR123"]'), 'Regular ad should not be removed');
    });

    it('If empty listitem containers exist, it should remove them', async () => {
        setupTestEnvironment();

        const emptyListItem = createEmptyListItemElement();
        const regularAd = createRegularAdElement();

        executeHideAmazonAdsScript();
        await waitForExecution();

        // Empty listitem should be removed
        assertNotExists(document.querySelector('[data-asin="B0EMPTY123"]'), 'Empty listitem should be removed');

        // Regular ad should remain
        assertExists(document.querySelector('[data-asin="B0REGULAR123"]'), 'Regular ad should not be removed');
    });

    it('If AdHolder elements are empty, it should remove them', async () => {
        setupTestEnvironment();

        const adHolder = document.createElement('div');
        adHolder.className = 'AdHolder sg-col-4-of-4';
        adHolder.setAttribute('data-test', 'empty-adholder');

        const innerDiv = document.createElement('div');
        innerDiv.className = 'sg-col-inner';
        // Empty inner div

        adHolder.appendChild(innerDiv);
        body.appendChild(adHolder);

        const regularAd = createRegularAdElement();

        executeHideAmazonAdsScript();
        await waitForExecution();

        // Empty AdHolder should be removed
        assertNotExists(document.querySelector('[data-test="empty-adholder"]'), 'Empty AdHolder should be removed');

        // Regular ad should remain
        assertExists(document.querySelector('[data-asin="B0REGULAR123"]'), 'Regular ad should not be removed');
    });

    it('If element contains "スポンサー" text, it should remove the parent container', async () => {
        setupTestEnvironment();

        const listItem = document.createElement('div');
        listItem.setAttribute('role', 'listitem');
        listItem.setAttribute('data-asin', 'B0TEXTSPONSORED');
        listItem.className = 's-result-item';

        const innerDiv = document.createElement('div');
        innerDiv.className = 'sg-col-inner';
        innerDiv.textContent = 'この商品はスポンサーです';

        listItem.appendChild(innerDiv);
        body.appendChild(listItem);

        const regularAd = createRegularAdElement();

        executeHideAmazonAdsScript();
        await waitForExecution();

        // Text-based sponsored ad should be removed
        assertNotExists(document.querySelector('[data-asin="B0TEXTSPONSORED"]'), 'Text-based sponsored ad should be removed');

        // Regular ad should remain
        assertExists(document.querySelector('[data-asin="B0REGULAR123"]'), 'Regular ad should not be removed');
    });

    it('If multiple sponsored ads exist, it should remove all of them', async () => {
        setupTestEnvironment();

        // Create multiple sponsored ads
        const sponsoredAd1 = createSponsoredAdElement();
        sponsoredAd1.setAttribute('data-asin', 'B0SPONSORED1');

        const sponsoredAd2 = createSponsoredAdElement();
        sponsoredAd2.setAttribute('data-asin', 'B0SPONSORED2');

        const regularAd = createRegularAdElement();

        executeHideAmazonAdsScript();
        await waitForExecution();

        // All sponsored ads should be removed
        assertNotExists(document.querySelector('[data-asin="B0SPONSORED1"]'), 'First sponsored ad should be removed');
        assertNotExists(document.querySelector('[data-asin="B0SPONSORED2"]'), 'Second sponsored ad should be removed');

        // Regular ad should remain
        assertExists(document.querySelector('[data-asin="B0REGULAR123"]'), 'Regular ad should not be removed');
    });

    it('If aria-label contains "スポンサー", it should remove the parent container', async () => {
        setupTestEnvironment();

        const listItem = document.createElement('div');
        listItem.setAttribute('role', 'listitem');
        listItem.setAttribute('data-asin', 'B0ARIALABEL');
        listItem.className = 's-result-item';

        const innerDiv = document.createElement('div');
        innerDiv.className = 'sg-col-inner';

        const sponsoredElement = document.createElement('div');
        sponsoredElement.setAttribute('aria-label', 'スポンサー商品');

        innerDiv.appendChild(sponsoredElement);
        listItem.appendChild(innerDiv);
        body.appendChild(listItem);

        const regularAd = createRegularAdElement();

        executeHideAmazonAdsScript();
        await waitForExecution();

        // Aria-label sponsored ad should be removed
        assertNotExists(document.querySelector('[data-asin="B0ARIALABEL"]'), 'Aria-label sponsored ad should be removed');

        // Regular ad should remain
        assertExists(document.querySelector('[data-asin="B0REGULAR123"]'), 'Regular ad should not be removed');
    });

    it('If script runs multiple times, it should not cause errors or remove regular content', async () => {
        setupTestEnvironment();

        const sponsoredAd = createSponsoredAdElement();
        const regularAd = createRegularAdElement();

        // Execute script multiple times
        executeHideAmazonAdsScript();
        await waitForExecution();

        executeHideAmazonAdsScript();
        await waitForExecution();

        executeHideAmazonAdsScript();
        await waitForExecution();

        // Sponsored ad should be removed
        assertNotExists(document.querySelector('[data-asin="B0TEST123"]'), 'Sponsored ad should be removed after multiple executions');

        // Regular ad should still remain
        assertExists(document.querySelector('[data-asin="B0REGULAR123"]'), 'Regular ad should remain after multiple executions');
    });

    it('If no sponsored content exists, it should not remove any elements', async () => {
        setupTestEnvironment();

        const regularAd1 = createRegularAdElement();
        regularAd1.setAttribute('data-asin', 'B0REGULAR1');

        const regularAd2 = createRegularAdElement();
        regularAd2.setAttribute('data-asin', 'B0REGULAR2');

        executeHideAmazonAdsScript();
        await waitForExecution();

        // All regular ads should remain
        assertExists(document.querySelector('[data-asin="B0REGULAR1"]'), 'First regular ad should remain');
        assertExists(document.querySelector('[data-asin="B0REGULAR2"]'), 'Second regular ad should remain');
    });

    it('If DOM structure matches removed.html example, it should clean up completely', async () => {
        setupTestEnvironment();

        // Create structure similar to removed.html
        const listItem = document.createElement('div');
        listItem.setAttribute('role', 'listitem');
        listItem.setAttribute('data-asin', 'B0C9YYFW4P');
        listItem.setAttribute('data-index', '18');
        listItem.setAttribute('id', '46f1d7f4-4f15-4e2d-9876-11b597454a30');
        listItem.setAttribute('data-component-type', 's-search-result');
        listItem.className = 'sg-col-4-of-4 sg-col-4-of-24 sg-col-4-of-12 s-result-item s-asin sg-col-4-of-16 AdHolder sg-col s-widget-spacing-small sg-col-4-of-8 sg-col-4-of-20';

        const innerDiv = document.createElement('div');
        innerDiv.className = 'sg-col-inner';
        // Empty inner div (as in removed.html)

        listItem.appendChild(innerDiv);
        body.appendChild(listItem);

        executeHideAmazonAdsScript();
        await waitForExecution();

        // The empty listitem should be completely removed
        assertNotExists(document.querySelector('#46f1d7f4-4f15-4e2d-9876-11b597454a30'), 'Empty listitem from removed.html structure should be completely removed');
        assertNotExists(document.querySelector('[data-asin="B0C9YYFW4P"]'), 'Element with specific ASIN should be removed');
    });
});
