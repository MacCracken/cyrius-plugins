# cyrius-plugins

Claude Code marketplace for the [Cyrius](https://github.com/MacCracken/cyrius)
language toolchain.

Sibling repo to the language itself — clean separation: Cyrius the
compiler/stdlib/tooling lives in `MacCracken/cyrius`; the Claude Code
wiring (LSP plumbing, slash commands, future agents/skills) lives
here.

## Install

Add the marketplace once at user scope, then install plugins by name:

```sh
/plugin marketplace add MacCracken/cyrius-plugins
/plugin install cyrius-lsp@cyrius-plugins
```

Updates flow automatically: `/plugin marketplace update`.

> **If `/plugin marketplace add` reports "marketplace not found"** —
> your Claude Code version may not resolve the `owner/repo` shorthand
> against GitHub. Pass the full clone URL instead:
>
> ```sh
> /plugin marketplace add https://github.com/MacCracken/cyrius-plugins.git
> ```
>
> Newer Claude Code versions accept the shorthand (same convention as
> `gh repo clone`); older ones need the explicit URL.

## Plugins

| Plugin | Status | Description |
|--------|--------|-------------|
| [`cyrius-lsp`](plugins/cyrius-lsp) | 0.2.0 | Wires `cyrius-lsp` to all `.cyr`-family files (`.cyr` / `.tcyr` / `.bcyr` / `.fcyr` / `.scyr` / `.smcyr`) — diagnostics from `cycc`, hover, go-to-definition, references, symbols, semantic tokens; finds the server without `~/.cyrius/bin` on `PATH`. |

Future slots (slash commands for `cyrius test` / `cyrius bench`,
agents for downstream-consumer porting, etc.) land as additional
entries here, not as bloat in the language repo.

## Layout

Standard Claude Code marketplace shape:

```
cyrius-plugins/
├── .claude-plugin/
│   └── marketplace.json          # catalog: lists every plugin + source path
├── plugins/
│   └── cyrius-lsp/
│       ├── .claude-plugin/
│       │   └── plugin.json       # plugin manifest (name, version, author)
│       ├── .lsp.json             # LSP server config (extensions → the launcher)
│       ├── scripts/
│       │   └── launch-cyrius-lsp.sh  # finds cyrius-lsp without ~/.cyrius/bin on PATH
│       └── README.md             # per-plugin install + capabilities
├── .github/
│   └── workflows/
│       └── validate.yml          # CI: validates manifests on push/PR
├── docs/
│   └── release-process.md        # how to cut a plugin release
├── LICENSE                       # GPL-3.0-only (matches MacCracken/cyrius)
└── README.md                     # this file
```

## Adding a new plugin

1. Create `plugins/<name>/` with `.claude-plugin/plugin.json` (and any
   plugin-type-specific files: `.lsp.json` for an LSP plugin, `agents/`
   for agents, etc.).
2. Append a `{name, description, version, source: "./plugins/<name>",
   ...}` entry to `.claude-plugin/marketplace.json` — version MUST
   match the plugin's `plugin.json` (`claude plugin tag` enforces it).
3. Write `plugins/<name>/README.md` covering install + capabilities +
   open issues. Include a `## Releases` section pointing back at the
   [Tag convention](#tag-convention) so plugin-folder readers find the
   release rules without bouncing.
4. Validate: `claude plugin validate plugins/<name>` and
   `claude plugin validate .` — both must pass before commit.
5. Cut the first release per the [Tag convention](#tag-convention) and
   the [release process](docs/release-process.md): `claude plugin tag
   plugins/<name> --push` produces `<name>--v0.1.0` and triggers
   [`release.yml`](.github/workflows/release.yml) to publish a GitHub
   Release.

## Tag convention

**Every release tag in this repo follows the form
`<plugin-name>--v<semver>`.** Examples:

- `cyrius-lsp--v0.1.0`
- `cyrius-lsp--v0.2.0`
- (future) `cyrius-test-runner--v0.1.0`

Two dashes between name and `v` so plugin names containing a single
dash (`cyrius-lsp`) parse unambiguously — splitting on `--v` always
yields `(name, version)`.

Why per-plugin tags (not a single repo-wide `vX.Y.Z`):

- Each plugin versions **independently** — a `cyrius-lsp` patch
  doesn't force a version bump on every other plugin in the
  marketplace.
- The release workflow ([`release.yml`](.github/workflows/release.yml))
  parses the plugin name out of the tag to know which plugin to
  publish — repo-wide tags would have no plugin to attribute to.
- `claude plugin tag` produces this exact format and refuses to run
  if `plugin.json` and the marketplace entry disagree on version
  — same guarantee the CI gate enforces.

A bare `vX.Y.Z` or `X.Y.Z` tag will NOT trigger the release
workflow (the `*--v*` glob won't match) and SHOULD be deleted to
avoid downstream confusion. See
[`docs/release-process.md`](docs/release-process.md) for the full
release checklist.

## Releasing

Short version (full checklist in
[`docs/release-process.md`](docs/release-process.md)):

```sh
# 1. Bump plugin version in BOTH plugin.json and marketplace.json
# 2. Validate
claude plugin validate .
claude plugin validate plugins/<name>
# 3. Commit + tag + push
git commit -am "<name> X.Y.Z"
claude plugin tag plugins/<name> --push
```

`claude plugin tag` enforces that the plugin's `plugin.json` and the
marketplace entry agree on version, then creates the
`<name>--v<X.Y.Z>` tag (per the [convention above](#tag-convention))
and (with `--push`) pushes it.

## CI

Two workflows in [`.github/workflows/`](.github/workflows/):

- **[`validate.yml`](.github/workflows/validate.yml)** — runs on every
  push to `main` and every PR. Validates marketplace + plugin
  manifests, cross-checks marketplace ↔ plugin.json version
  agreement, parses every JSON file. Drift between manifests fails
  CI before merge.
- **[`release.yml`](.github/workflows/release.yml)** — runs on
  per-plugin tag pushes (`<name>--v<X.Y.Z>`). Re-validates the
  tagged state, double-checks tag literal vs. manifest versions,
  creates a GitHub Release with auto-generated notes pointing at
  the plugin's README at that tag.

Together: PR-time enforcement that manifests stay in sync, plus
release-time enforcement that the tagged commit matches the tag's
declared version.

## Why a separate marketplace repo

- **Independent release cadence.** Plugin updates ship without bumping
  the compiler. Compiler ships without forcing a plugin update.
- **Smaller blast radius.** Editor-side wiring breaks don't gate
  language-toolchain releases (and vice versa).
- **Standard pattern.** Mirrors how Anthropic's
  `claude-plugins-official` repo is structured — one repo, one
  marketplace, many plugins.
- **Discoverable.** `MacCracken/cyrius-plugins` is the obvious name
  for "Claude Code plugins for Cyrius"; embedding them under
  `MacCracken/cyrius` would have hidden them.

## License

GPL-3.0-only, matching the rest of the Cyrius toolchain.
