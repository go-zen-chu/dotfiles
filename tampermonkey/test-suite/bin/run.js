#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const { TestRunner } = require('../runner/test-runner');
const { writeJUnitXml } = require('../runner/junit');

function findTestFiles(rootDir) {
    const results = [];

    function walk(dir) {
        const entries = fs.readdirSync(dir, { withFileTypes: true });
        for (const entry of entries) {
            const full = path.join(dir, entry.name);
            if (entry.isDirectory()) {
                walk(full);
            } else if (entry.isFile() && entry.name.endsWith('.test.js')) {
                results.push(full);
            }
        }
    }

    if (!fs.existsSync(rootDir)) {
        return [];
    }

    walk(rootDir);
    results.sort();
    return results;
}

function readPackageName(cwd) {
    try {
        const pkgPath = path.join(cwd, 'package.json');
        const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf8'));
        return pkg.name || path.basename(cwd);
    } catch {
        return path.basename(cwd);
    }
}

function parseArgs(argv) {
    const args = { junit: 'test-results.xml' };

    for (let i = 2; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--junit') {
            args.junit = argv[++i];
        }
    }

    return args;
}

async function main() {
    const cwd = process.cwd();
    const args = parseArgs(process.argv);
    const suiteName = readPackageName(cwd);

    console.log(`🚀 ${suiteName} Test Suite Started`);
    console.log('='.repeat(50));

    const runner = new TestRunner({ suiteName });

    global.describe = (name, fn) => {
        console.log(`\n📋 ${name}`);
        runner.describe(name, fn);
    };
    global.it = (name, fn) => runner.it(name, fn);

    global.assert = runner.assert.bind(runner);
    global.assertEqual = runner.assertEqual.bind(runner);
    global.assertTrue = runner.assertTrue.bind(runner);
    global.assertFalse = runner.assertFalse.bind(runner);
    global.assertExists = runner.assertExists.bind(runner);
    global.assertNotExists = runner.assertNotExists.bind(runner);

    const testDir = path.join(cwd, 'test');
    const testFiles = findTestFiles(testDir);

    if (testFiles.length === 0) {
        console.log('No test files found.');
        writeJUnitXml({
            outputPath: args.junit,
            suiteName,
            total: 0,
            failed: 0,
            passed: 0,
            durationMs: 0,
            failures: []
        });
        process.exit(0);
    }

    const startedAt = Date.now();

    try {
        for (const file of testFiles) {
            require(file);
        }
    } catch (error) {
        const err = error instanceof Error ? error : new Error(String(error));
        console.error('❌ Error occurred during test load:');
        console.error(err.message);
        console.error(err.stack);

        const durationMs = Date.now() - startedAt;
        writeJUnitXml({
            outputPath: args.junit,
            suiteName,
            total: 0,
            failed: 1,
            passed: 0,
            durationMs,
            failures: [
                {
                    suiteName,
                    testName: 'test load',
                    message: err.message,
                    stack: err.stack || ''
                }
            ]
        });

        process.exit(1);
    }

    const success = await runner.runAll();
    const durationMs = Date.now() - startedAt;

    const summary = runner.getSummary();

    console.log('\n' + '='.repeat(50));
    console.log('📊 Test Results');
    console.log('='.repeat(50));
    console.log(`Total tests: ${summary.total}`);
    console.log(`Passed: ${summary.passed}`);
    console.log(`Failed: ${summary.failed}`);

    writeJUnitXml({
        outputPath: args.junit,
        suiteName,
        total: summary.total,
        failed: summary.failed,
        passed: summary.passed,
        durationMs,
        failures: summary.failures
    });

    if (summary.failed === 0) {
        console.log('🎉 All tests passed!');
    } else {
        console.log('💥 Some tests failed');
    }

    // Force-exit to avoid hanging on leftover timers from userscripts.
    process.exit(success ? 0 : 1);
}

main();
