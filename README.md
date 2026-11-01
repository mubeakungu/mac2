# mac2 GNU/Linux

mac2 is a Debian-based penetration testing and security distribution in the spirit of Kali Linux.
It is built with Debian's `live-build`, the same tooling Kali uses, and produces a hybrid ISO you can
boot live from USB or install to disk.

> Only use the tools in mac2 against systems you own or are explicitly authorised to test.

## What you get

- **Base**: Debian 13 "trixie" (default) or Kali rolling (`MAC2_BASE=kali`)
- **Desktop**: Xfce (default), GNOME, KDE Plasma or none
- **Live user**: `mac2` / password `mac2`, hostname `mac2`
- **Shell**: zsh with a Kali-style two-line prompt, autosuggestions and syntax highlighting
- **Installer**: Debian installer (graphical) from the boot menu
- **`mac2-tools`**: lists every tool category in the image and what's installed
- Network services (ssh, tor) are disabled by default

### Tool categories

| Category    | Examples                                                    |
|-------------|-------------------------------------------------------------|
| `recon`     | nmap, masscan, arp-scan, netdiscover, dnsrecon, whatweb     |
| `web`       | sqlmap, gobuster, ffuf, wfuzz, dirb, nikto          |
| `passwords` | john, hashcat, hydra, medusa, crunch, cewl                  |
| `wireless`  | aircrack-ng, reaver, bully, wifite, hcxtools, pixiewps      |
| `sniffing`  | wireshark, tshark, tcpdump, ettercap, bettercap, dsniff     |
| `exploit`   | netcat, ncat, socat, impacket, proxychains4, tor            |
| `forensics` | sleuthkit, autopsy, binwalk, foremost, testdisk, yara       |
| `reversing` | gdb, ltrace, strace                                |
| `kali-extras` (Kali base only) | metasploit, burpsuite, exploitdb, seclists, wpscan, netexec, zaproxy |

Package lists live in `config/package-lists/*.list.chroot.opt`. Add a package by adding a line.

## Building

You need a Debian 13 machine (or VM/container) with root, about 20 GB free disk and a network connection.

```sh
sudo apt install live-build debootstrap xorriso squashfs-tools curl gpg
sudo ./build.sh
```

Options are environment variables:

```sh
sudo MAC2_DESKTOP=gnome ./build.sh            # xfce | gnome | kde | none
sudo MAC2_TOOLS="recon web passwords" ./build.sh
sudo MAC2_BASE=kali ./build.sh                # adds Kali-only tools
sudo MAC2_VERSION=1.0 ./build.sh
```

The ISO appears as `mac2-<version>-amd64.hybrid.iso`. Clean up with `sudo lb clean --purge`.

### Building with Docker (any Linux host)

```sh
docker run --rm --privileged -v "$PWD:/build" -w /build debian:trixie sh -c '
  apt-get update && apt-get install -y live-build debootstrap xorriso squashfs-tools curl gpg &&
  ./build.sh'
```

### Building on GitHub

The **Build ISO** workflow (Actions tab → Build ISO → Run workflow) builds the ISO on GitHub's runners and
attaches it as a downloadable artifact. Pushing a tag like `v1.0` builds and publishes a release.

## Trying it

```sh
qemu-system-x86_64 -m 4096 -enable-kvm -cdrom mac2-*.iso
```

Or write it to a USB stick with `dd`, balenaEtcher or Ventoy.

## Layout

```
build.sh                    entry point: picks lists, runs live-build
auto/config                 live-build options (base, mirrors, boot params, ISO name)
config/package-lists/       package lists; *.opt files are switched on by build.sh
config/hooks/normal/        scripts run inside the image (branding, defaults)
config/hooks/live/          live-session-only setup (live user)
config/includes.chroot/     files copied into the image (/etc/skel, motd, mac2-tools)
.github/workflows/          CI ISO build
```
