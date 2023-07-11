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

function ga
  git add $argv
end

function gas
  git add $argv
  git status
end

function gb
  git branch
end

function gbg
  git branch | grep
end

function gco
  git checkout $argv
end

function gd
  git diff
end

function gdc
  git diff --cached
end

function gm
  git commit -m $argv
end

function gl
  git pull
end

function amend
  git commit --amend
end

function gs
  git status
end

function gst
  git stash
end

function gsp
  git stash pop
end

function fetch-n-force
  git fetch
  git rebase origin/master
  force-push
end

function set-github-cred
  ssh-add -D
  ssh-add $HOME/.ssh/$argv
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

function review-requests
  echo "My review requests:"
  gh pr list -l Ready\ for\ Review -S "user-review-requested:@me"

  echo "Signup team review requests:"
  gh pr list -l Ready\ for\ Review -S  "team-review-requested:joinpapa/signup"
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
