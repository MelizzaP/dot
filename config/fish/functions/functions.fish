set -x ME "MelizzaP"
source ~/.config/fish/functions/hatch.fish
source ~/.config/fish/functions/speak_lines.fish
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

function toggle-dark-mode
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
end

function toggle-term-color
  set tmp_dir (pwd)
  cd $HOME/.dot
  git checkout -
  cd $tmp_dir
end

########### Git ###############
function gsq
  git rebase -i HEAD~$argv
end

function gs
  git status
end

function push-branch
  git push --set-upstream origin (git branch --show-current)
end

function conflicts
  git ls-files -u
end

function gp
  git push --force-with-lease
end

function gco
  git checkout
end

function gm
  git commit
end

function review-requests
  set_color green
  echo "------------------------------------------------"
  echo " checking for pr review requests for $ME "
  echo "------------------------------------------------"
  set_color normal
  gh pr list -S user-review-requested:$ME
end

function git-view-commit --description 'Review a commit for a given sha'
   git rev-list --format=%B --max-count=1 $agrv[1]
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

######### AI ##########
function ask_gemini --description 'Curl gemini API for an answer'
echo -e (curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d "{ \"contents\": [{ \"parts\":[{\"text\": \"$argv\"}] }] }" \
  |  jq '.candidates[0].content.parts[0].text')
end

function ask_ai --description 'Curl openai API for an answer'
  echo -e (curl https://api.openai.com/v1/responses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{ \"model\": \"gpt-4o\", \"input\": \"$argv\" }" \
  | jq '.output[0]["content"][0]["text"]')
end

function openai_models --description 'Curl available models'
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  | jq '.'
end

function openai_usage --description 'Open web browser with openai api usage'
  open "https://platform.openai.com/usage"
end
