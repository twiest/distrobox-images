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


img_name_escaped = f"ghcr.io\\/twiest\\/distrobox-{ distro }"
img_name = f"ghcr.io/twiest/distrobox-{ distro }"
img_ver = $(basename $PWD)
distrobox_name = $ARG1


echo -n "Checking if the distrobox exists... "
awk_param = f"/{ distrobox_name }/" + ' { print $2 }'
output = $(distrobox list --no-color | awk -F '|' @(awk_param)).strip()
print_success_or_die(output == distrobox_name, "it exists", f"distrobox [{ distrobox_name }] doesn't exist")

echo -n "Checking if the distrobox is using this image... "
awk_param = fr"/{ distrobox_name }.*{ img_name_escaped }.{ img_ver }/" + ' { print $2 $4 }'
output = $(distrobox list --no-color | awk -F '|' @(awk_param) | wc -l).strip()
print_success_or_die(output == "1", "it is using this image", f"distrobox [{ distrobox_name }] is using a different image")

echo f"Pulling latest image from ghcr [{ img_name }:{ img_ver }]:"
podman pull f"{ img_name }:{ img_ver }"

echo f"Removing existing distrobox instance [{ distrobox_name }]:"
distrobox rm -f @(distrobox_name)

echo "Waiting 3 seconds otherwise distrobox may fail to create..."
sleep 3

rm_param = gf`/var/home/twiest/distrobox/{ distrobox_name }/.config/BraveSoftware/Brave-Browser/Singleton*`
rm_param_len = len(rm_param)
if rm_param_len > 0:
    echo -n f"Removing { len(rm_param) } Brave Singletons... "
    rm -f @(rm_param)
    echo "Done."

echo f"Creating distrobox instance [{ distrobox_name }]..."
./create-distrobox.xsh @(distrobox_name)
