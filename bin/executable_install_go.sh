#! /usr/bin/env bash

SW=$(readlink -f "${HOME}/software")
if [[ -z "$SW" ]]; then
	os="$(get_os)"
	if [[ "${os}" == "macos" ]]; then
		mkdir ~/Software
	else
		mkdir ~/software
	fi
fi

GOPATH=$(readlink -f "${HOME}/software")/go
export GOPATH
export PATH="${GOPATH}/bin:${PATH}"

echo bla
source "${HOME}/.path.d/50_mise.bash"
echo blub
eval "$(${MISE} hook-env)"
echo foo
${MISE} install go@latest
echo bar
${MISE} use -g go@latest
echo baz
# ${MISE} reshim
# eval "$(${MISE} hook-env)"
type go
