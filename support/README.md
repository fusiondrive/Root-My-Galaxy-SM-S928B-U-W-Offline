# Support manifests

This offline pack ships two exact DZF2 profiles and does not download GitHub
feeds at runtime.

- `targets-v3.json` is the schema used by the bundled app.
- `targets-v2.json` keeps the same two profiles in the older feed shape.

The app copies `targets-v3.json` into `app/src/main/assets/targets-v3.json`.
Artifact URLs use `asset://<profileId>/<file>` and are verified by size and
SHA-256 before use.

Do not add `SM-S928W`, `SM-S928N`, `SM-S9280`, or any non-DZF2 build to these
files without a separate firmware-specific audit.
