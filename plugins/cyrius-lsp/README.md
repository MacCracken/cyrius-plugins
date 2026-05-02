# cyrius-lsp

Cyrius language server wiring for Claude Code. Auto-attaches `cyrius-lsp`
to all `.cyr`-family files.

## Supported extensions

`.cyr` · `.tcyr` · `.bcyr` · `.fcyr` · `.scyr` · `.smcyr`

## Capabilities

Provided by [`cyrius-lsp`](https://github.com/MacCracken/cyrius/blob/main/programs/cyrius-lsp.cyr):

- `initialize` — handshake / capabilities
- `textDocument/didOpen` — compile, return diagnostics
- `textDocument/didSave` — recompile, return diagnostics
- `textDocument/didChange` — recompile, return diagnostics
- `shutdown` — exit cleanly

Diagnostics are produced by invoking the in-tree compiler (`cc5`) on
the buffer and parsing its `error:<file>:<line>: <msg>` output back
into LSP `Diagnostic` records.

Hover, goToDefinition, completion, and semantic tokens are not yet
provided — they land in `cyrius-lsp` itself, not in this plugin.

## Installation

This plugin lives in [`MacCracken/cyrius-plugins`](https://github.com/MacCracken/cyrius-plugins),
the Claude Code marketplace for the Cyrius toolchain (sibling repo to
the [language](https://github.com/MacCracken/cyrius) itself). Wire it
up with:

```sh
/plugin marketplace add MacCracken/cyrius-plugins
/plugin install cyrius-lsp@cyrius-plugins
```

The `cyrius-lsp` binary itself is built and installed by the Cyrius
toolchain (`cyrius lsp` or `cyriusly setup`):

```sh
cyrius lsp                        # build → ~/.cyrius/bin/cyrius-lsp
```

`~/.cyrius/bin` should be on your shell `PATH` (added by
`cyriusly setup`). Confirm with:

```sh
which cyrius-lsp                  # ~/.cyrius/bin/cyrius-lsp
```

## Why this exists

Pre-plugin, every Cyrius repo carried its own byte-identical
`.lsp.json` — drift risk, and any new repo (or downstream consumer)
started broken until the file was copied in by hand. Once this plugin
is installed at user scope, every `.cyr`-family file on the machine
gets the LSP automatically — no per-repo wiring.

See [`docs/development/proposals/consolidate-cyrius-lsp-claude-plugin.md`](https://github.com/MacCracken/cyrius/blob/main/docs/development/proposals/consolidate-cyrius-lsp-claude-plugin.md)
for the original proposal and severity rationale.

## Releases

Tags for this plugin follow the marketplace-wide convention
**`cyrius-lsp--v<X.Y.Z>`** — see the
[Tag convention](../../README.md#tag-convention) and
[release process](../../docs/release-process.md) at the marketplace
root for the full rules. Examples: `cyrius-lsp--v0.1.0`,
`cyrius-lsp--v0.2.0`, etc.

Released versions show up at
[github.com/MacCracken/cyrius-plugins/releases](https://github.com/MacCracken/cyrius-plugins/releases)
filtered to `cyrius-lsp--v*` tags.

## Open: cc5 not found under Claude Code

If `cyrius-lsp` logs `[cyrius-lsp] warning: cc5 not found —
diagnostics disabled`, Claude Code launched it without `~/.cyrius/bin`
on the inherited `PATH`. Workarounds (pick one):

1. Confirm your Claude Code launcher inherits a shell that has
   `~/.cyrius/bin` on `PATH` (`cyriusly setup` does this).
2. Add an `env.PATH` block to this plugin's `.lsp.json` — but
   resolve `$HOME` ahead of time, since JSON values aren't shell-
   expanded:
   ```json
   "env": { "PATH": "/Users/<you>/.cyrius/bin:/usr/local/bin:/usr/bin:/bin" }
   ```
   Per-machine override, not committed to the marketplace copy
   (which stays portable).

The right long-term fix is on the `cyrius-lsp` side: probe its own
`argv[0]` location and prepend that directory to its child-process
search path internally — same trick `gopls`, `clangd`, etc. use to
resolve their toolchain regardless of how the editor launched them.
That removes the need for any per-user PATH workaround in this
plugin. Tracked separately.

## License

GPL-3.0-only — same as the rest of the Cyrius toolchain.
