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

function vpn --description 'Manage tailscale VPN connection'
  set -l action $argv[1]
  if test -z "$action"
    set action (gum choose --header "󰖟 VPN action" staging prod disconnect)
  end
  if test -z "$action"
    return 1
  end

  switch $action
    case staging
      gum style --foreground 46 "󰖟 Connecting tailscale → staging-eks"
      tailscale up
      tailscale configure kubeconfig staging-eks
    case prod
      gum confirm "Connect to PRODUCTION cluster?"; or return 1
      gum style --foreground 196 "󰖟 Connecting tailscale → prod-eks"
      tailscale up
      tailscale configure kubeconfig prod-eks
    case disconnect
      gum style --foreground 245 "󰖟 Disconnecting tailscale"
      tailscale down
      kubectl config unset current-context
    case '*'
      gum style --foreground 196 "󰀦 Unknown action: $action"
      return 1
  end
end

function load_assistant
  vpn staging
  echo "Loading Environment Variables"
  source .env.assistant
  echo "Port Forwarding DB"
  kubectl port-forward -n assistant assistant-postgresql-1 5432:5432 &
  sleep 2
end

function load_assistant2
  vpn staging
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
    gum style --foreground 196 "󰀦 WORKSPACE_ID_CD environment variable must be set"
    return 1
  end

  if not set -q NAMESPACE
    gum style --foreground 196 "󰀦 NAMESPACE environment variable must be set"
    return 1
  end

  set -l selected_env (gum choose --header "󱓞 Deploy to which environment?" staging prod)
  if test -z "$selected_env"
    return 1
  end

  set -l branch (git branch --show-current)

  gum style --border rounded --padding "0 1" --border-foreground 46 \
    "󱓞 Deploy preview" \
    "󰘬 Branch:    $branch" \
    "󰖟 Env:       $selected_env" \
    "󰉋 Namespace: $NAMESPACE"

  gum confirm "Trigger deploy?"; or return 1

  if test "$NAMESPACE" = "hatch-elixir"
    gh workflow run $WORKSPACE_ID_CD -f ENVIRONMENT=$selected_env -f REF=$branch -f HELM_REF="main"
  else if test "$NAMESPACE" = "livekit-agent"
    gh workflow run $WORKSPACE_ID_CD -f ENVIRONMENT=$selected_env -f REF=$branch
  else if test "$NAMESPACE" = "hatch-scheduler-assistant"
    gh workflow run $WORKSPACE_ID_CD -f environment=$selected_env -f REF=$branch
  else
    gum style --foreground 226 "󰀦 No deploy command configured for namespace: $NAMESPACE"
    return 1
  end
end

######### DB ##########
function _query_staging_pg --argument-names namespace
  set -l svc $namespace-postgresql-rw
  set -l secret $namespace-postgresql-role-hatch-elixir

  tailscale up
  tailscale configure kubeconfig staging-eks
  kubectl port-forward -n $namespace svc/$svc 15432:5432 &
  set -l pf_pid $last_pid
  sleep 2
  env PGPASSWORD=(kubectl get secret $secret -n $namespace -o jsonpath='{.data.password}' | base64 -d) \
    PGSSLMODE=disable \
    pgcli -h 127.0.0.1 -p 15432 -U hatch-elixir
  kill $pf_pid 2>/dev/null
end

function query --description 'Open a database in pgcli'
  set -l target $argv[1]
  if test -z "$target"
    set target (gum choose --header "󰆼 Which database?" prod staging assistant assistant-2)
  end
  if test -z "$target"
    return 1
  end

  switch $target
    case prod
      gum confirm "Connect to PRODUCTION database?"; or return 1
      gum style --foreground 196 "󰆼 Connecting to prod"
      tailscale up
      tailscale configure kubeconfig prod-eks
      pgcli $PROD_DB
    case staging
      _query_staging_pg staging
    case assistant
      _query_staging_pg assistant
    case assistant-2
      _query_staging_pg assistant-2
    case '*'
      gum style --foreground 196 "󰀦 Unknown target: $target"
      return 1
  end
end

