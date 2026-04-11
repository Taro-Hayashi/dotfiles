[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Claude shortcuts
alias cgh='claude /Volumes/Primary/GitHub'
function cghr() { claude "/Volumes/Primary/GitHub/${1}"; }
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/hayashi/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
