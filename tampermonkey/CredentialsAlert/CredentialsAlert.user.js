// ==UserScript==
// @name         ContainsCredentialsAlert
// @namespace    github.com/go-zen-chu
// @version      0.1
// @description  Watch out! You might input credentials!
// @author       Akira Masuda
// @licence      MIT
// @match        https://*/*
// @icon         https://img.icons8.com/?size=64&id=82753&format=png
// @grant        none
// ==/UserScript==

(function () {
    'use strict';
    const detectWords = ["password", "token", "secret"];
    // may be credentials
    const doutfulWords = [
        // private key
        "begin private key", "begin rsa private key", "begin openssh private key",
        // jwt
        "eyjhbgci",
        // base64 encoded string (easily decoded)
        "ls0tls1", "cg==",
        "api_key", "secret_key",
        "connection_string",
    ]

    const body = document.querySelector("body")
    const new_element = document.createElement('div');
    new_element.textContent = 'WARNING!!! : Your input might contain ' + JSON.stringify(detectWords);
    new_element.id = "credential-alert";
    new_element.className = "credential-alert";
    new_element.style.cssText = "font-weight: bold;"
        + "font-size: 12pt;"
        + "background-color: #FF0000;"
        + "color: #FFFFFF;"
        + "padding: 5px;";

    body.addEventListener("input", (event) => {
        let text = ""
        if (event.target.value !== undefined) {
            text = event.target.value.toLowerCase();
        } else if (event.target.innerText !== undefined) {
            text = event.target.innerText.toLowerCase();
        } else {
            return;
        }
        const result = detectWords.concat(doutfulWords).map(keyword => text.includes(keyword));
        if (result.includes(true)) {
            const firstChild = document.body.firstChild;
            document.body.insertBefore(new_element, firstChild);
        } else {
            const al = document.getElementById("credential-alert");
            if (al !== undefined && al !== null) {
                al.remove();
            }
        }
    })
})();
