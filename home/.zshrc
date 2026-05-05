[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Claude shortcuts
alias cgh='claude /Volumes/Primary/GitHub'
function cghr() { claude "/Volumes/Primary/GitHub/${1}"; }
# --- Quick navigation commands ---
function home() { cd ~ ${1:+/"$1"}; }
function github() { cd /Volumes/Primary/GitHub ${1:+/"$1"}; }
function desktop() { cd ~/Desktop ${1:+/"$1"}; }

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/hayashi/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# OpenClaw Completion
source "/Users/hayashi/.openclaw/completions/openclaw.zsh"

export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/hayashi/.lmstudio/bin"
# End of LM Studio CLI section

export OLLAMA_API_BASE="http://mac-mini-2:11434"
