#!/usr/bin/env bash

get_os() {
	os="$(uname -s)"
	if [ "$os" = Darwin ]; then
		echo "apple-darwin"
	elif [ "$os" = Linux ]; then
		echo "unknown-linux-musl"
	else
		error "unsupported OS: $os"
	fi
}

get_arch() {
	arch="$(uname -m)"
	if [ "$arch" = x86_64 ]; then
		echo "x86_64"
	elif [ "$arch" = aarch64 ] || [ "$arch" = arm64 ]; then
		echo "aarch64"
	else
		error "unsupported architecture: $arch"
	fi
}

update_zoxide() {
	echo "Updating zoxide..."
	os="$(get_os)"
	if [[ "${os}" == "macos" ]]; then
		brew install zoxide
	else
		arch="$(get_arch)"
		mkdir -p "${HOME}/bin"
		latest=$(curl -s https://api.github.com/repositories/245166720/tags | jq -r ".[0].name")
		echo "Latest release seems to be: ${latest}"
		TMPDIR=$(mktemp -d /tmp/zoxide.XXXXXX) || exit 1
		if ! curl -sL "https://github.com/ajeetdsouza/zoxide/releases/download/${latest}/zoxide-${latest#v}-${arch}-unknown-linux-musl.tar.gz" -o "${TMPDIR}/zoxide.tar.gz"; then
			echo "Download failed. Aborting."
			exit 1
		fi
		cd "${TMPDIR}" || exit
		tar xf zoxide.tar.gz
		cp zoxide "${HOME}/bin/zoxide"
		chmod 755 "${HOME}/bin/zoxide"
		rm -rf "${TMPDIR}"
	fi
	echo "done."
}

update_zoxide
