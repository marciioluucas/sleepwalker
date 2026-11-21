#!/bin/bash
# Install swk without Homebrew: links bin/swk into ~/.local/bin (or $PREFIX/bin).
set -euo pipefail
src="$(cd "$(dirname "$0")" && pwd)"
bin="${PREFIX:-$HOME/.local}/bin"
mkdir -p "$bin"
ln -sf "$src/bin/swk" "$bin/swk"
echo "linked $bin/swk"
case ":$PATH:" in *":$bin:"*) ;; *) echo "add to your shell profile: export PATH=\"$bin:\$PATH\"" ;; esac
echo "next: swk setup"
