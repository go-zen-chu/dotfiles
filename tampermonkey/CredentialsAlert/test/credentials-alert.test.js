/**
 * Test cases for CredentialsAlert.user.js
 * Tests credential detection functionality in various scenarios
 */

const fs = require('fs');
const path = require('path');

/**
 * Loads and prepares the CredentialsAlert script for testing
 */
function loadCredentialsAlertScript() {
    const scriptPath = path.join(__dirname, '..', 'CredentialsAlert.user.js');
    const scriptContent = fs.readFileSync(scriptPath, 'utf8');
    return scriptContent.replace(/\/\/ ==UserScript==[\s\S]*?\/\/ ==\/UserScript==\s*/, '');
}

const scriptBody = loadCredentialsAlertScript();

describe('CredentialsAlert Script Tests', () => {
    let document, window, body;

    /**
     * Sets up DOM environment for testing using jsdom
     */
    function setupTestEnvironment() {
        const { JSDOM } = require('jsdom');
        const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>');

        global.window = dom.window;
        global.document = dom.window.document;
        global.Event = dom.window.Event;
        global.CustomEvent = dom.window.CustomEvent;

        document = global.document;
        window = global.window;
        body = document.querySelector('body');

        return { document, window, body };
    }

    /**
     * Executes the CredentialsAlert script in the test environment
     */
    function executeCredentialsAlertScript() {
        eval(scriptBody);
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
     * Simulates user input on an input element
     */
    function simulateUserInput(element, value) {
        element.value = value;
        const event = new window.Event('input', { bubbles: true });
        element.dispatchEvent(event);
    }

    /**
     * Simulates user input on a contenteditable element
     */
    function simulateContentEditableInput(element, text) {
        element.innerText = text;
        const event = new window.Event('input', { bubbles: true });
        element.dispatchEvent(event);
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

    it('If credential keywords are detected in input, it should display warning alert', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'my password is secret');

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should exist when credential keyword is detected');
        assertTrue(alert.textContent.includes('password'), 'Alert message should contain detected keyword');
        assertEqual(alert.style.backgroundColor, 'rgb(255, 0, 0)', 'Alert background should be red');
    });

    it('If no credential keywords are detected, it should not display warning alert', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'hello world');

        const alert = getCredentialAlert();
        assertNotExists(alert, 'Warning alert should not exist when no credential keywords are detected');
    });

    it('If credential keywords are in uppercase, it should detect them case-insensitively', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'My PASSWORD is here');

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed even for uppercase keywords');
    });

    it('If different credential keywords are used, it should detect all of them', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // Test token detection
        simulateUserInput(input, 'api token here');
        let alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for token keyword');

        clearExistingAlert();

        // Test secret detection
        simulateUserInput(input, 'this is secret');
        alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for secret keyword');
    });

    it('If suspicious patterns like API keys or JWT tokens are detected, it should display warning', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // Test API key detection
        simulateUserInput(input, 'my api_key is here');
        let alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for API key pattern');

        clearExistingAlert();

        // Test JWT token detection
        simulateUserInput(input, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
        alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for JWT token pattern');
    });

    it('If credentials are entered in contenteditable elements, it should detect them', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const contentEditableDiv = createTestContentEditableElement();
        simulateContentEditableInput(contentEditableDiv, 'password123');

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed for contenteditable elements');
    });

    it('If safe text is entered after credentials, it should remove the warning alert', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();

        // First display warning
        simulateUserInput(input, 'password');
        let alert = getCredentialAlert();
        assertExists(alert, 'Warning alert should be displayed initially');

        // Then enter safe text
        simulateUserInput(input, 'safe text');
        alert = getCredentialAlert();
        assertNotExists(alert, 'Warning alert should be removed when safe text is entered');
    });

    it('If warning alert is displayed, it should have correct styling properties', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        const input = createTestInputElement();
        simulateUserInput(input, 'token');

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert element should exist');
        assertEqual(alert.className, 'credential-alert', 'Alert should have correct CSS class');
        assertTrue(alert.style.fontWeight.includes('bold'), 'Alert text should be bold');
        assertEqual(alert.style.backgroundColor, 'rgb(255, 0, 0)', 'Alert background should be red');
        assertEqual(alert.style.color, 'rgb(255, 255, 255)', 'Alert text should be white');
    });

    it('If warning alert is triggered, it should be inserted at the top of the page', () => {
        setupTestEnvironment();
        executeCredentialsAlertScript();

        // Add existing content to body
        const existingDiv = document.createElement('div');
        existingDiv.textContent = 'existing content';
        body.appendChild(existingDiv);

        const input = createTestInputElement();
        simulateUserInput(input, 'secret');

        const alert = getCredentialAlert();
        assertExists(alert, 'Warning alert element should exist');
        assertEqual(body.firstChild, alert, 'Alert should be inserted as the first child element');
    });
});
