# Tampermonkey Scripts

This directory contains UserScripts for Tampermonkey.

## Installation

1. Install [Tampermonkey](https://www.tampermonkey.net/) extension for your browser
2. Click the "Install" link for each script below to add it to Tampermonkey
3. In the Tampermonkey dashboard, add sensitive sites (password managers, banks, identity providers)
   to "User excludes" in the Settings tab of the scripts matching every site (CredentialsAlert, EmphasizeTab)

## Updates

The scripts update automatically from `master` (`@updateURL` / `@downloadURL`).
Most of them run on every site, so whatever is merged into `master` runs in the browser:

- `master` only changes through pull requests (no direct or force push), so review every change under `tampermonkey/`
- "User excludes" are browser-side settings, so an update to a script cannot remove them
- `@require` URLs are pinned to a version with a `#sha256=` hash

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
