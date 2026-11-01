#!/bin/sh
# Report every package in the mac2 lists that the current apt sources can't install.
# Run inside the target distro (e.g. debian:trixie) with all archive areas enabled.
cd "$(dirname "$0")/.." || exit 1
missing=0
for f in config/package-lists/*.list.chroot config/package-lists/*.list.chroot.opt; do
	case "$f" in *kali-extras*|*/sel-*) continue ;; esac
	for p in $(grep -v '^#' "$f"); do
		if [ -z "$(apt-cache policy "$p" 2>/dev/null | awk '/Candidate:/ && $2 != "(none)"')" ]; then
			echo "missing: $p ($(basename "$f"))"
			missing=$((missing + 1))
		fi
	done
done
[ "$missing" = 0 ] && echo "All packages available." && exit 0
exit 1
