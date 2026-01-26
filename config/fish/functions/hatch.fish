function get_staging_env
  $HOME/.cargo/bin/kubesecret
end

function kiex
  $HOME/.cargo/bin/kiex
end

function install_tools
  cargo install --path $HOME/.dot/cli/kubesecret
  cargo install --path $HOME/.dot/cli/kiex
end

function query_assistant --description 'Open assistant db in postgres CLI'
  load_assistant
  set -x PGPASSWORD (kubectl get secret assistant-postgresql-role-hatch-elixir -n assistant -o jsonpath='{.data.password}' | base64 -d)
  pgcli -h localhost -p 5432 -U hatch-elixir -d hatch-elixir
  pkill -f "kubectl port-forward svc/assistant-postgresql-rw"
end

function query_assistant2 --description 'Open assistant db in postgres CLI'
  load_assistant2
  set -x PGPASSWORD (kubectl get secret assistant-2-postgresql-role-hatch-elixir -n assistant-2 -o jsonpath='{.data.password}' | base64 -d)
  pgcli -h localhost -p 5432 -U hatch-elixir -d hatch-elixir
  pkill -f "kubectl port-forward svc/assistant-2-postgresql-rw"
end

function vpn_staging
  vpn staging prod
end

function load_assistant
  vpn_staging
  echo "Loading Environment Variables"
  source .env.assistant
  echo "Port Forwarding DB"
  kubectl port-forward svc/assistant-postgresql-rw 5432:5432 -n assistant &
  sleep 2
end

function load_assistant2
  vpn_staging
  echo "Loading Environment Variables"
  source .env.assistant2
  echo "Port Forwarding DB"
  kubectl port-forward svc/assistant-2-postgresql-rw 5432:5432 -n assistant-2 &
  sleep 2
end

function vpn_prod
  vpn prod staging
end

function list_review_ready_prs
  review-requests

  set_color magenta
  echo "---------------------------------------------------------"
  echo " checking for pr review requests for Hatch1fy/instruct "
  echo "---------------------------------------------------------"
  set_color normal

  gh pr list -S team-review-requested:Hatch1fy/instruct
  set_color magenta
  echo "--------------------------------------------------------"
  echo " checking for pr review requests for Hatch1fy/backend "
  echo "--------------------------------------------------------"
  set_color normal
  gh pr list -S team-review-requested:Hatch1fy/backend

  set_color magenta
  echo "------------------------------------------------------------"
  echo " checking for pr review requests for Hatch1fy/engineering "
  echo "------------------------------------------------------------"
  set_color normal
  gh pr list -S team-review-requested:Hatch1fy/engineering
end

function load_staging
  set_color yellow
  echo " loading staging environment "
  set_color normal

  set_color green
  echo " connecting to staging vpn"
  set_color normal
  vpn staging prod

  set_color magenta
  echo "󰍂 logging into "
  set_color normal
  aws sso login --profile staging

  set_color magenta
  echo " switching to  staging context"
  set_color normal
  kubectx staging
end

function load_prod
  set_color yellow
  echo " loading prod environment "
  set_color normal

  set_color green
  echo " connecting to prod vpn"
  set_color normal
  vpn prod staging

  set_color magenta
  echo "󰍂 logging into "
  set_color normal
  aws sso login --profile prod

  set_color magenta
  echo " switching to  prod context"
  set_color normal
  kubectx prod
end

function deploy --description 'Deploy current branch to environment'
  if not set -q WORKSPACE_ID_CD
    set_color red
    echo "Error: WORKSPACE_ID_CD environment variable must be set"
    set_color normal
    return 1
  end

  if not set -q env
    set_color red
    echo "Error: env environment variable must be set"
    set_color normal
    return 1
  end

  if not set -q NAMESPACE
    set_color red
    echo "Error: NAMESPACE environment variable must be set"
    set_color normal
    return 1
  end

  set_color green
  echo "🚀 deploying the current branch to env: $env"
  set_color normal

  if test "$NAMESPACE" = "hatch-elixir"
    gh workflow run $WORKSPACE_ID_CD -f ENVIRONMENT=$env -f REF=(git branch --show-current) -f HELM_REF="main"
  else if test "$NAMESPACE" = "livekit-agent"
    gh workflow run $WORKSPACE_ID_CD -f ENVIRONMENT=$env -f REF=(git branch --show-current)
  else
    set_color yellow
    echo "No deploy command configured for namespace: $NAMESPACE"
    set_color normal
    return 1
  end
end
