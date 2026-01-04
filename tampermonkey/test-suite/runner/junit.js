'use strict';

const fs = require('fs');
const path = require('path');

function escapeXml(value) {
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
}

function writeJUnitXml({
    outputPath,
    suiteName,
    total,
    failed,
    passed,
    durationMs,
    failures
}) {
    const timeSeconds = (durationMs / 1000).toFixed(3);
    const tsName = escapeXml(suiteName);

    let xml = '';
    xml += '<?xml version="1.0" encoding="UTF-8"?>\n';
    xml += `<testsuite name="${tsName}" tests="${total}" failures="${failed}" errors="0" skipped="0" time="${timeSeconds}">\n`;

    for (const f of failures) {
        const classname = escapeXml(f.suiteName || suiteName);
        const name = escapeXml(f.testName);
        const message = escapeXml(f.message || 'Test failed');
        const stack = f.stack ? escapeXml(f.stack) : '';

        xml += `  <testcase classname="${classname}" name="${name}" time="0">\n`;
        xml += `    <failure message="${message}">${stack}</failure>\n`;
        xml += '  </testcase>\n';
    }

    // For passed tests, we don't currently emit testcase entries.
    // This keeps the file small and still compatible with many reporters.
    xml += '</testsuite>\n';

    const abs = path.resolve(outputPath);
    fs.writeFileSync(abs, xml, 'utf8');
}

module.exports = { writeJUnitXml };
