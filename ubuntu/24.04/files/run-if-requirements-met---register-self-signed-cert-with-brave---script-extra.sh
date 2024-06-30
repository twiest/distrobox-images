tnet_ca_file="/usr/share/ca-certificates/tnet/tnet-self-signed-ca-cert.crt"
tnet_ca_name=$(basename $tnet_ca_file)
nssdb_dir="$HOME/.pki/nssdb"
pkcs11_file="${nssdb_dir}/pkcs11.txt"

for ca_file in $tnet_ca_file; do
  if ! [ -f "$ca_file" ]; then
    echo "skipping [$ca_file], ca_file doesn't exist"
    continue
  fi

  mkdir -p ${HOME}/.pki/nssdb
  certutil -d sql:${nssdb_dir} -A -t "C,C,C" -n "$tnet_ca_name" -i "$ca_file"
done
