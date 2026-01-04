'use strict';

class TestRunner {
    constructor({ suiteName } = {}) {
        this.suiteName = suiteName || 'tampermonkey';
        this.suiteStack = [];
        this.testCases = [];
        this.results = {
            passed: 0,
            failed: 0,
            total: 0,
            failures: []
        };
    }

    describe(suiteName, fn) {
        this.suiteStack.push(String(suiteName));
        try {
            fn();
        } finally {
            this.suiteStack.pop();
        }
    }

    it(testName, fn) {
        this.testCases.push({
            suitePath: this.suiteStack.slice(),
            testName: String(testName),
            fn
        });
    }

    assert(condition, message = 'Assertion failed') {
        if (!condition) {
            throw new Error(message);
        }
    }

    assertEqual(actual, expected, message) {
        if (actual !== expected) {
            throw new Error(message || `Expected ${expected}, but got ${actual}`);
        }
    }

    assertTrue(condition, message) {
        if (!condition) {
            throw new Error(message || 'Expected true, but got false');
        }
    }

    assertFalse(condition, message) {
        if (condition) {
            throw new Error(message || 'Expected false, but got true');
        }
    }

    assertExists(element, message) {
        if (!element) {
            throw new Error(message || 'Expected element to exist, but it was null/undefined');
        }
    }

    assertNotExists(element, message) {
        if (element) {
            throw new Error(message || 'Expected element to not exist, but it was found');
        }
    }

    getSummary() {
        return { ...this.results };
    }

    async runAll() {
        for (const testCase of this.testCases) {
            this.results.total++;
            const suiteName = testCase.suitePath.join(' / ') || this.suiteName;
            const fullName = testCase.testName;

            try {
                await Promise.resolve().then(() => testCase.fn());
                this.results.passed++;
                console.log(`  ✅ ${fullName}`);
            } catch (error) {
                this.results.failed++;
                const err = error instanceof Error ? error : new Error(String(error));
                this.results.failures.push({
                    suiteName,
                    testName: fullName,
                    message: err.message,
                    stack: err.stack || ''
                });
                console.log(`  ❌ ${fullName}`);
                console.log(`     Error: ${err.message}`);
            }
        }

        return this.results.failed === 0;
    }
}

module.exports = { TestRunner };
