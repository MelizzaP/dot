############ General ############
function reload-config
  source ~/.config/fish/config.fish
end

function local
  source ~/.localrc
end

function kill-port
  kill -kill lsof -t -i :$argv
end

function go-home
    cd $HOME
end

########### Git ###############
function gsq
  git rebase -i HEAD-$argv
end

function conflicts
  git ls-files -u
end

function force-push
  git push --force-with-lease
end

function review-requests 
  gh pr list -S user-review-requested:$ME
end

function set-github-cred
  ssh-add -D
  ssh-add $HOME/.ssh/$argv
end

function git-diff-commit --description 'Pretty print the commit history diff b/w 2 branches'
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative $argv[1]..$argv[2]
end

function set-gitemail
  git config --global user.email $argv
end

function personal-github
 set-github-cred $PERSONAL_GITHUB_KEY
 set-gitemail $PERSONAL_EMAIL
end

function professional-github
 set-github-cred $PROF_GITHUB_KEY
 set-gitemail $PROF_EMAIL
end

############ NVim ############
set -x VISUAL nvim
function vim
  nvim
end

function vi
  nvim $argv -u $HOME/.config/nvim/init.vim
end

########## dotenv ##########
function dotenv --description 'Load environment variables from .env file'
  set -l envfile ".env"
  if [ (count $argv) -gt 0 ]
    set envfile $argv[1]
  end

  if test -e $envfile
    for line in (cat $envfile)
      set -xg (echo $line | cut -d = -f 1) (echo $line | cut -d = -f 2-)
    end
  end
end
