# based loosely on mira theme
# GoesByJim Theme, for your viewing pleasure.
#
# ✅ Context-aware language version indicators (jenv, nvm, go)
# ✅ Only shows language versions when in relevant project directories
# ✅ Efficient single directory traversal using precmd hook
#
# Environment variables:
# - GOESBYJIM_JENV: set to "hide" to completely disable jenv display.
# - ZSH_THEME_[LANG]_PROMPT_PREFIX: can be set to override color, text, etc of the lang prompt.
# - ZSH_THEME_[LANG]_PROMPT_SUFFIX: can be set to override end of lang prompt, must call $reset_color somewhere.

ZSH_THEME_NVM_PROMPT_PREFIX="%{$fg[green]%}‹node-"
ZSH_THEME_NVM_PROMPT_SUFFIX="›%{$reset_color%} "

ZSH_THEME_JENV_PROMPT_PREFIX="%{$fg[green]%}‹jenv-"
ZSH_THEME_JENV_PROMPT_SUFFIX="›%{$reset_color%} "

ZSH_THEME_GO_PROMPT_PREFIX="%{$fg[green]%}‹go-"
ZSH_THEME_GO_PROMPT_SUFFIX="›%{$reset_color%} "

# Detect if a project is a certain lang, all the way up to root /
# Sets a flag for later usage if within such a context:
#   _GOESBYJIM_HAS_JAVA - Maven/Gradle projects
#   _GOESBYJIM_HAS_NODE - Node.js projects
#   _GOESBYJIM_HAS_GO   - Go projects
# Called automatically via precmd hook before each prompt.
function goesbyjim_detect_projects() {
  _GOESBYJIM_HAS_JAVA=0
  _GOESBYJIM_HAS_NODE=0
  _GOESBYJIM_HAS_GO=0

  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    # Check for Java/Maven/Gradle
    if [[ $_GOESBYJIM_HAS_JAVA -eq 0 ]]; then
      if [[ -f "$dir/pom.xml" ]] || [[ -f "$dir/build.gradle" ]] || [[ -f "$dir/build.gradle.kts" ]] || [[ -f "$dir/settings.gradle" ]] || [[ -f "$dir/settings.gradle.kts" ]]; then
        _GOESBYJIM_HAS_JAVA=1
      fi
    fi

    # Check for Node.js
    if [[ $_GOESBYJIM_HAS_NODE -eq 0 ]]; then
      if [[ -f "$dir/package.json" ]] || [[ -f "$dir/yarn.lock" ]] || [[ -f "$dir/package-lock.json" ]] || [[ -f "$dir/pnpm-lock.yaml" ]]; then
        _GOESBYJIM_HAS_NODE=1
      fi
    fi

    # Check for Go
    if [[ $_GOESBYJIM_HAS_GO -eq 0 ]]; then
      if [[ -f "$dir/go.mod" ]] || [[ -n "$(find "$dir" -maxdepth 1 -name "*.go" 2>/dev/null | head -n 1)" ]]; then
        _GOESBYJIM_HAS_GO=1
      fi
    fi

    # Exit early if all found
    if [[ $_GOESBYJIM_HAS_JAVA -eq 1 && $_GOESBYJIM_HAS_NODE -eq 1 && $_GOESBYJIM_HAS_GO -eq 1 ]]; then
      break
    fi

    dir="$(dirname "$dir")"
  done
}

function goesbyjim_jenv {
  if [[ "hide" = "${GOESBYJIM_JENV}" ]]; then
    return ""
  fi
  which jenv &>/dev/null || return
  [[ $_GOESBYJIM_HAS_JAVA -eq 0 ]] && return

  local jvm_prompt=${$(jenv version-name 2>/dev/null)#v}
  if [[ "$jvm_prompt" == "system" ]]; then
    return
  fi
  echo "${ZSH_THEME_JENV_PROMPT_PREFIX}${jvm_prompt:gs/%/%%}${ZSH_THEME_JENV_PROMPT_SUFFIX}"
}

function goesbyjim_nvm() {
  which nvm &>/dev/null || return
  [[ $_GOESBYJIM_HAS_NODE -eq 0 ]] && return

  local nvm_prompt=${$(nvm current)#v}
  if [[ "$nvm_prompt" == "system" ]]; then
    return
  fi
  echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt:gs/%/%%}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}

function goesbyjim_go() {
  which go &>/dev/null || return
  [[ $_GOESBYJIM_HAS_GO -eq 0 ]] && return

  local go_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
  if [[ -z "$go_version" ]]; then
    return
  fi
  echo "${ZSH_THEME_GO_PROMPT_PREFIX}${go_version:gs/%/%%}${ZSH_THEME_GO_PROMPT_SUFFIX}"
}

local current_dir="%B%{$fg[cyan]%}%c%{$reset_color%}"
# local current_dir='%{$terminfo[bold]$fg[cyan]%} %c%{$reset_color%}'

# precmd is a ZSH hook which runs at the start of the prompt render.
# see https://zsh.sourceforge.io/Doc/Release/Functions.html#Hook-Functions
precmd() {
  goesbyjim_detect_projects
}

local return_code="%(?:%{$fg_bold[green]%}%1{➜%}:%{$fg_bold[red]%}%1{✗%})%{$reset_color%} "
local git_branch='$(git_prompt_info)'
local nvm_node='$(goesbyjim_nvm)'
local jenv_info='$(goesbyjim_jenv)'
local go_info='$(goesbyjim_go)'

PROMPT="${return_code}〉${current_dir} 〉${nvm_node}${jenv_info}${go_info}${git_branch}» %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[yellow]%}git:(%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}) %{$fg[red]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[yellow]%})"
