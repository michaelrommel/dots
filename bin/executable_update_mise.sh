#!/bin/bash

source "${HOME}/bin/helper.sh"

update_mise() {
	echo "Updating mise..."
	platform="$(get_platform)"
	arch="$(get_arch)"
	if [ "$arch" = x86_64 ]; then
		echo "x64"
	elif [ "$arch" = aarch64 ]; then
		echo "arm64"
	else
		error "unsupported architecture: $arch"
	fi
	mkdir -p "${HOME}/bin"
	latest=$(curl -s https://api.github.com/repositories/586920414/tags | jq -r ".[0].name")
	echo "Latest release seems to be: ${latest}"
	if ! curl -sL "https://github.com/jdx/mise/releases/download/${latest}/mise-${latest}-${platform}-${arch}" >"${HOME}/bin/mise"; then
		echo "Download failed. Aborting."
		exit 1
	fi
	chmod 755 "${HOME}/bin/mise"
	MISE="${HOME}/bin/mise"
	export MISE
	echo "done."
}

update_mise
