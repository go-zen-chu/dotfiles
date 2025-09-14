/**
 * Test runner for HideAmazonAds.user.js
 * Executes all test cases and reports results
 */

const testRunner = require('./test-runner');

// Load and execute test cases
require('./hide-amazon-ads.test');

// Print final results and exit with appropriate code
const success = testRunner.printResults();
process.exit(success ? 0 : 1);
