# Release process

Plugins in this marketplace version independently — no monorepo
lock-step. Each plugin gets its own `<name>--v<X.Y.Z>` tag.

## Tagging convention

`{plugin-name}--v{semver}` — the format `claude plugin tag` produces.
Examples:

- `cyrius-lsp--v0.1.0`
- `cyrius-lsp--v0.2.0`
- (future) `cyrius-test-runner--v0.1.0`

Two dashes between name and `v` so plugin names containing a dash
(`cyrius-lsp`) parse unambiguously.

## Cutting a release

### 1. Bump version in BOTH manifests

`claude plugin tag` refuses to tag if the marketplace entry and the
plugin's `plugin.json` disagree. Edit both:

```jsonc
// plugins/<name>/.claude-plugin/plugin.json
{ "version": "X.Y.Z", ... }

// .claude-plugin/marketplace.json
{ "plugins": [{ "name": "<name>", "version": "X.Y.Z", ... }] }
```

### 2. Validate locally

```sh
claude plugin validate .
claude plugin validate plugins/<name>
claude plugin tag --dry-run plugins/<name>
```

The `--dry-run` confirms versions agree and prints the tag that
would be created.

### 3. Commit

```sh
git add plugins/<name>/.claude-plugin/plugin.json \
        .claude-plugin/marketplace.json \
        plugins/<name>/  # any plugin-internal changes
git commit -m "<name> X.Y.Z"
```

`claude plugin tag` refuses to tag a dirty working tree (override
with `-f` if you really mean it — usually you don't).

### 4. Tag and push

```sh
claude plugin tag plugins/<name> --push
```

Creates the annotated tag locally and pushes it to `origin`. Drop
`--push` to inspect the tag locally before publishing.

### 5. Verify users see the update

After CI completes on `main`, downstream users get the update on next
`/plugin marketplace update` (or auto-update if Claude Code's polling
fires first).

## Versioning policy

Standard SemVer:

- **Patch (X.Y.Z → X.Y.Z+1)** — internal fixes (manifest typo, README
  edit that ships as plugin metadata, dependency-binary version bump).
  Users notice nothing functional.
- **Minor (X.Y.Z → X.Y+1.0)** — additive capability (new LSP method
  surfaced, new file extension wired, new slash command added). No
  break in existing wiring.
- **Major (X.Y.Z → X+1.0.0)** — breaking change (extension removed,
  command name renamed, server config schema change requiring user
  reconfig). Document the migration in the plugin's README + a top-level
  CHANGELOG entry.

Pre-1.0 (`0.X.Y`) plugins MAY break in minor releases — flag clearly
in the bump commit message.

## CI gate

[`.github/workflows/validate.yml`](../.github/workflows/validate.yml)
runs on every push and PR:

1. Each `plugins/<name>/.claude-plugin/plugin.json` validates.
2. The top-level `.claude-plugin/marketplace.json` validates.
3. Every plugin's `claude plugin tag --dry-run` succeeds — meaning
   the marketplace entry and plugin.json agree on version.
4. All `*.json` files parse as JSON.

A drift between marketplace.json and a plugin's plugin.json fails CI
before merge — the same guarantee `claude plugin tag` enforces
locally.

## Adding a new plugin to the marketplace

1. Scaffold under `plugins/<name>/` per the layout in the top-level
   [README](../README.md#layout).
2. Add the plugin entry to `.claude-plugin/marketplace.json`.
3. Open a PR. CI validates the addition.
4. After merge, cut the first release per the steps above
   (`<name>--v0.1.0` tag).

## Removing a plugin

Removing a plugin is a breaking change for anyone who installed it.
Steps:

1. Bump the plugin to a final version with a deprecation note in its
   README + a `"deprecated": true` field on its marketplace entry (if
   the schema supports it; otherwise note in description).
2. Tag the final release (`<name>--vX.Y.Z`).
3. After a soak window (one minor cycle minimum), delete the plugin
   directory and its marketplace entry in a single PR. Existing
   installs continue to work via the cached version; new installs
   fail loudly.

## Open: per-plugin CHANGELOG

This marketplace currently has no top-level `CHANGELOG.md` — release
context lives in commit messages and the plugin's own README. If
contributor count grows or release notes need to be more discoverable,
add a per-plugin `CHANGELOG.md` next to its `plugin.json`. Track in
issue if it surfaces real friction.
