/**
 * Test cases for CredentialsAlert.user.js
 * Tests credential detection functionality in various scenarios
 */

const path = require('path');
const { installDomGlobals } = require('../../test-suite/runner/dom-globals');
const { loadUserscriptBody, evalUserscript } = require('../../test-suite/runner/userscript-loader');

/**
 * Loads and prepares the CredentialsAlert script for testing
 */
const scriptBody = loadUserscriptBody(path.join(__dirname, '..', 'CredentialsAlert.user.js'));

describe('CredentialsAlert Script Tests', () => {
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
     * Executes the CredentialsAlert script in the test environment
     */
    function executeCredentialsAlertScript() {
        evalUserscript(scriptBody);
    }

    /**
     * Creates and configures an input element for testing
     */
    function createTestInputElement() {
        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);
        return input;
    }

    /**
     * Creates and configures a contenteditable element for testing
     */
    function createTestContentEditableElement() {
        const div = document.createElement('div');
        div.contentEditable = true;
        body.appendChild(div);
        return div;
    }

    /**
     * Simulates user input on an input element with debounce consideration
     */
    function simulateUserInput(element, value) {
        element.value = value;
        const event = new window.Event('input', { bubbles: true });
        element.dispatchEvent(event);
    }

    /**
     * Simulates user input on a contenteditable element with debounce consideration
     */
    function simulateContentEditableInput(element, text) {
        element.innerText = text;
        const event = new window.Event('input', { bubbles: true });
        element.dispatchEvent(event);
    }

    /**
     * Waits for debounced operations to complete
     */
    function waitForDebounce(ms = 350) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Gets the credential alert element from the DOM
     */
    function getCredentialAlert() {
        return document.getElementById('credential-alert');
    }

    /**
     * Removes existing credential alert if present
     */
    function clearExistingAlert() {
        const alert = getCredentialAlert();
        if (alert) {
            alert.remove();
        }
    }

    it('If credential keywords are detected in input, it should display warning alert', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'my password is secret');

        // Wait for debounce to complete
        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should exist when credential keyword is detected');
        assertTrue(alert.textContent.includes('password'), 'Alert message should contain detected keyword');
        assertEqual(alert.style.backgroundColor, 'rgb(255, 0, 0)', 'Alert background should be red');
        assertEqual(alert.style.display, 'block', 'Alert should be visible');
    });

    it('If no credential keywords are detected, it should not display warning alert', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'hello world');

        // Wait for debounce to complete
        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Alert element should exist but be hidden');
        assertEqual(alert.style.display, 'none', 'Alert should be hidden when no credential keywords are detected');
    });

    it('If credential keywords are in uppercase, it should detect them case-insensitively', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'My PASSWORD is here');

        // Wait for debounce to complete
        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed even for uppercase keywords');
        assertEqual(alert.style.display, 'block', 'Alert should be visible for uppercase keywords');
    });

    it('If different credential keywords are used, it should detect all of them', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // Test token detection
        simulateUserInput(input, 'api token here');
        await waitForDebounce();
        let alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for token keyword');
        assertEqual(alert.style.display, 'block', 'Alert should be visible for token keyword');

        // Test secret detection (no need to clear, just change input)
        simulateUserInput(input, 'this is secret');
        await waitForDebounce();
        alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for secret keyword');
        assertEqual(alert.style.display, 'block', 'Alert should be visible for secret keyword');
    });

    it('If suspicious patterns like API keys or JWT tokens are detected, it should display warning', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // Test API key detection
        simulateUserInput(input, 'my api_key is here');
        await waitForDebounce();
        let alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for API key pattern');
        assertEqual(alert.style.display, 'block', 'Alert should be visible for API key pattern');

        // Test JWT token detection
        simulateUserInput(input, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
        await waitForDebounce();
        alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for JWT token pattern');
        assertEqual(alert.style.display, 'block', 'Alert should be visible for JWT token pattern');
    });

    it('If credentials are entered in contenteditable elements, it should detect them', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const contentEditableDiv = createTestContentEditableElement();
        simulateContentEditableInput(contentEditableDiv, 'password123');

        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for contenteditable elements');
        assertEqual(alert.style.display, 'block', 'Alert should be visible for contenteditable elements');
    });

    it('If safe text is entered after credentials, it should remove the warning alert', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // First display warning
        simulateUserInput(input, 'password');
        await waitForDebounce();
        let alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed initially');
        assertEqual(alert.style.display, 'block', 'Alert should be visible initially');

        // Then enter safe text
        simulateUserInput(input, 'safe text');
        await waitForDebounce();
        alert = getCredentialAlert();
        assertExists(alert, 'Alert element should still exist');
        assertEqual(alert.style.display, 'none', 'Alert should be hidden when safe text is entered');
    });

    it('If warning alert is displayed, it should have correct styling properties', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'token');

        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert element should exist');
        assertEqual(alert.className, 'credential-alert', 'Alert should have correct CSS class');
        assertTrue(alert.style.fontWeight.includes('bold'), 'Alert text should be bold');
        assertEqual(alert.style.backgroundColor, 'rgb(255, 0, 0)', 'Alert background should be red');
        assertEqual(alert.style.color, 'rgb(255, 255, 255)', 'Alert text should be white');
        assertEqual(alert.style.display, 'block', 'Alert should be visible');
    });

    it('If warning alert is triggered, it should be inserted at the top of the page', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        // Add existing content to body
        const existingDiv = document.createElement('div');
        existingDiv.textContent = 'existing content';
        body.appendChild(existingDiv);

        const input = createTestInputElement();
        simulateUserInput(input, 'secret');

        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert element should exist');
        assertEqual(body.firstChild, alert, 'Alert should be inserted as the first child element');
        assertEqual(alert.style.display, 'block', 'Alert should be visible');
    });

    it('If very short input is provided, it should skip processing for performance', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'pa'); // Less than 3 characters

        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Alert element should exist but be hidden');
        assertEqual(alert.style.display, 'none', 'Alert should be hidden for very short inputs');
    });

    it('If debounced input events occur rapidly, it should only process the final input', async () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // Simulate rapid typing
        simulateUserInput(input, 'p');
        simulateUserInput(input, 'pa');
        simulateUserInput(input, 'pas');
        simulateUserInput(input, 'pass');
        simulateUserInput(input, 'password'); // Final input contains credential

        // Wait for debounce to complete
        await waitForDebounce();

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should exist after debounce completes');
        assertEqual(alert.style.display, 'block', 'Alert should be visible for final credential input');
    });

    it('If alert element is reused, it should maintain performance by avoiding DOM recreation', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // Get initial alert element reference
        const initialAlert = getCredentialAlert();
        assertExists(initialAlert, 'Alert element should be created during initialization');
        assertEqual(initialAlert.style.display, 'none', 'Alert should be initially hidden');

        // Trigger alert display
        simulateUserInput(input, 'password');

        // Get alert element reference after triggering
        const triggeredAlert = getCredentialAlert();
        assertEqual(initialAlert, triggeredAlert, 'Alert element should be reused, not recreated');
    });
});
