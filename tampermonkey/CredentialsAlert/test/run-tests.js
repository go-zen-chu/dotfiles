#!/usr/bin/env node

/**
 * Test execution script for CredentialsAlert
 * Runs tests in jsdom environment
 */

const path = require('path');

// Load test runner
const testRunner = require('./test-runner');

console.log('🚀 CredentialsAlert Test Suite Started');
console.log('='.repeat(50));

try {
    // Load and execute test files
    require('./credentials-alert.test.js');

    // Display test results
    const success = testRunner.printResults();

    // Set exit code for CI
    process.exit(success ? 0 : 1);

} catch (error) {
    console.error('❌ Error occurred during test execution:');
    console.error(error.message);
    console.error(error.stack);
    process.exit(1);
}
