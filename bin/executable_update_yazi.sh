#!/usr/bin/env bash

get_os() {
	os="$(uname -s)"
	if [ "$os" = Darwin ]; then
		echo "apple-darwin"
	elif [ "$os" = Linux ]; then
		echo "unknown-linux-gnu"
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

update_yazi() {
	echo "Updating yazi..."
	os="$(get_os)"
	if [[ "${os}" == "macos" ]]; then
		brew install yazi
	else
		arch="$(get_arch)"
		mkdir -p "${HOME}/bin"
		mkdir -p "${HOME}/.yazi"
		latest=$(curl -s https://api.github.com/repositories/663900193/tags | jq -r ".[0].name")
		echo "Latest release seems to be: ${latest}"
		TMPDIR=$(mktemp -d /tmp/yazi.XXXXXX) || exit 1
		if ! curl -sL "https://github.com/sxyazi/yazi/releases/download/${latest}/yazi-${arch}-${os}.zip" -o "${TMPDIR}/yazi.zip"; then
			echo "Download failed. Aborting."
			exit 1
		fi
		cd "${TMPDIR/}" || exit
		unzip yazi.zip
		cd "yazi-${arch}-${os}" || exit
		cp yazi "${HOME}/bin/yazi"
		chmod 755 "${HOME}/bin/yazi"
		cp completions/{ya,yazi}.bash "${HOME}/.yazi/"
		rm -rf "${TMPDIR}"
	fi
	echo "done."
}

update_yazi
