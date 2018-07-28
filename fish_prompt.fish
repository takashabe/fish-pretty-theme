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

function _k8s_namespace
  set -l ns (cat $HOME/.kube/config | grep 'namespace' | cut -f 2 -d ':' | string trim)
  if test -n $ns
    echo $ns
  else
    echo 'default'
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
    set arrow "\U1F41F" # fish
  else
    set arrow "\U1F4A3" # bomb
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

  set -l k8s_ctx_raw (_k8s_context_name)
  if test -n $k8s_ctx_raw
    if test -n "$K8S_PRODUCTION_CONTEXT" -a $k8s_ctx_raw = "$K8S_PRODUCTION_CONTEXT"
      set k8s_ctx_info "$red$k8s_ctx_raw"
    else
      set k8s_ctx_info "$yellow$k8s_ctx_raw"
    end
  end

  set -l k8s_ns_raw (_k8s_namespace)
  if test -n $k8s_ns_raw
    set k8s_ns_info "$blue($k8s_ns_raw)"
  end

  printf "$arrow $k8s_ctx_info$k8s_ns_info $cwd$git_info $normal"
end
