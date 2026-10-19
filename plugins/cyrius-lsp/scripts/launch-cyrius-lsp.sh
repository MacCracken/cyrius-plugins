#!/bin/sh
# Start cyrius-lsp for Claude Code. stdout carries the LSP protocol: nothing else may write to it.
#
# Claude Code starts an LSP `command` by name from its own PATH, which need not hold ~/.cyrius/bin
# (a desktop-app launch, a non-interactive SSH session), and .lsp.json expands only the plugin's
# path variables — never $HOME. So the lookup lives here, in the order a user would expect:
#   1. $CYRIUS_LSP          an explicit path to the server
#   2. cyrius-lsp on PATH   what a configured shell already finds
#   3. $CYRIUS_HOME/bin     a non-default toolchain home
#   4. $HOME/.cyrius/bin    the default install (`cyrius lsp`, `install.sh`, `cyriusly setup`)
# The server's own directory is put first on PATH, so whatever it spawns resolves to the same
# toolchain it came from.
run() {
    PATH="$(dirname "$1"):$PATH"
    export PATH
    exec "$@"
}
if [ -n "${CYRIUS_LSP:-}" ] && [ -x "$CYRIUS_LSP" ]; then run "$CYRIUS_LSP" "$@"; fi
p=$(command -v cyrius-lsp 2>/dev/null) && [ -n "$p" ] && run "$p" "$@"
for d in "${CYRIUS_HOME:-}" "${HOME:-}/.cyrius"; do
    if [ -n "$d" ] && [ -x "$d/bin/cyrius-lsp" ]; then run "$d/bin/cyrius-lsp" "$@"; fi
done
echo "cyrius-lsp: not found (\$CYRIUS_LSP, PATH, \$CYRIUS_HOME/bin, ~/.cyrius/bin) — build it with \`cyrius lsp\`" >&2
exit 127
