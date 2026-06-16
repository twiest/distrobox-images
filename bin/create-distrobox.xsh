#!/usr/bin/env xonsh

if len($ARGS) != 2:
    echo
    echo "  Usage: $(basename $0) <permission_domain_for_box>"
    echo
    echo "Example: $(basename $0) financial"
    echo
    exit(10)

source /usr/local/lib/xonsh/utils.xsh

script_dir = $(dirname @($ARGS[0]))
script_name = $(basename @($ARGS[0]))
distro = $(basename $(dirname $PWD))

cd @(script_dir)

echo -n "Checking if sudo works... "
retval = does_sudo_work()
print_success_or_die(retval.returncode == 0, "worked", f"return_code: { retval.returncode }:\n\nstdout:\n{ retval.stdout }\n\nstderr:\n{ retval.stderr }")



distrobox_name = $ARG1
distrobox_dir = "$HOME/distrobox"
home_dir = pf"{ distrobox_dir }/{ distrobox_name }"

img_name = f"ghcr.io/twiest/distrobox-{ distro }"
img_ver = $(basename $PWD)
date_stamp = $(date +%Y-%m-%d)

has_zfs_dir = False
zfs_fs = ""
if pf"{ home_dir }/.zfs".exists():
    has_zfs_dir = True
    zfs_fs = f"ssd/zones/{ distrobox_name }-enc"
    echo -n f"Disabling .zfs dir for [{ zfs_fs }]... "
    sudo zfs set snapdir=hidden f"{ zfs_fs }"
    echo f"{ GREEN }Done.{ RESTORE }"

mkdir -p @(home_dir)
sudo chown -R twiest:twiest @(home_dir)
distrobox create --nvidia --unshare-process --unshare-groups --unshare-devsys --name f"{ distrobox_name }" --home f"{ home_dir }" --image f"{ img_name }:{ img_ver }"

if has_zfs_dir:
    echo -n f"Resetting .zfs dir to inheritted for [{ zfs_fs }]... "
    sudo zfs inherit snapdir @(zfs_fs)
    echo f"{ GREEN }Done.{ RESTORE }"
