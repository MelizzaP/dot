# Laptop Setup

## Install some basic programs and tools

- [firefox](https://www.mozilla.org/en-US/firefox/mac/)
- [1Password](https://1password.com/downloads/mac/)
- [Rectangle Pro](https://rectangleapp.com/pro)
- [Alacritty](https://alacritty.org/)
- [Dash](https://kapeli.com/dash)
- [Postgres App](https://postgresapp.com/)
- Homebrew `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- [Open Dyslexic Font](https://www.nerdfonts.com/font-downloads), then in Font Book application click file add font for this user
- add .localrc add, `eval "$(/opt/homebrew/bin/brew shellenv)"
- add open ai and anthropic api keys to `OPENAI_API_KEY` and `ANTHROPIC_API_KEY` to localrc
- brew install
    - git
    - gh
    - fish
    - neovim
    - asdf
    - ripgrep
    - fd
    - tmux
    - starship
    - chafa
- setup github ssh key
    - `ssh-keygen -t ed25519 -C "melissa.patterson.va@gmail.com"`
    - `pbcopy < .ssh/id_ed25519.pub`
- clone dotfiles `git clone git@github.com:MelizzaP/dot.git .dot`
- symlink dotfiles config directory `ln -s .dot/config .config`
- symlink snippets directory `ln -s .dot/vsnip .vsnip`
- symlink tmux conf to $HOME path `ln -s .dot/tmux.conf $HOME/.tmux.conf`
- install omf `curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish`
- install [vim plug](https://github.com/junegunn/vim-plug)
    `sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'`
-   install lexical ls
    -   `git clone git@github.com:lexical-lsp/lexical.git`
    -   `cd lexical`
    -   `mix deps.get`
    -   `mix package`
-   install ts_ls `npm install -g typescript-language-server typescript`
-   open neovim and run plug install
