# -*- mode: sh; -*-
# Rivo prompt set-up

local __GIT_PROMPT_DIR=~/.zsh/git-prompt-python

# Allow for functions in the prompt
setopt prompt_subst 

# Enable auto-execution of functions
typeset -ga preexec_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions

# Append git functions needed for prompts to various hooks
# Executed before each prompt
precmd_functions+='precmd_update_git_vars'
# Executed after a command has been read and is to be executed
preexec_functions+='preexec_update_git_vars'
# Executed after a directory change
chpwd_functions+='chpwd_update_git_vars'

# Append titlebar functions
precmd_functions+='precmd_titlebar'
preexec_functions+='preexec_titlebar'

# precmd_functions+='fill_space'

# Load colors
autoload -U colors
colors

# Set some colors
local reset="%{${reset_color}%}"

for color in red green blue cyan  yellow magenta black white; do
    local $color b_$color
    eval $color='%{$fg[${color}]%}'
    eval b_$color='%{$fg_bold[${color}]%}'
done

# Colors for root and normal users
local root_color=${red}
local user_color=${green}

# Default values for the appearance of the prompt. Configure at will.
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
ZSH_THEME_GIT_PROMPT_BRANCH="${b_blue}"
ZSH_THEME_GIT_PROMPT_STAGED="${red}●"
ZSH_THEME_GIT_PROMPT_CONFLICTS="${red}✖"
ZSH_THEME_GIT_PROMPT_CHANGED="${b_magenta}✚"
ZSH_THEME_GIT_PROMPT_REMOTE=""
ZSH_THEME_GIT_PROMPT_UNTRACKED="${b_yellow}⚡"
ZSH_THEME_GIT_PROMPT_UNTRACKED_MANY="…"
ZSH_THEME_GIT_PROMPT_CLEAN="${b_green}✔"


PROMPT='%B%~%b$(git_super_status)${(e)spacing}$(user_and_host)
${reset}%# '

RPROMPT='${red}%B%t%b${reset}'

user_and_host() {
    local UH
    if [ "`id -u`" -eq 0 ] || [[ "$USER" = 'root' ]]; then
        UH="${root_color}%m"
    else
        UH="${user_color}%n@%m"
    fi
    echo "$UH"
}

fill_space() {
    local char=' '
    local termwidth
    ((termwidth=${COLUMNS} - 1))

    local pwd_width=${#${(%):-%~}}
    local git_width=${#$(git_super_status)}
    if [ $git_width != 0 ]; then
	((git_width=$git_width + 10))
    fi
    # local uh_width=${#$(user_and_host)}
    
    spacing="\${(l.(($termwidth - ($pwd_width + $git_width + 11) ))..${char}.)}"

    # local spacing=""
    # ((termwidth=$termwidth - ($pwd_width + 11)))
    # for k in {1..$termwidth}; do
    # 	spacing="${spacing} "
    # done
    # echo $spacing
}

git_super_status() {
    local STATUS
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
	STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH$GIT_BRANCH${reset}"
	if [ -n "$GIT_REMOTE" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_REMOTE$GIT_REMOTE${reset}"
	fi
	STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
	if [ "$GIT_STAGED" -ne "0" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED${reset}"
	fi
	if [ "$GIT_CONFLICTS" -ne "0" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS${reset}"
	fi
	if [ "$GIT_CHANGED" -ne "0" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED${reset}"
	fi
	if [ "$GIT_UNTRACKED" -ne "0" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
	    if [ "$GIT_UNTRACKED" -lt "10" ]; then
		STATUS="$STATUS$GIT_UNTRACKED${reset}"
	    else
		STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED_MANY${reset}"
	    fi
	fi
	if [ "$GIT_CLEAN" -eq "1" ]; then
	    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
	fi
	STATUS="$STATUS${reset}$ZSH_THEME_GIT_PROMPT_SUFFIX"
	echo "$STATUS"
    fi
}

#### Manage cache
local __UPDATE_GIT_PR=1

# Variables used to store git status
local _GIT_STATUS
local __CURRENT_GIT_STATUS
local GIT_BRANCH
local GIT_REMOTE
local GIT_STAGED
local GIT_CONFLICTS
local GIT_CHANGED
local GIT_UNTRACKED
local GIT_CLEAN

function precmd_update_git_vars() {
    if [ -n "$__UPDATE_GIT_PR" ]; then
    	update_current_git_vars
        unset __UPDATE_GIT_PR
    fi
}

function preexec_update_git_vars() {
    case "$2" in
        git*)
        __UPDATE_GIT_PR=1
        ;;
    esac
}

function chpwd_update_git_vars() {
     __UPDATE_GIT_PR=1
}

function update_current_git_vars() {
    unset _GIT_STATUS
    unset __CURRENT_GIT_STATUS

    local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
    _GIT_STATUS=`python ${gitstatus}`
    __CURRENT_GIT_STATUS=("${(@f)_GIT_STATUS}")
    GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
    GIT_REMOTE=$__CURRENT_GIT_STATUS[2]
    GIT_STAGED=$__CURRENT_GIT_STATUS[3]
    GIT_CONFLICTS=$__CURRENT_GIT_STATUS[4]
    GIT_CHANGED=$__CURRENT_GIT_STATUS[5]
    GIT_UNTRACKED=$__CURRENT_GIT_STATUS[6]
    GIT_CLEAN=$__CURRENT_GIT_STATUS[7]
}

#### Manage titlebar
function precmd_titlebar(){
    titlebar "%~"
}

function preexec_titlebar(){
    titlebar $1
}

function titlebar() {
    [[ -t 1 ]] || return
    case $TERM in
	xterm*|rxvt*|(dt|k|E)term)
	    print -Pn "\e]0; %n@%M|%y| %# $1\a"
	    ;;
	screen)
	    print -Pn "\e]0;$1\a"
	    ;;
    esac
}

