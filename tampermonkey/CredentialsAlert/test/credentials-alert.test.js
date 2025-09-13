/**
 * CredentialsAlert.user.js のテストケース
 */

const fs = require('fs');
const path = require('path');

// CredentialsAlertスクリプトを読み込み
const scriptPath = path.join(__dirname, '..', 'CredentialsAlert.user.js');
const scriptContent = fs.readFileSync(scriptPath, 'utf8');

// UserScriptヘッダーを除去してスクリプト本体のみを取得
const scriptBody = scriptContent.replace(/\/\/ ==UserScript==[\s\S]*?\/\/ ==\/UserScript==\s*/, '');

describe('CredentialsAlert スクリプトテスト', () => {
    let document, window, body;

    // 各テスト前にDOM環境をセットアップ
    function setupDOM() {
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

    // スクリプトを実行
    function executeScript() {
        // スクリプトをevalで実行（IIFEなので即座に実行される）
        eval(scriptBody);
    }

    // 入力イベントをシミュレート
    function simulateInput(element, value) {
        element.value = value;
        const event = new window.Event('input', { bubbles: true });
        element.dispatchEvent(event);
    }

    // contenteditable要素の入力をシミュレート
    function simulateContentEditableInput(element, text) {
        element.innerText = text;
        const event = new window.Event('input', { bubbles: true });
        element.dispatchEvent(event);
    }

    it('検出単語が含まれる場合に警告が表示される', () => {
        setupDOM();
        executeScript();

        // input要素を作成
        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        // "password"を入力
        simulateInput(input, 'my password is secret');

        // 警告要素が表示されることを確認
        const alert = document.getElementById('credential-alert');
        assertExists(alert, '警告要素が存在すること');
        assertTrue(alert.textContent.includes('password'), '警告メッセージにpasswordが含まれること');
        assertEqual(alert.style.backgroundColor, 'rgb(255, 0, 0)', '背景色が赤であること');
    });

    it('検出単語が含まれない場合に警告が表示されない', () => {
        setupDOM();
        executeScript();

        // input要素を作成
        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        // 通常のテキストを入力
        simulateInput(input, 'hello world');

        // 警告要素が表示されないことを確認
        const alert = document.getElementById('credential-alert');
        assertNotExists(alert, '警告要素が存在しないこと');
    });

    it('大文字小文字を区別せずに検出する', () => {
        setupDOM();
        executeScript();

        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        // 大文字で入力
        simulateInput(input, 'My PASSWORD is here');

        const alert = document.getElementById('credential-alert');
        assertExists(alert, '大文字のPASSWORDでも警告が表示されること');
    });

    it('複数の検出単語をテストする', () => {
        setupDOM();
        executeScript();

        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        // token を含むテキスト
        simulateInput(input, 'api token here');
        let alert = document.getElementById('credential-alert');
        assertExists(alert, 'tokenで警告が表示されること');

        // 警告をクリア
        if (alert) alert.remove();

        // secret を含むテキスト
        simulateInput(input, 'this is secret');
        alert = document.getElementById('credential-alert');
        assertExists(alert, 'secretで警告が表示されること');
    });

    it('疑わしい単語（doutfulWords）でも検出する', () => {
        setupDOM();
        executeScript();

        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        // api_key を含むテキスト
        simulateInput(input, 'my api_key is here');
        let alert = document.getElementById('credential-alert');
        assertExists(alert, 'api_keyで警告が表示されること');

        // 警告をクリア
        if (alert) alert.remove();

        // JWT形式の文字列
        simulateInput(input, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
        alert = document.getElementById('credential-alert');
        assertExists(alert, 'JWT形式の文字列で警告が表示されること');
    });

    it('contenteditable要素でも動作する', () => {
        setupDOM();
        executeScript();

        const div = document.createElement('div');
        div.contentEditable = true;
        body.appendChild(div);

        // contenteditable要素に入力
        simulateContentEditableInput(div, 'password123');

        const alert = document.getElementById('credential-alert');
        assertExists(alert, 'contenteditable要素でも警告が表示されること');
    });

    it('警告が削除される', () => {
        setupDOM();
        executeScript();

        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        // まず警告を表示
        simulateInput(input, 'password');
        let alert = document.getElementById('credential-alert');
        assertExists(alert, '警告が表示されること');

        // 安全なテキストに変更
        simulateInput(input, 'safe text');
        alert = document.getElementById('credential-alert');
        assertNotExists(alert, '警告が削除されること');
    });

    it('警告要素のスタイルが正しく設定される', () => {
        setupDOM();
        executeScript();

        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        simulateInput(input, 'token');

        const alert = document.getElementById('credential-alert');
        assertExists(alert, '警告要素が存在すること');
        assertEqual(alert.className, 'credential-alert', 'クラス名が正しいこと');
        assertTrue(alert.style.fontWeight.includes('bold'), 'フォントが太字であること');
        assertEqual(alert.style.backgroundColor, 'rgb(255, 0, 0)', '背景色が赤であること');
        assertEqual(alert.style.color, 'rgb(255, 255, 255)', '文字色が白であること');
    });

    it('警告が画面上部に挿入される', () => {
        setupDOM();
        executeScript();

        // body に既存の要素を追加
        const existingDiv = document.createElement('div');
        existingDiv.textContent = 'existing content';
        body.appendChild(existingDiv);

        const input = document.createElement('input');
        input.type = 'text';
        body.appendChild(input);

        simulateInput(input, 'secret');

        const alert = document.getElementById('credential-alert');
        assertExists(alert, '警告要素が存在すること');
        assertEqual(body.firstChild, alert, '警告が最初の子要素として挿入されること');
    });
});
