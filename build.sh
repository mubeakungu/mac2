#!/bin/sh
# Build a mac2 ISO.  Run as root on Debian 13 (or in the debian:trixie container).
#
#   sudo ./build.sh                          # Xfce + all Debian tool categories
#   sudo MAC2_DESKTOP=none ./build.sh        # CLI only
#   sudo MAC2_TOOLS="recon web" ./build.sh   # only some tool categories
#   sudo MAC2_BASE=kali ./build.sh           # Kali rolling base + Kali-only tools
#
# Output: mac2-<version>-<arch>.hybrid.iso in this directory.
set -e
cd "$(dirname "$0")"

export MAC2_VERSION="${MAC2_VERSION:-$(date +%Y.%m)}"
export MAC2_ARCH="${MAC2_ARCH:-amd64}"
export MAC2_BASE="${MAC2_BASE:-debian}"
MAC2_DESKTOP="${MAC2_DESKTOP:-xfce}"
MAC2_TOOLS="${MAC2_TOOLS:-recon web passwords wireless sniffing exploit forensics reversing}"
LISTS=config/package-lists

[ "$(id -u)" = 0 ] || { echo "build.sh: run as root" >&2; exit 1; }
command -v lb >/dev/null || { echo "build.sh: install live-build first (apt install live-build)" >&2; exit 1; }

# Kali base needs Kali's archive key on the host for debootstrap.
if [ "$MAC2_BASE" = kali ]; then
	KEY=/usr/share/keyrings/kali-archive-keyring.gpg
	if [ ! -s "$KEY" ]; then
		echo "Fetching Kali archive key..."
		curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor > "$KEY"
	fi
	[ -e /usr/share/debootstrap/scripts/kali-rolling ] ||
		ln -s sid /usr/share/debootstrap/scripts/kali-rolling
fi

# Activate the chosen package lists. Generated files are prefixed "sel-" and git-ignored.
rm -f "$LISTS"/sel-*.list.chroot
if [ "$MAC2_DESKTOP" != none ]; then
	src="$LISTS/mac2-desktop-$MAC2_DESKTOP.list.chroot.opt"
	[ -f "$src" ] || { echo "build.sh: unknown desktop '$MAC2_DESKTOP' (xfce, gnome, kde, none)" >&2; exit 1; }
	cp "$src" "$LISTS/sel-desktop.list.chroot"
fi
[ "$MAC2_BASE" = kali ] && MAC2_TOOLS="$MAC2_TOOLS kali-extras"
mkdir -p config/includes.chroot/usr/share/mac2/tools
rm -f config/includes.chroot/usr/share/mac2/tools/*.list
for t in $MAC2_TOOLS; do
	case "$t" in kali-extras) src="$LISTS/mac2-kali-extras.list.chroot.opt" ;; *) src="$LISTS/mac2-tools-$t.list.chroot.opt" ;; esac
	[ -f "$src" ] || { echo "build.sh: unknown tool category '$t'" >&2; exit 1; }
	cp "$src" "$LISTS/sel-tools-$t.list.chroot"
	cp "$src" "config/includes.chroot/usr/share/mac2/tools/$t.list"
done

printf 'MAC2_VERSION=%s\nMAC2_BASE=%s\nMAC2_DESKTOP=%s\n' \
	"$MAC2_VERSION" "$MAC2_BASE" "$MAC2_DESKTOP" > config/includes.chroot/etc/mac2-build-info

echo "==> mac2 $MAC2_VERSION ($MAC2_ARCH, base=$MAC2_BASE, desktop=$MAC2_DESKTOP)"
echo "==> tools: $MAC2_TOOLS"

lb clean --purge >/dev/null 2>&1 || true
lb config
lb build

ls -lh ./*.iso
