[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Claude shortcuts
alias cgh='claude /Volumes/Primary/GitHub'
function cghr() { claude "/Volumes/Primary/GitHub/${1}"; }
# --- Quick navigation commands ---
function home() { cd ~ ${1:+/"$1"}; }
function github() { cd /Volumes/Primary/GitHub ${1:+/"$1"}; }
function desktop() { cd ~/Desktop ${1:+/"$1"}; }
