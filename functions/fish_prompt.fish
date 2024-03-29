function _git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty $untracked 2> /dev/null)
end

function _xdg_config_home
  set -l dir "$XDG_CONFIG_HOME"
  if test -n $dir
    echo $dir
  else
    echo "$HOME/.config"
  end
end

function _k8s_context_name
  if test ! -e $HOME/.kube/config
    echo ""
    return
  end

  set -l ctx (cat $HOME/.kube/config | grep 'current-context' | cut -f 2 -d ':' | string trim)
  echo $ctx
end

function _k8s_short_context_name
  set -l ctx (_k8s_context_name)
  if string match -q 'gke*' $ctx
    echo (echo $ctx | cut -f 4 -d '_')
  else
    echo $ctx
  end
end

function _k8s_namespace
  set -l ctx (_k8s_context_name)
  # TODO: Too slow...
  set -l ns (kubectl config view -o=jsonpath="{.contexts[?(@.name==\""{$ctx}\"")].context.namespace}")
  if test -n "$ns"
    echo $ns
  else
    echo 'default'
  end
end

function _gcloud_project
  set -l config_home (_xdg_config_home)

  if test ! -e "$config_home"/gcloud/active_config
    echo ''
    return
  end

  set -l prj (cat "$config_home"/gcloud/configurations/"config_"(cat "$config_home"/gcloud/active_config) | grep project | awk -F ' = ' '{print $2}')
  if test -n "$prj"
    echo $prj
  else
    echo ''
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

  # optional prompt
  set -l flag_k8s_context $PROMPT_ENABLE_K8S_CONTEXT
  set -l flag_k8s_namespace $PROMPT_ENABLE_K8S_NAMESPACE
  set -l flag_gcloud_project $PROMPT_ENABLE_GCLOUD_PROJECT
  set -l flag_show_err_status $PROMPT_SHOW_ERR_STATUS

  # sonokai-andromeda
  # https://gist.github.com/sainnhe/e5c4512d5bcfcb46afd493beb86223c6
  set -l background (set_color 2b2d3a)
  set -l foreground (set_color e1e3e4)
  set -l black      (set_color 181a1c)
  set -l red        (set_color fb617e)
  set -l green      (set_color 9ed06c)
  set -l yellow     (set_color edc763)
  set -l blue       (set_color 6dcae8)
  set -l magenta    (set_color bb97ee)
  set -l cyan       (set_color f89860)
  set -l white      (set_color e1e3e4)

  set -l now $magenta(date "+[%H:%M:%S]")

  if test $last_status = 0
    set arrow $foreground(_get_prompt_icon)
  else
    set arrow $red(_get_prompt_error_icon)
    if test -n $flag_show_err_status
      set arrow "$arrow $last_status"
    end
  end
  set -l cwd $green(prompt_pwd)

  if test (_git_branch_name)
    set -l git_branch (_git_branch_name)
    set git_info " $white- $git_branch"

    if test (_is_git_dirty)
      set -l dirty "$red*"
      set git_info "$git_info$dirty"
    end
  end

  if test $flag_k8s_context -eq 1
    set -l k8s_ctx_raw (_k8s_short_context_name)
    if test -n $k8s_ctx_raw
      if test -n "$K8S_PRODUCTION_CONTEXT" -a $k8s_ctx_raw = "$K8S_PRODUCTION_CONTEXT"
        set k8s_ctx_info " $red$k8s_ctx_raw"
      else
        set k8s_ctx_info " $green$k8s_ctx_raw"
      end
    end
  end

  if test $flag_k8s_namespace -eq 1
    set -l k8s_ns_raw (_k8s_namespace)
    if test -n $k8s_ns_raw
      set k8s_ns_info "$magenta($k8s_ns_raw)"
    end
  end

  if test $flag_gcloud_project -eq 1
    set -l gcloud_project (_gcloud_project)
    if test -n $gcloud_project
      set gcloud_project_info " $blue$gcloud_project"
    end
  end

  printf "$now$arrow$k8s_ctx_info$k8s_ns_info$gcloud_project_info $cwd$git_info $foreground"
end
