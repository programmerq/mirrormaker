#!/bin/bash

directory=$1
gpg_fingerprint="EE6D536CF7DC86E2D7D56F59A178AC6C6238F52E"

key_servers="
ha.pool.sks-keyservers.net
pgp.mit.edu
keyserver.ubuntu.com
"

rpm_import_repository_key() {
	local key=$1;
	local tmpdir=$2;
	for key_server in $key_servers ; do
		gpg --keyserver "$key_server" --recv-keys "$key" && break
	done
	gpg -k "$key" >/dev/null
	gpg --export --armor "$key" > "$tmpdir"/repo.key
	rm -rf /root/.gnupg
}

rpm_import_repository_key "$gpg_fingerprint" "$directory"
