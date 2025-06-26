set -x ME "MelizzaP"
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
  echo "(set color purple)  checking for pr review requests for $ME (set color normal)"
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

######### VPN ##########

function vpn -a connect_to maybe_disconnect_from
  # checking the status & possibly disconnecting from this VPN
  set status_line_str (tunnelblickctl status | grep "^$maybe_disconnect_from")
  set status_line_list (string split ' ' (string trim -- $status_line_str | string replace -ar '\s+' ' '))
  if test "$status_line_list[2]" = "CONNECTED"
    echo "󱠽 Disconnecting from the $maybe_disconnect_from VPN..."
    tunnelblickctl disconnect $maybe_disconnect_from

    while true
      set status_line_str (tunnelblickctl status | grep "^$maybe_disconnect_from")
      set status_line_list (string split ' ' (string trim -- $status_line_str | string replace -ar '\s+' ' '))
      if test "$status_line_list[2]" = "EXITING"
        echo "󰌙 disconnected"
        break
      end
      sleep 1
    end
  else
    echo "󰩐 already disconnected from $maybe_disconnect_from VPN"
  end

  set status_line_str (tunnelblickctl status | grep "^$connect_to")
  set status_line_list (string split ' ' (string trim -- $status_line_str | string replace -ar '\s+' ' '))
  if test "$status_line_list[2]" = "CONNECTED"
    echo "󰩐 already connected from $connect_to VPN"
  else
    echo "󱠽 Connecting to the $connect_to VPN..."
    tunnelblickctl connect $connect_to
    while true
      set status_line_str (tunnelblickctl status | grep "^$connect_to")
      set status_line_list (string split ' ' (string trim -- $status_line_str | string replace -ar '\s+' ' '))
      if test "$status_line_list[2]" = "CONNECTED"
        echo "󰌘"
        echo " connected"
        break
      end
      printf " "
      sleep 1
    end
  end
end


######### DB ##########
function query_prod --description 'Open readonly production db in postgres CLI'
  vpn prod staging
  psql $PROD_DB
end

function query_staging --description 'Open staging db in postgres CLI'
  vpn staging prod
  psql $STAGING_DB
end
