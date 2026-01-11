/**
 * Test cases for EmphasizeTab.user.js
 * Emphasizes favicon (GIF data URI) on /edit pages
 */

const path = require('path');
const { installDomGlobals } = require('../../test-suite/runner/dom-globals');
const { loadUserscriptBody, evalUserscript } = require('../../test-suite/runner/userscript-loader');

const scriptBody = loadUserscriptBody(path.join(__dirname, '..', 'EmphasizeTab.user.js'));

describe('EmphasizeTab Script Tests', () => {
    const EMPHASIS_FAVICON_ID = 'emphasize-tab-favicon';
    const DATA_URI_PREFIX = 'data:image/gif;base64,';

    function setupTestEnvironment({ url }) {
        const { JSDOM } = require('jsdom');
        const dom = new JSDOM(
            '<!DOCTYPE html><html><head><title></title><link rel="icon" href="/favicon.ico"></head><body></body></html>',
            { url },
        );

        installDomGlobals(dom.window);

        return dom;
    }

    function executeScript() {
        evalUserscript(scriptBody);
    }

    function getEmphasisFaviconLink() {
        return document.getElementById(EMPHASIS_FAVICON_ID);
    }

    it('Non-edit path should not inject emphasis favicon', () => {
        setupTestEnvironment({ url: 'https://example.test/view' });
        executeScript();

        assertEqual(getEmphasisFaviconLink(), null);
    });

    it('Edit path should inject emphasis favicon (data URI gif)', () => {
        setupTestEnvironment({ url: 'https://example.test/edit' });
        executeScript();

        const link = getEmphasisFaviconLink();
        assertExists(link);
        assertEqual(link.getAttribute('rel'), 'icon');
        assertEqual(link.getAttribute('type'), 'image/gif');
        assertTrue((link.href || '').startsWith(DATA_URI_PREFIX));
    });

    it('Should be idempotent (no duplicate emphasis favicon)', () => {
        setupTestEnvironment({ url: 'https://example.test/edit' });
        executeScript();

        // Trigger applyEmphasis again via history wrapper
        window.history.replaceState({}, '', '/edit');

        const links = Array.from(document.querySelectorAll(`#${EMPHASIS_FAVICON_ID}`));
        assertEqual(links.length, 1);
    });

    it('Entering edit path via pushState should inject emphasis favicon', () => {
        setupTestEnvironment({ url: 'https://example.test/view' });
        executeScript();

        window.history.pushState({}, '', '/edit');

        assertExists(getEmphasisFaviconLink());
    });

    it('Leaving edit path should remove emphasis favicon', () => {
        setupTestEnvironment({ url: 'https://example.test/edit' });
        executeScript();

        window.history.pushState({}, '', '/view');

        assertEqual(getEmphasisFaviconLink(), null);
    });

    it('Keeping edit path should keep emphasis favicon present', () => {
        setupTestEnvironment({ url: 'https://example.test/edit' });
        executeScript();

        const firstHref = getEmphasisFaviconLink().href;

        // Simulate app actions that re-run applyEmphasis while staying on /edit
        window.history.replaceState({}, '', '/edit');

        assertExists(getEmphasisFaviconLink());
        assertEqual(getEmphasisFaviconLink().href, firstHref);
    });
});
