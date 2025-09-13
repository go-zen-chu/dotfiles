/**
 * 軽量テストフレームワーク
 * 外部ライブラリに依存しないシンプルなテストランナー
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

    describe(suiteName, fn) {
        this.currentSuite = suiteName;
        console.log(`\n📋 ${suiteName}`);
        fn();
        this.currentSuite = null;
    }

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

    printResults() {
        console.log('\n' + '='.repeat(50));
        console.log('📊 テスト結果');
        console.log('='.repeat(50));
        console.log(`総テスト数: ${this.results.total}`);
        console.log(`成功: ${this.results.passed}`);
        console.log(`失敗: ${this.results.failed}`);

        if (this.results.failed === 0) {
            console.log('🎉 すべてのテストが成功しました！');
            return true;
        } else {
            console.log('💥 一部のテストが失敗しました');
            return false;
        }
    }
}

// グローバルなテストランナーインスタンス
const testRunner = new TestRunner();

// グローバル関数として公開
global.describe = testRunner.describe.bind(testRunner);
global.it = testRunner.it.bind(testRunner);
global.assert = testRunner.assert.bind(testRunner);
global.assertEqual = testRunner.assertEqual.bind(testRunner);
global.assertTrue = testRunner.assertTrue.bind(testRunner);
global.assertFalse = testRunner.assertFalse.bind(testRunner);
global.assertExists = testRunner.assertExists.bind(testRunner);
global.assertNotExists = testRunner.assertNotExists.bind(testRunner);

module.exports = testRunner;
