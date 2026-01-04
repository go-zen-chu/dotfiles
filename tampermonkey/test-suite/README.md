# Tampermonkey test-suite

Shared test runner for Tampermonkey user scripts in this repo.

## Usage (from a package directory)

- `npm test` (packages call the shared runner)
- Or directly: `node ../test-suite/bin/run.js`

Outputs `test-results.xml` in the package root for CI artifact upload.
