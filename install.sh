#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

if [[ -z ${PREFIX:-} || $(uname -m) != aarch64 ]] || ! command -v pkg >/dev/null; then
  printf 'Run this installer inside ARM64 Termux.\n' >&2
  exit 1
fi

source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if [[ ! -s $source_dir/qvm ]]; then
  printf 'Keep install.sh alongside qvm from the same checkout.\n' >&2
  exit 1
fi
bash -n "$source_dir/qvm"

pkg update
pkg install x11-repo
pkg install qemu-system-aarch64 qemu-utils binutils libjxl util-linux socat

umask 077
mkdir -p -- "$HOME/qvm"
staged=$(mktemp "$HOME/qvm/.launcher.XXXXXXXX")
trap 'rm -f -- "$staged"' EXIT
install -m 700 -- "$source_dir/qvm" "$staged"
mv -fT -- "$staged" "$HOME/qvm/qvm"
ln -sfnT -- "$HOME/qvm/qvm" "$PREFIX/bin/qvm"
"$PREFIX/bin/qvm" list
printf '\nQVM installed. Run qvm help for commands.\n'
