#! /usr/bin/env bash

source "${HOME}/.path.d/50_mise.bash"
eval "$(${MISE} hook-env)"

echo "Installing rust"
${MISE} install rust@latest
${MISE} use -g rust@latest
eval "$(${MISE} hook-env)"
rustup component add rust-analyzer
# install shell completions
mkdir -p "${HOME}/.rust/shell"
rustup completions bash >"${HOME}/.rust/shell/completion_rustup.bash"
rustup completions bash cargo >"${HOME}/.rust/shell/completion_cargo.bash"
rustup completions zsh >"${HOME}/.rust/shell/_rustup"
rustup completions zsh cargo >"${HOME}/.rust/shell/_cargo"
