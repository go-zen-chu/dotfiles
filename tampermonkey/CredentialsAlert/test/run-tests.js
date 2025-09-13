#!/usr/bin/env node

/**
 * テスト実行スクリプト
 * jsdom環境でCredentialsAlertのテストを実行
 */

const path = require('path');

// テストランナーを読み込み
const testRunner = require('./test-runner');

console.log('🚀 CredentialsAlert テストスイート開始');
console.log('='.repeat(50));

try {
    // テストファイルを読み込んで実行
    require('./credentials-alert.test.js');

    // テスト結果を表示
    const success = testRunner.printResults();

    // 終了コードを設定（CI用）
    process.exit(success ? 0 : 1);

} catch (error) {
    console.error('❌ テスト実行中にエラーが発生しました:');
    console.error(error.message);
    console.error(error.stack);
    process.exit(1);
}
