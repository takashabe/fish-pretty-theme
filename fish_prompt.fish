function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  set -l show_untracked (git config --bool bash.showUntrackedFiles)
  set untracked ''
  if [ "$theme_display_git_untracked" = 'no' -o "$show_untracked" = 'false' ]
    set untracked '--untracked-files=no'
  end
  echo (command git status -s --ignore-submodules=dirty $untracked ^/dev/null)
end

function _is_macos
  echo (command uname -a | grep 'Darwin' ^/dev/null)
end

function fish_prompt
  # base colors: soralized (http://ethanschoonover.com/solarized)
  set -l cyan (set_color -o 2aa198)
  set -l yellow (set_color -o b58900)
  set -l red (set_color -o dc322f)
  set -l blue (set_color -o 268bd2)
  set -l green (set_color -o 2aa198)
  set -l normal (set_color normal)

  if test $status = 0
      set arrow "\U1F41F " # fish
  else
      set arrow "\U1F4A3 " # bomb
  end
  set -l cwd $cyan(prompt_pwd)

  if test (_git_branch_name)
    set -l git_branch (_git_branch_name)
    set git_info "$blue- $git_branch"

    if test (_is_git_dirty)
      set -l dirty "$red*"
      set git_info "$git_info$dirty"
    end
  end

  if _is_macos
    printf "$arrow $cwd $git_info $normal"
  else
    echo -n -s -e $arrow ' ' $cwd $git_info $normal ' '
  end
end
