# cyrius-lsp

Cyrius language server wiring for Claude Code. Auto-attaches `cyrius-lsp` to every `.cyr`-family file, so
any Cyrius project gets diagnostics and navigation without per-repo config.

## Supported extensions

`.cyr` · `.tcyr` · `.bcyr` · `.fcyr` · `.scyr` · `.smcyr`

## Capabilities

Provided by [`cyrius-lsp`](https://github.com/MacCracken/cyrius/blob/main/programs/cyrius-lsp.cyr), which
ships with the Cyrius toolchain:

- **Diagnostics** — on open, change and save the server compiles through the `cyrius` CLI (`cyrius check`,
  with the project's dependencies when a `cyrius.cyml` sits at or above the file) and turns the compiler's
  `error:<file>:<line>:<col>:` / `warning:` lines into LSP diagnostics. A file outside any project is checked
  by the server's own toolchain, never another project's pin.
- **Hover**, **go-to-definition** (across files), **references**, **document symbols** and **semantic tokens**
  — from the server's cross-file symbol table (fns, vars, enums, structs, enum members).

Claude Code pushes the diagnostics into the session after each edit of a handled file; the navigation
requests are served to the `LSP` tool.

## Installation

```sh
/plugin marketplace add MacCracken/cyrius-plugins
/plugin install cyrius-lsp@cyrius-plugins
```

The `cyrius-lsp` binary is built and installed by the Cyrius toolchain — `cyrius lsp` (or the installer /
`cyriusly setup`) puts it at `~/.cyrius/bin/cyrius-lsp`.

### How the server is found

Claude Code starts an LSP server from its own `PATH`, which need not contain `~/.cyrius/bin` — a desktop-app
launch, or a non-interactive SSH session, often does not. So the plugin starts the server through
[`scripts/launch-cyrius-lsp.sh`](scripts/launch-cyrius-lsp.sh), which looks, in order, at:

1. `$CYRIUS_LSP` — an explicit path to a server binary;
2. `cyrius-lsp` on `PATH`;
3. `$CYRIUS_HOME/bin/cyrius-lsp`;
4. `~/.cyrius/bin/cyrius-lsp`.

It puts the server's own directory first on `PATH`, so everything the server spawns comes from the same
toolchain. The server itself then finds `cycc` and the `cyrius` CLI next to its own executable. If no
server is found, the launcher exits 127 with one line on stderr naming the places it looked (shown in
`/plugin` → Errors).

The launcher needs `/bin/sh` — Linux and macOS. On Windows, point a project's own `.lsp.json` at
`cyrius-lsp.exe` instead.

### Turning it off for one project

Set `"cyrius-lsp@cyrius-plugins": false` under `enabledPlugins` in that project's `.claude/settings.json`
(or `claude plugin disable cyrius-lsp@cyrius-plugins --scope project`).

## Updating

An installed plugin keeps its cached copy until the version changes:

```sh
claude plugin marketplace update cyrius-plugins
claude plugin update cyrius-lsp@cyrius-plugins
```

then `/reload-plugins` (or a new session).

## Releases

Tags for this plugin follow the marketplace-wide convention **`cyrius-lsp--v<X.Y.Z>`** — see the
[Tag convention](../../README.md#tag-convention) and [release process](../../docs/release-process.md) at the
marketplace root. Released versions are at
[github.com/MacCracken/cyrius-plugins/releases](https://github.com/MacCracken/cyrius-plugins/releases),
filtered to `cyrius-lsp--v*` tags.

- **0.2.0** — the launcher (the server is found without `~/.cyrius/bin` on `PATH`); the capabilities and the
  compiler name (`cycc`) brought up to date.
- **0.1.0** — the initial wiring.

## History

Before this plugin, every Cyrius repo carried its own byte-identical `.lsp.json`. See the archived
[proposal](https://github.com/MacCracken/cyrius/blob/main/docs/development/archive/consolidate-cyrius-lsp-claude-plugin.md).

## License

GPL-3.0-only — same as the rest of the Cyrius toolchain.
