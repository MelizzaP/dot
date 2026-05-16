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
  tailscale up
  tailscale configure kubeconfig staging-eks
end

function vpn_prod
  tailscale up
  tailscale configure kubeconfig prod-eks
end

function vpn_disconnect
  tailscale down
  kubectl config unset current-context
end

function load_assistant
  vpn_staging
  echo "Loading Environment Variables"
  source .env.assistant
  echo "Port Forwarding DB"
  kubectl port-forward -n assistant assistant-postgresql-1 5432:5432 &
  sleep 2
end

function load_assistant2
  vpn_staging
  echo "Loading Environment Variables"
  source .env.assistant2
  echo "Port Forwarding DB"
  kubectl port-forward -n assistant-2 assistant-2-postgresql-1 5432:5432 &
  sleep 2
end

function list_review_ready_prs
  review-requests

  for team in Hatch1fy/agents Hatch1fy/backend Hatch1fy/engineering
    set -l label "  checking for pr review requests for $team  "
    set -l rule (string repeat -n (string length -- $label) -)
    set_color magenta
    echo $rule
    echo $label
    echo $rule
    set_color normal
    gh pr list -S team-review-requested:$team
  end
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

function _query_staging_pg --argument-names namespace
  set -l svc $namespace-postgresql-rw
  set -l secret $namespace-postgresql-role-hatch-elixir
  set -l forward "kubectl port-forward -n $namespace svc/$svc 15432:5432"

  tailscale configure kubeconfig staging-eks
  eval $forward & sleep 2
  env PGPASSWORD=(kubectl get secret $secret -n $namespace -o jsonpath='{.data.password}' | base64 -d) \
    PGSSLMODE=disable \
    pgcli -h 127.0.0.1 -p 15432 -U hatch-elixir
  pkill -f "$forward"
end

function query_staging --description 'Open staging db in pgcli'
  _query_staging_pg staging
end

function query_assistant --description 'Open assistant staging db in pgcli'
  _query_staging_pg assistant
end

function query_assistant2 --description 'Open assistant-2 staging db in pgcli'
  _query_staging_pg assistant-2
end

