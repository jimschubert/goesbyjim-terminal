# based loosely on mira theme
ZSH_THEME_NVM_PROMPT_PREFIX="%{$fg[green]%}‹node-"
ZSH_THEME_NVM_PROMPT_SUFFIX="›%{$reset_color%} "

ZSH_THEME_JENV_PROMPT_PREFIX="%{$fg[green]%}‹jenv-"
ZSH_THEME_JENV_PROMPT_SUFFIX="›%{$reset_color%} "

function goesbyjim_jenv {
  if [[ "hide" = "${GOESBYJIM_JENV}" ]]; then
    return ""
  fi
  which jenv &>/dev/null || return
  local jvm_prompt=${$(jenv version-name 2>/dev/null)#v}
  if [[ "$jvm_prompt" == "system" ]]; then
    return
  fi
  echo "${ZSH_THEME_JENV_PROMPT_PREFIX}${jvm_prompt:gs/%/%%}${ZSH_THEME_JENV_PROMPT_SUFFIX}"
}

function goesbyjim_nvm() {
  which nvm &>/dev/null || return
  local nvm_prompt=${$(nvm current)#v}
  if [[ "$nvm_prompt" == "system" ]]; then
    return
  fi
  echo "${ZSH_THEME_NVM_PROMPT_PREFIX}${nvm_prompt:gs/%/%%}${ZSH_THEME_NVM_PROMPT_SUFFIX}"
}

local current_dir="%B%{$fg[cyan]%}%c%{$reset_color%}"
# local current_dir='%{$terminfo[bold]$fg[cyan]%} %c%{$reset_color%}'

local return_code="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{✗ %})%{$reset_color%}"
local git_branch='$(git_prompt_info)'
local nvm_node='$(goesbyjim_nvm)'
local jenv_info='$(goesbyjim_jenv)'

PROMPT="${return_code}〉${current_dir} 〉${nvm_node}${jenv_info}${git_branch}» %{$reset_color%}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[yellow]%}git:(%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}) %{$fg[red]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[yellow]%})"
