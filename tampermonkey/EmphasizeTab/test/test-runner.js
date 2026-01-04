/**
 * Lightweight test framework for EmphasizeTab
 * Simple test runner without external library dependencies
 */

class TestRunner {
    constructor() {
        this.tests = [];
        this.currentSuite = null;
        this.results = {
            passed: 0,
            failed: 0,
            total: 0
        };
    }

    /**
     * Groups related test cases under a descriptive suite name
     */
    describe(suiteName, fn) {
        this.currentSuite = suiteName;
        console.log(`\n📋 ${suiteName}`);
        fn();
        this.currentSuite = null;
    }

    /**
     * Executes individual test case and records the result
     */
    it(testName, fn) {
        this.results.total++;
        try {
            fn();
            this.results.passed++;
            console.log(`  ✅ ${testName}`);
        } catch (error) {
            this.results.failed++;
            console.log(`  ❌ ${testName}`);
            console.log(`     Error: ${error.message}`);
        }
    }

    /**
     * Asserts that a condition is true
     */
    assert(condition, message = 'Assertion failed') {
        if (!condition) {
            throw new Error(message);
        }
    }

    /**
     * Asserts that two values are strictly equal
     */
    assertEqual(actual, expected, message) {
        if (actual !== expected) {
            throw new Error(message || `Expected ${expected}, but got ${actual}`);
        }
    }

    /**
     * Asserts that a condition is true
     */
    assertTrue(condition, message) {
        if (!condition) {
            throw new Error(message || 'Expected true, but got false');
        }
    }

    /**
     * Asserts that a condition is false
     */
    assertFalse(condition, message) {
        if (condition) {
            throw new Error(message || 'Expected false, but got true');
        }
    }

    /**
     * Asserts that an element exists (not null or undefined)
     */
    assertExists(element, message) {
        if (!element) {
            throw new Error(message || 'Expected element to exist, but it was null/undefined');
        }
    }

    /**
     * Asserts that an element does not exist (null or undefined)
     */
    assertNotExists(element, message) {
        if (element) {
            throw new Error(message || 'Expected element to not exist, but it was found');
        }
    }

    /**
     * Prints test execution results and returns success status
     */
    printResults() {
        console.log('\n' + '='.repeat(50));
        console.log('📊 Test Results');
        console.log('='.repeat(50));
        console.log(`Total tests: ${this.results.total}`);
        console.log(`Passed: ${this.results.passed}`);
        console.log(`Failed: ${this.results.failed}`);

        if (this.results.failed === 0) {
            console.log('🎉 All tests passed!');
            return true;
        } else {
            console.log('💥 Some tests failed');
            return false;
        }
    }
}

const testRunner = new TestRunner();

global.describe = testRunner.describe.bind(testRunner);
global.it = testRunner.it.bind(testRunner);
global.assert = testRunner.assert.bind(testRunner);
global.assertEqual = testRunner.assertEqual.bind(testRunner);
global.assertTrue = testRunner.assertTrue.bind(testRunner);
global.assertFalse = testRunner.assertFalse.bind(testRunner);
global.assertExists = testRunner.assertExists.bind(testRunner);
global.assertNotExists = testRunner.assertNotExists.bind(testRunner);

module.exports = testRunner;
