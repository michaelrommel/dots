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
	arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

	case "${arch}" in
	amd64) arch="x86_64" ;;
	armv*) arch="arm" ;;
	arm64) arch="aarch64" ;;
	esac

	# `uname -m` in some cases mis-reports 32-bit OS as 64-bit, so double check
	if [ "${arch}" = "x86_64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
		arch=i686
	elif [ "${arch}" = "aarch64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
		arch=arm
	fi

	printf '%s' "${arch}"
}

get_target() {
	arch="$1"
	platform="$2"
	target="$arch-$platform"

	if [ "${target}" = "arm-unknown-linux-musl" ]; then
		target="${target}eabihf"
	fi

	printf '%s' "${target}"
}

update_starship() {
	echo "Updating starship..."
	os="$(get_os)"
	if [[ "${os}" == "apple-darwin" ]]; then
		brew install starship
	else
		arch="$(get_arch)"
		TARGET="$(get_target "${arch}" "${os}")"
		mkdir -p "${HOME}/bin"
		TMPDIR=$(mktemp -d /tmp/starship.XXXXXX) || exit 1
		if ! curl -sL "https://github.com/starship/starship/releases//latest/download/starship-${TARGET}.tar.gz" -o "${TMPDIR}/starship.tar.gz"; then
			echo "Download failed. Aborting."
			exit 1
		fi
		cd "${TMPDIR}" || exit
		tar xf starship.tar.gz
		cp starship "${HOME}/.cargo/bin/starship"
		chmod 755 "${HOME}/.cargo/bin/starship"
		rm -rf "${TMPDIR}"
	fi
	echo "done."
}

update_starship
