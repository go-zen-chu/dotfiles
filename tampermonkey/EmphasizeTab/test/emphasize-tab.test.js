/**
 * Test cases for EmphasizeTab.user.js
 * Blinks tab title on /edit pages
 */

const path = require('path');
const { installDomGlobals } = require('../../test-suite/runner/dom-globals');
const { loadUserscriptBody, evalUserscript } = require('../../test-suite/runner/userscript-loader');

const scriptBody = loadUserscriptBody(path.join(__dirname, '..', 'EmphasizeTab.user.js'));

describe('EmphasizeTab Script Tests', () => {
    const TITLE_BLINK_TEXT = '● 編集中';

    function setupTestEnvironment({ url }) {
        const { JSDOM } = require('jsdom');
        const dom = new JSDOM(
            '<!DOCTYPE html><html><head><title>Original Title</title></head><body></body></html>',
            { url },
        );

        installDomGlobals(dom.window);

        const intervals = [];
        const cleared = new Set();

        dom.window.setInterval = (callback, delay) => {
            intervals.push({ callback, delay, active: true });
            return intervals.length - 1;
        };

        dom.window.clearInterval = (id) => {
            if (intervals[id]) {
                intervals[id].active = false;
            }
            cleared.add(id);
        };

        return { dom, intervals, cleared };
    }

    function executeScript() {
        evalUserscript(scriptBody);
    }

    it('Non-edit path should not start title blinking', () => {
        const { intervals } = setupTestEnvironment({ url: 'https://example.test/view' });
        const originalTitle = document.title;
        executeScript();

        assertEqual(intervals.length, 0);
        assertEqual(document.title, originalTitle);
    });

    it('Edit path should start title blinking and toggle title', () => {
        const { intervals } = setupTestEnvironment({ url: 'https://example.test/edit' });
        const originalTitle = document.title;
        executeScript();

        assertEqual(intervals.length, 1);
        intervals[0].callback();
        assertEqual(document.title, TITLE_BLINK_TEXT);

        intervals[0].callback();
        assertEqual(document.title, originalTitle);
    });

    it('Should be idempotent (no duplicate blinking interval)', () => {
        const { intervals } = setupTestEnvironment({ url: 'https://example.test/edit' });
        executeScript();

        window.history.replaceState({}, '', '/edit');

        assertEqual(intervals.length, 1);
    });

    it('Entering edit path via pushState should start blinking', () => {
        const { intervals } = setupTestEnvironment({ url: 'https://example.test/view' });
        executeScript();

        window.history.pushState({}, '', '/edit');

        assertEqual(intervals.length, 1);
    });

    it('Leaving edit path should stop blinking and restore title', () => {
        const { intervals, cleared } = setupTestEnvironment({ url: 'https://example.test/edit' });
        const originalTitle = document.title;
        executeScript();

        intervals[0].callback();
        assertEqual(document.title, TITLE_BLINK_TEXT);

        window.history.pushState({}, '', '/view');

        assertTrue(cleared.has(0));
        assertEqual(document.title, originalTitle);
    });
});
