[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Claude shortcuts
alias cgh='claude /Volumes/Primary/GitHub'
function cghr() { claude "/Volumes/Primary/GitHub/${1}"; }
