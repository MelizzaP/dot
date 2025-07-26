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
  vpn staging prod
  psql $ASSISTANT_DB
end

function vpn_staging
  vpn staging prod
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
