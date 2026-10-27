# Tampermonkey Scripts

This directory contains UserScripts for Tampermonkey.

## Installation

1. Install [Tampermonkey](https://www.tampermonkey.net/) extension for your browser
2. Click the "Install" link for each script below to add it to Tampermonkey
3. Open the script in the Tampermonkey dashboard, and uncheck "Check for updates" in its Settings tab

## Updating

The scripts have no `@updateURL` / `@downloadURL` on purpose.
Most of them run on every site (including password managers), so an automatic update from this public repository
would let anyone who can push to `master` run arbitrary JavaScript in the browser.
Tampermonkey still checks the URL a script was installed from unless "Check for updates" is unchecked (step 3).

To update a script, review the diff on GitHub, then reinstall it from the "Install" link
(or paste the new version into the Tampermonkey editor).

## Scripts

### [CredentialsAlert](./CredentialsAlert/CredentialsAlert.user.js)

- **Description:** Watch out! You might input credentials!
- **Install:** [Click here to install](https://github.com/go-zen-chu/dotfiles/raw/master/tampermonkey/CredentialsAlert/CredentialsAlert.user.js)

### [EmphasizeTab](./EmphasizeTab/EmphasizeTab.user.js)

- **Description:** Emphasize the tab title with custom prefix and/or suffix
- **Install:** [Click here to install](https://github.com/go-zen-chu/dotfiles/raw/master/tampermonkey/EmphasizeTab/EmphasizeTab.user.js)

### [HideAmazonAds](./HideAmazonAds/HideAmazonAds.user.js)

- **Description:** Hide sponser ads from amazon list
- **Install:** [Click here to install](https://github.com/go-zen-chu/dotfiles/raw/master/tampermonkey/HideAmazonAds/HideAmazonAds.user.js)

### [Html2md](./Html2md/Html2md.user.js)

- **Description:** Convert html page to markdown and store to clipboard
- **Install:** [Click here to install](https://github.com/go-zen-chu/dotfiles/raw/master/tampermonkey/Html2md/Html2md.user.js)
