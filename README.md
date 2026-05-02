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

## Plugins

| Plugin | Status | Description |
|--------|--------|-------------|
| [`cyrius-lsp`](plugins/cyrius-lsp) | 0.1.0 | Wires `cyrius-lsp` to all `.cyr`-family files (`.cyr` / `.tcyr` / `.bcyr` / `.fcyr` / `.scyr` / `.smcyr`) — diagnostics from `cc5`. |

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
│       ├── .lsp.json             # LSP server config (extensions → server)
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
   open issues.
4. Validate: `claude plugin validate plugins/<name>` and
   `claude plugin validate .` — both must pass before commit.

## Releasing

See [`docs/release-process.md`](docs/release-process.md) for the full
checklist. Short version:

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
marketplace entry agree on version, then creates `<name>--v<X.Y.Z>`
and (with `--push`) pushes it. Per-plugin tags so each plugin
versions independently.

## CI

Every push and PR runs [`./.github/workflows/validate.yml`](.github/workflows/validate.yml):

- Manifests parse as JSON
- `claude plugin validate` passes on the marketplace and each plugin
- Marketplace entry version agrees with plugin's `plugin.json`
  version (`claude plugin tag --dry-run` is the cross-check)

Drift between `marketplace.json` and a plugin's `plugin.json` fails
CI before the merge — same guarantee `claude plugin tag` enforces
locally.

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
