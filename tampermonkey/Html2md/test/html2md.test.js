const TurndownService = require('turndown');
// Since the script exports the function, we can require it directly.
const convertContentToMarkdown = require('../Html2md.user.js');

describe('Html2md Script Tests', () => {

    it('should convert basic HTML to Markdown', () => {
        const turndownService = new TurndownService();
        const html = '<h1>Hello World</h1><p>This is a test.</p>';
        const expectedMarkdown = '# Hello World\n\nThis is a test.';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should convert h1 and p tags correctly');
    });

    it('should remove script and style tags', () => {
        const turndownService = new TurndownService();
        const html = '<style>p { color: red; }</style><h1>Title</h1><script>alert("foo")</script>';
        const expectedMarkdown = '# Title';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should remove script and style tags');
    });

    it('should remove div elements with header or footer classes', () => {
        const turndownService = new TurndownService();
        const html = '<div class="header">Header content</div><p>Main content</p><div class="footer">Footer content</div>';
        const expectedMarkdown = 'Main content';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should remove header and footer divs');
    });

    it('should trim trailing whitespace from each line', () => {
        const turndownService = new TurndownService();
        const html = '<p>Line 1   </p>\n<p>Line 2\t</p>';
        const expectedMarkdown = 'Line 1\n\nLine 2';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should trim trailing whitespace');
    });

    it('should handle nested HTML elements', () => {
        const turndownService = new TurndownService();
        const html = '<div><p><strong>Bold text</strong> and <em>italic text</em></p></div>';
        const expectedMarkdown = '**Bold text** and _italic text_';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should handle nested elements correctly');
    });

    it('should return an empty string for empty input', () => {
        const turndownService = new TurndownService();
        const html = '';
        const expectedMarkdown = '';
        const result = convertContentToMarkdown(turndownService, html);
        assertEqual(result, expectedMarkdown, 'Should return empty string for empty input');
    });
});
