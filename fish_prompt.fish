function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty $untracked ^/dev/null)
end

function _k8s_context_name
  set -l ctx (cat $HOME/.kube/config | grep 'current-context' | cut -f 2 -d ':' | string trim)
  if string match -q 'gke*' $ctx
    echo (echo $ctx | cut -f 4 -d '_')
  else
    echo $ctx
  end
end

function _get_prompt_icon
  set -l icon "$PROMPT_ICON"
  if test -n $icon
    echo $icon
  else
    echo "\U1F41F" # fish
  end
end

function _get_prompt_error_icon
  set -l icon "$PROMPT_ERROR_ICON"
  if test -n $icon
    echo $icon
  else
    echo "\U1F4A3" # bomb
  end
end

function fish_prompt
  set -l last_status $status

  # base colors: soralized (http://ethanschoonover.com/solarized)
  set -l cyan (set_color -o 2aa198)
  set -l yellow (set_color -o b58900)
  set -l red (set_color -o dc322f)
  set -l blue (set_color -o 268bd2)
  set -l green (set_color -o 2aa198)
  set -l normal (set_color normal)

  if test $last_status = 0
    set arrow (_get_prompt_icon)
  else
    set arrow (_get_prompt_error_icon)
  end
  set -l cwd $cyan(prompt_pwd)

  if test (_git_branch_name)
    set -l git_branch (_git_branch_name)
    set git_info " $blue- $git_branch"

    if test (_is_git_dirty)
      set -l dirty "$red*"
      set git_info "$git_info$dirty"
    end
  end

  set -l k8s_raw (_k8s_context_name)
  if test -n $k8s_raw
    if test -n "$K8S_PRODUCTION_CONTEXT" -a $k8s_raw = "$K8S_PRODUCTION_CONTEXT"
      set k8s_info "$red$k8s_raw "
    else
      set k8s_info "$yellow$k8s_raw "
    end
  end

  printf "$arrow $k8s_info$cwd$git_info $normal"
end
