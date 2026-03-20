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

function vpn_staging
  tailscale configure kubeconfig staging-eks
end

function vpn_prod
  tailscale configure kubeconfig prod-eks
end

function load_assistant2
  vpn_staging
  load_staging
  echo "Loading Environment Variables"
  source .env.assistant2
  echo "Port Forwarding DB"
  kubectl port-forward svc/assistant-2-postgresql-rw 5432:5432 -n assistant-2 &
  sleep 2
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
  else if test "$NAMESPACE" = "hatch-scheduler-assistant"
    gh workflow run $WORKSPACE_ID_CD -f environment=$env -f REF=(git branch --show-current)
  else
    set_color yellow
    echo "No deploy command configured for namespace: $NAMESPACE"
    set_color normal
    return 1
  end
end

######### DB ##########
function query_prod --description 'Open readonly production db in postgres CLI'
  tailscale configure kubeconfig prod-eks
  pgcli $PROD_DB
end

function query_staging --description 'Open staging db in pgcli'
  tailscale configure kubeconfig staging-eks
  kubectl port-forward -n staging svc/staging-postgresql-rw 15432:5432 & sleep 2
  env PGPASSWORD=(kubectl get secret staging-postgresql-role-hatch-elixir -n staging -o jsonpath='{.data.password}' | base64 -d) \
  PGSSLMODE=disable \
  pgcli -h 127.0.0.1 -p 15432 -U hatch-elixir
  pkill -f "kubectl port-forward -n staging svc/staging-postgresql-rw 15432:5432"
end

function query_assistant --description 'Open assistant staging db in pgcli'
  tailscale configure kubeconfig staging-eks
  kubectl port-forward -n assistant svc/assistant-postgresql-rw 15432:5432 & sleep 2
  env PGPASSWORD=(kubectl get secret assistant-postgresql-role-hatch-elixir -n assistant -o jsonpath='{.data.password}' | base64 -d) \
  PGSSLMODE=disable \
  pgcli -h 127.0.0.1 -p 15432 -U hatch-elixir
  pkill -f "kubectl port-forward -n assistant svc/assistant-postgresql-rw 15432:5432"
end

function query_assistant2 --description 'Open assistant-2 staging db in pgcli'
  tailscale configure kubeconfig staging-eks
  kubectl port-forward -n assistant-2 svc/assistant-2-postgresql-rw 15432:5432 & sleep 2
  env PGPASSWORD=(kubectl get secret assistant-2-postgresql-role-hatch-elixir -n assistant-2 -o jsonpath='{.data.password}' | base64 -d) \
  PGSSLMODE=disable \
  pgcli -h 127.0.0.1 -p 15432 -U hatch-elixir
  pkill -f "kubectl port-forward -n assistant-2 svc/assistant-2-postgresql-rw 15432:5432"
end

