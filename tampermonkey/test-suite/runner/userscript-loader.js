'use strict';

const fs = require('fs');
const path = require('path');
const vm = require('vm');

function stripUserscriptHeader(scriptContent) {
    return String(scriptContent).replace(/\/\/ ==UserScript==[\s\S]*?\/\/ ==\/UserScript==\s*/, '');
}

function loadUserscriptBody(scriptPath) {
    const abs = path.resolve(scriptPath);
    const content = fs.readFileSync(abs, 'utf8');
    return stripUserscriptHeader(content);
}

function evalUserscript(scriptBody) {
    const body = String(scriptBody);
    // Indirect eval: execute in global scope
    (0, eval)(body);
}

function requireUserscriptModule(scriptPath) {
    const abs = path.resolve(scriptPath);
    // Ensure fresh load per test run
    delete require.cache[abs];
    return require(abs);
}

function requireUserscriptModuleInSandbox(scriptPath) {
    const abs = path.resolve(scriptPath);
    const scriptContent = fs.readFileSync(abs, 'utf8');

    const module = { exports: {} };
    const sandbox = {
        module,
        exports: module.exports,
        require,
        __filename: abs,
        __dirname: path.dirname(abs),
        console,
        process,
        Buffer,
        setTimeout,
        clearTimeout,
        setInterval,
        clearInterval
    };

    vm.createContext(sandbox);
    const wrapped = `(function (exports, require, module, __filename, __dirname) {\n${scriptContent}\n})`;
    const fn = vm.runInContext(wrapped, sandbox, { filename: abs });
    fn(sandbox.exports, sandbox.require, sandbox.module, sandbox.__filename, sandbox.__dirname);
    return sandbox.module.exports;
}

module.exports = {
    stripUserscriptHeader,
    loadUserscriptBody,
    evalUserscript,
    requireUserscriptModule,
    requireUserscriptModuleInSandbox
};
