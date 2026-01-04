'use strict';

function installDomGlobals(window) {
    if (!window) {
        throw new Error('installDomGlobals(window) requires a window');
    }

    global.window = window;
    global.document = window.document;

    if (window.Event) global.Event = window.Event;
    if (window.CustomEvent) global.CustomEvent = window.CustomEvent;
    if (window.MutationObserver) global.MutationObserver = window.MutationObserver;

    return window;
}

module.exports = { installDomGlobals };
