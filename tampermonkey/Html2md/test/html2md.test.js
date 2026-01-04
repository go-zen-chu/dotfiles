const TurndownService = require('turndown');
const path = require('path');
const { requireUserscriptModuleInSandbox } = require('../../test-suite/runner/userscript-loader');

const convertContentToMarkdown = requireUserscriptModuleInSandbox(path.join(__dirname, '..', 'Html2md.user.js'));

function createTurndownService() {
    // Make heading output deterministic across turndown versions.
    return new TurndownService({ headingStyle: 'atx' });
}

describe('Html2md Script Tests', () => {

    it('should convert basic HTML to Markdown', () => {
        const turndownService = createTurndownService();
        const html = '<h1>Hello World</h1><p>This is a test.</p>';
        const expectedMarkdown = '# Hello World\n\nThis is a test.';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should convert h1 and p tags correctly');
    });

    it('should remove script and style tags', () => {
        const turndownService = createTurndownService();
        const html = '<style>p { color: red; }</style><h1>Title</h1><script>alert("foo")</script>';
        const expectedMarkdown = '# Title';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should remove script and style tags');
    });

    it('should remove div elements with header or footer classes', () => {
        const turndownService = createTurndownService();
        const html = '<div class="header">Header content</div><p>Main content</p><div class="footer">Footer content</div>';
        const expectedMarkdown = 'Main content';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should remove header and footer divs');
    });

    it('should trim trailing whitespace from each line', () => {
        const turndownService = createTurndownService();
        const html = '<p>Line 1   </p>\n<p>Line 2\t</p>';
        const expectedMarkdown = 'Line 1\n\nLine 2';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should trim trailing whitespace');
    });

    it('should handle nested HTML elements', () => {
        const turndownService = createTurndownService();
        const html = '<div><p><strong>Bold text</strong> and <em>italic text</em></p></div>';
        const expectedMarkdown = '**Bold text** and _italic text_';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should handle nested elements correctly');
    });

    it('should return an empty string for empty input', () => {
        const turndownService = createTurndownService();
        const html = '';
        const expectedMarkdown = '';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should return empty string for empty input');
    });
});
