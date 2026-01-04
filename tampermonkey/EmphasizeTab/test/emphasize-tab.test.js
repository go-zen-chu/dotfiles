/**
 * Test cases for EmphasizeTab.user.js
 * Emphasizes tab title with a prefix on /edit pages
 */

const path = require('path');
const { installDomGlobals } = require('../../test-suite/runner/dom-globals');
const { loadUserscriptBody, evalUserscript } = require('../../test-suite/runner/userscript-loader');

const scriptBody = loadUserscriptBody(path.join(__dirname, '..', 'EmphasizeTab.user.js'));

describe('EmphasizeTab Script Tests', () => {
    const PREFIX = '✏️ ';

    function setupTestEnvironment({ url, title }) {
        const { JSDOM } = require('jsdom');
        const dom = new JSDOM('<!DOCTYPE html><html><head><title></title></head><body></body></html>', { url });

        installDomGlobals(dom.window);

        document.title = title;

        return dom;
    }

    function executeScript() {
        evalUserscript(scriptBody);
    }

    it('Non-edit path should not decorate title', () => {
        setupTestEnvironment({ url: 'https://example.test/view', title: 'Doc' });
        executeScript();

        assertEqual(document.title, 'Doc');
    });

    it('Edit path should decorate title with prefix', () => {
        setupTestEnvironment({ url: 'https://example.test/edit', title: 'Doc' });
        executeScript();

        assertEqual(document.title, PREFIX + 'Doc');
    });

    it('Should be idempotent (no double prefix)', () => {
        setupTestEnvironment({ url: 'https://example.test/edit', title: 'Doc' });
        executeScript();

        // Trigger applyTitle again via history wrapper
        window.history.replaceState({}, '', '/edit');

        assertEqual(document.title, PREFIX + 'Doc');
    });

    it('Entering edit path via pushState should decorate', () => {
        setupTestEnvironment({ url: 'https://example.test/view', title: 'Doc' });
        executeScript();

        window.history.pushState({}, '', '/edit');

        assertEqual(document.title, PREFIX + 'Doc');
    });

    it('Leaving edit path should restore raw title', () => {
        setupTestEnvironment({ url: 'https://example.test/edit', title: 'Doc' });
        executeScript();

        window.history.pushState({}, '', '/view');

        assertEqual(document.title, 'Doc');
    });

    it('If app changes title while editing, it should re-decorate and restore latest raw title after leaving', () => {
        setupTestEnvironment({ url: 'https://example.test/edit', title: 'Doc' });
        executeScript();

        // Simulate app changing title
        document.title = 'New Title';

        // Trigger applyTitle again via history wrapper (same path)
        window.history.replaceState({}, '', '/edit');

        assertEqual(document.title, PREFIX + 'New Title');

        // Leave edit and ensure latest raw title is restored
        window.history.pushState({}, '', '/view');
        assertEqual(document.title, 'New Title');
    });
});
