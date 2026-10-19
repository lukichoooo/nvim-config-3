#!/usr/bin/env bash
# setup.sh - Bootstrap a fresh Ubuntu machine for this Neovim config.
#
# Run as your normal user (the script uses sudo internally):
#   ./setup.sh
#   ./setup.sh --with-ghostty --with-dotnet
#   ./setup.sh --help
#
# The script is idempotent: existing files are backed up, and every phase
# checks whether its work has already been done.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
readonly ASSET_DIR="$SCRIPT_DIR/install"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
readonly TIMESTAMP
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim-setup"
readonly LOG_FILE="$STATE_DIR/setup-$TIMESTAMP.log"
readonly BACKUP_DIR="$HOME/.config/nvim-setup-backups/$TIMESTAMP"

DRY_RUN=false
ASSUME_YES=false
SKIP_SYSTEM=false
NO_BOOTSTRAP=false
WITH_GHOSTTY=false
WITH_BATTERY=false
WITH_OPENCODE=true
WITH_DOTNET=false
DOTNET_SOURCE="script"
WITH_FLATPAK=true
declare -a FLATPAK_APPS=()
LOCK_BACKUP=""

# Make user-local binaries and snap binaries available for this session.
export PATH="$HOME/.local/bin:/snap/bin:$PATH"

if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_RED=$'\033[31m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
else
  C_RESET=""
  C_BOLD=""
  C_RED=""
  C_YELLOW=""
  C_BLUE=""
fi

usage() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Installs the Neovim toolchain, snaps, Flatpak/Flathub, this config, and the
system limits documented in README.md.

Options:
  -y, --yes                 Do not ask for confirmation
      --dry-run             Print every action, change no system/config files
      --skip-system         Skip limits.d/systemd/sysctl tuning
      --no-bootstrap        Skip Lazy/Mason/Treesitter installation
      --with-ghostty        Install Ghostty from snap and write its config
      --with-battery        Install the ThinkPad BAT0 battery service
      --no-opencode         Do not install OpenCode from snap
      --with-dotnet         Install .NET and EasyDotnet
      --dotnet-source=SRC   .NET source: script (default) or snap
      --no-flatpak          Do not install Flatpak/Flathub
      --flatpak-app ID      Install a Flatpak app (repeatable)
  -h, --help                Show this help

Examples:
  ./setup.sh
  ./setup.sh --with-ghostty --with-dotnet
  ./setup.sh --flatpak-app com.visualstudio.code --flatpak-app dev.zed.Zed
  ./setup.sh --dry-run
EOF
}

log() {
  local msg="$*"
  printf '%s%s%s\n' "$C_BLUE" "$msg" "$C_RESET"
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$msg" >>"$LOG_FILE" 2>/dev/null || true
}

warn() {
  local msg="$*"
  printf '%sWARN:%s %s\n' "$C_YELLOW" "$C_RESET" "$msg" >&2
  printf '[%s] WARN: %s\n' "$(date +%H:%M:%S)" "$msg" >>"$LOG_FILE" 2>/dev/null || true
}

die() {
  local msg="$*"
  printf '%sERROR:%s %s\n' "$C_RED" "$C_RESET" "$msg" >&2
  printf '[%s] ERROR: %s\n' "$(date +%H:%M:%S)" "$msg" >>"$LOG_FILE" 2>/dev/null || true
  exit 1
}

on_error() {
  local line="$1"
  restore_lockfile || true
  die "Setup failed at line $line. See $LOG_FILE"
}
trap 'on_error $LINENO' ERR

have() {
  command -v "$1" >/dev/null 2>&1
}

run() {
  if $DRY_RUN; then
    log "[dry-run] $*"
    return 0
  fi
  log "+ $*"
  "$@"
}

run_sudo() {
  if $DRY_RUN; then
    log "[dry-run] sudo $*"
    return 0
  fi
  log "+ sudo $*"
  sudo "$@"
}

backup_path() {
  local src="$1"
  [[ -e "$src" || -L "$src" ]] || return 0

  if $DRY_RUN; then
    log "[dry-run] backup $src"
    return 0
  fi

  local rel="${src#"$HOME"/}"
  local dest="$BACKUP_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  cp -a "$src" "$dest"
  log "Backed up $src -> $dest"
}

install_asset() {
  local src="$1"
  local dest="$2"

  [[ -f "$src" ]] || die "Missing install asset: $src"

  if $DRY_RUN; then
    log "[dry-run] install $src -> $dest"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  backup_path "$dest"
  install -m 0644 "$src" "$dest"
  log "Installed $dest"
}

restore_lockfile() {
  [[ -n "${LOCK_BACKUP:-}" && -f "$LOCK_BACKUP" ]] || return 0

  if [[ -f "$SCRIPT_DIR/lazy-lock.json" ]] &&
    cmp -s "$LOCK_BACKUP" "$SCRIPT_DIR/lazy-lock.json"; then
    rm -f "$LOCK_BACKUP"
  else
    cp "$LOCK_BACKUP" "$SCRIPT_DIR/lazy-lock.json"
    log "Restored lazy-lock.json after bootstrap"
    rm -f "$LOCK_BACKUP"
  fi
  LOCK_BACKUP=""
}

parse_args() {
  while (($#)); do
    case "$1" in
      -y | --yes) ASSUME_YES=true ;;
      --dry-run) DRY_RUN=true ;;
      --skip-system) SKIP_SYSTEM=true ;;
      --no-bootstrap) NO_BOOTSTRAP=true ;;
      --with-ghostty) WITH_GHOSTTY=true ;;
      --with-battery) WITH_BATTERY=true ;;
      --no-opencode) WITH_OPENCODE=false ;;
      --with-dotnet) WITH_DOTNET=true ;;
      --dotnet-source=*)
        DOTNET_SOURCE="${1#*=}"
        WITH_DOTNET=true
        ;;
      --dotnet-source)
        shift
        [[ $# -gt 0 ]] || die "--dotnet-source requires an argument"
        DOTNET_SOURCE="$1"
        WITH_DOTNET=true
        ;;
      --no-flatpak) WITH_FLATPAK=false ;;
      --flatpak-app=*) FLATPAK_APPS+=("${1#*=}") ;;
      --flatpak-app)
        shift
        [[ $# -gt 0 ]] || die "--flatpak-app requires an application ID"
        FLATPAK_APPS+=("$1")
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1 (try --help)"
        ;;
    esac
    shift
  done

  case "$DOTNET_SOURCE" in
    script | snap) ;;
    *) die "--dotnet-source must be 'script' or 'snap' (got '$DOTNET_SOURCE')" ;;
  esac

  if ! $WITH_FLATPAK && ((${#FLATPAK_APPS[@]})); then
    die "--flatpak-app cannot be used with --no-flatpak"
  fi
}

confirm() {
  if $ASSUME_YES || $DRY_RUN; then
    return 0
  fi
  if [[ ! -t 0 ]]; then
    die "Non-interactive shell; pass --yes to continue"
  fi

  local opencode_state flatpak_state ghostty_state dotnet_state
  local battery_state system_state bootstrap_state
  if $WITH_OPENCODE; then
    opencode_state="snap 2/stable (v2)"
  else
    opencode_state="skipped"
  fi
  if $WITH_FLATPAK; then
    flatpak_state="yes (+ Flathub)"
  else
    flatpak_state="skipped"
  fi
  if $WITH_GHOSTTY; then
    ghostty_state="snap"
  else
    ghostty_state="skipped"
  fi
  if $WITH_DOTNET; then
    dotnet_state="$DOTNET_SOURCE"
  else
    dotnet_state="skipped"
  fi
  if $WITH_BATTERY; then
    battery_state="yes"
  else
    battery_state="skipped"
  fi
  if $SKIP_SYSTEM; then
    system_state="skipped"
  else
    system_state="yes"
  fi
  if $NO_BOOTSTRAP; then
    bootstrap_state="skipped"
  else
    bootstrap_state="yes"
  fi

  cat <<EOF

Install plan
------------
  Base packages:   apt (toolchain, Java, Python, Node, ripgrep, ...)
  Neovim:          snap (nvim --classic)
  OpenCode:        $opencode_state
  Flatpak:         $flatpak_state
  Flatpak apps:    ${#FLATPAK_APPS[@]}
  Ghostty:         $ghostty_state
  .NET:            $dotnet_state
  Battery service: $battery_state
  System tuning:   $system_state
  Neovim bootstrap:$bootstrap_state

  Log:     $LOG_FILE
  Backups: $BACKUP_DIR

EOF

  local reply
  read -r -p "Continue? [y/N] " reply </dev/tty || die "Aborted"
  [[ "$reply" =~ ^[Yy]$ ]] || die "Aborted"
}

preflight() {
  [[ ${EUID} -ne 0 ]] || die "Run this as your normal user, not as root"
  [[ -n ${HOME:-} && ${HOME} != / ]] || die "HOME is not set correctly"
  [[ -r /etc/os-release ]] || die "Cannot read /etc/os-release"

  # shellcheck source=/dev/null
  . /etc/os-release
  [[ ${ID:-} == ubuntu ]] || die "This script targets Ubuntu (found '${ID:-unknown}')"

  mkdir -p "$STATE_DIR"
  : >"$LOG_FILE"
  log "Log file: $LOG_FILE"

  if ! $DRY_RUN; then
    getent hosts github.com >/dev/null 2>&1 ||
      die "No DNS/network access (cannot resolve github.com)"
    have sudo || die "sudo is required"
    sudo -v || die "sudo authentication failed"
  fi
}

install_base_packages() {
  local packages=(
    git
    curl
    wget
    ca-certificates
    gnupg
    lsb-release
    software-properties-common
    apt-transport-https
    build-essential
    make
    pkg-config
    unzip
    zip
    tar
    gzip
    file
    diffutils
    ripgrep
    fd-find
    xclip
    xsel
    clang
    clangd
    clang-format
    python3
    python3-pip
    python3-venv
    python3-full
    default-jre
    luarocks
    snapd
  )

  if $WITH_FLATPAK; then
    packages+=(flatpak)
  fi

  log "Installing base apt packages"
  run_sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
    apt-get update
  run_sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
    apt-get install -y "${packages[@]}"
}

link_fd() {
  if have fdfind && ! have fd; then
    log "Linking fdfind -> ~/.local/bin/fd"
    if $DRY_RUN; then
      log "[dry-run] ln -sf $(command -v fdfind) $HOME/.local/bin/fd"
    else
      mkdir -p "$HOME/.local/bin"
      ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
  fi
}

install_node() {
  local major=0
  if have node; then
    major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  fi

  if ((major >= 20)); then
    log "Node $(node --version) is already installed"
    if ! have npm; then
      if $DRY_RUN; then
        log "[dry-run] install npm"
      else
        log "npm is missing; installing it"
        run_sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
          apt-get install -y npm || warn "Could not install npm"
        have npm || die "npm is required (install nodejs/npm)"
      fi
    fi
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] install Node $(node --version 2>/dev/null || echo '(missing)') via NodeSource 24.x"
    return 0
  fi

  log "Installing Node 24.x from NodeSource"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL https://deb.nodesource.com/setup_24.x -o "$tmp/setup.sh"
  run_sudo bash "$tmp/setup.sh"
  run_sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
    apt-get install -y nodejs
  rm -rf "$tmp"

  major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  ((major >= 20)) || die "Node installation failed (found major version $major)"
  log "Installed Node $(node --version)"
}

install_tree_sitter_cli() {
  export PATH="$HOME/.local/bin:$PATH"

  if $NO_BOOTSTRAP; then
    log "Skipping the tree-sitter CLI (--no-bootstrap)"
    return 0
  fi

  if have tree-sitter; then
    log "tree-sitter CLI: $(tree-sitter --version)"
    return 0
  fi

  log "Installing the tree-sitter CLI (required by nvim-treesitter)"
  run npm install -g --prefix "$HOME/.local" tree-sitter-cli
  if $DRY_RUN; then
    return 0
  fi
  have tree-sitter || die "tree-sitter CLI installation failed"
  log "tree-sitter CLI: $(tree-sitter --version)"
}

ensure_snapd() {
  if ! have snap; then
    run_sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a \
      apt-get install -y snapd
  fi

  run_sudo systemctl enable --now snapd.socket || warn "Could not enable snapd.socket"

  if ! $DRY_RUN; then
    log "Waiting for snapd to finish seeding"
    if ! sudo timeout 180 snap wait system seed.loaded; then
      warn "snapd seeding did not finish within 180s; snap installs may fail"
    fi
  fi
}

snap_is_installed() {
  have snap && snap list "$1" >/dev/null 2>&1
}

snap_install() {
  local pkg="$1"
  shift

  if snap_is_installed "$pkg"; then
    log "snap: $pkg is already installed"
    return 0
  fi

  run_sudo snap install "$pkg" "$@"
}

snap_ensure_channel() {
  local pkg="$1"
  local channel="$2"
  local tracking

  snap_is_installed "$pkg" || return 0

  tracking="$(snap list "$pkg" 2>/dev/null | awk 'NR==2 {print $4}')"
  if [[ -n "$tracking" && "$tracking" != "$channel" ]]; then
    log "snap: switching $pkg from $tracking to $channel"
    run_sudo snap refresh "$pkg" --channel="$channel"
  fi
}

install_snaps() {
  log "Installing snap applications"
  ensure_snapd

  export PATH="/snap/bin:$PATH"

  snap_install nvim --classic

  if $WITH_OPENCODE; then
    # OpenCode v2. The Neovim config reads either of the v2 service
    # registration files (service.json or service-prod.json).
    snap_install opencode --classic --channel=2/stable
    snap_ensure_channel opencode 2/stable
  fi

  if $WITH_GHOSTTY; then
    snap_install ghostty --classic
  fi

  if $WITH_DOTNET && [[ "$DOTNET_SOURCE" == snap ]]; then
    snap_install dotnet-sdk-100
  fi
}

verify_nvim() {
  $DRY_RUN && return 0

  have nvim || die "nvim was not found after the snap install"
  export PATH="/snap/bin:$PATH"

  local first
  first="$(nvim --version | head -n1)"
  if [[ ! "$first" =~ ^NVIM\ v([0-9]+)\.([0-9]+) ]]; then
    warn "Could not parse Neovim version: $first"
    return 0
  fi

  local major="${BASH_REMATCH[1]}"
  local minor="${BASH_REMATCH[2]}"
  if ((major == 0 && minor < 11)); then
    die "Neovim 0.11+ is required, but $first is installed"
  fi

  log "Neovim: $first"
}

setup_flatpak() {
  if ! $WITH_FLATPAK; then
    log "Skipping Flatpak (--no-flatpak)"
    return 0
  fi

  log "Configuring Flatpak/Flathub"

  run flatpak remote-add --if-not-exists --user flathub \
    https://flathub.org/repo/flathub.flatpakrepo

  if ((${#FLATPAK_APPS[@]} == 0)); then
    return 0
  fi

  run flatpak update -y --user --appstream || warn "Flathub appstream update failed"

  local app
  for app in "${FLATPAK_APPS[@]}"; do
    [[ -n "$app" ]] || continue

    if ! $DRY_RUN &&
      flatpak list --app --columns=application 2>/dev/null | grep -qx "$app"; then
      log "flatpak: $app is already installed"
      continue
    fi

    run flatpak install -y --user flathub "$app" ||
      warn "Failed to install Flatpak app: $app"
  done
}

place_configs() {
  log "Placing configuration files"
  local target="$HOME/.config/nvim"

  if [[ "$SCRIPT_DIR" != "$target" ]]; then
    if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$SCRIPT_DIR")" ]]; then
      log "Neovim config is already linked to $SCRIPT_DIR"
    else
      if [[ -e "$target" || -L "$target" ]]; then
        if $DRY_RUN; then
          log "[dry-run] move $target -> $BACKUP_DIR/nvim"
        else
          mkdir -p "$BACKUP_DIR"
          mv "$target" "$BACKUP_DIR/nvim"
          log "Backed up $target -> $BACKUP_DIR/nvim"
        fi
      fi

      run mkdir -p "$(dirname "$target")"
      run ln -sfn "$SCRIPT_DIR" "$target"
    fi
  else
    log "Neovim config is already in place at $target"
  fi

  install_asset "$ASSET_DIR/clang-format" "$HOME/.clang-format"
  install_asset "$ASSET_DIR/clangd.yaml" "$HOME/.config/clangd/config.yaml"

  if $WITH_GHOSTTY; then
    install_asset "$ASSET_DIR/ghostty.conf" \
      "$HOME/.config/ghostty/config.ghostty"
  fi
}

setup_dotnet_script() {
  log "Installing .NET from the official install script"

  if $DRY_RUN; then
    log "[dry-run] install .NET LTS into $HOME/dotnet"
    log "[dry-run] dotnet tool install --global EasyDotnet"
    log "[dry-run] dotnet-easydotnet roslyn install"
    return 0
  fi

  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$tmp/dotnet-install.sh"
  run bash "$tmp/dotnet-install.sh" --channel LTS --install-dir "$HOME/dotnet"
  rm -rf "$tmp"

  export DOTNET_ROOT="$HOME/dotnet"
  export PATH="$PATH:$DOTNET_ROOT:$HOME/.dotnet/tools"

  "$DOTNET_ROOT/dotnet" --info >/dev/null 2>&1 ||
    warn "dotnet --info failed after installation"

  if ! "$DOTNET_ROOT/dotnet" tool update --global EasyDotnet >/dev/null 2>&1; then
    run "$DOTNET_ROOT/dotnet" tool install --global EasyDotnet ||
      warn "Could not install the EasyDotnet global tool"
  fi

  if [[ -x "$HOME/.dotnet/tools/dotnet-easydotnet" ]]; then
    run "$HOME/.dotnet/tools/dotnet-easydotnet" roslyn install ||
      warn "Could not install EasyDotnet Roslyn"
  else
    warn "dotnet-easydotnet was not found; run 'dotnet tool install --global EasyDotnet' manually"
  fi
}

setup_dotnet_snap() {
  log "Configuring the .NET snap"

  run_sudo ln -sfn /snap/dotnet-sdk-100/current/usr/bin/dotnet \
    /usr/local/bin/dotnet

  export DOTNET_ROOT=/snap/dotnet-sdk-100/current/usr/lib/dotnet
  export PATH="$PATH:$HOME/.dotnet/tools"

  if $DRY_RUN; then
    log "[dry-run] dotnet tool install --tool-path $HOME/.dotnet/tools EasyDotnet"
    log "[dry-run] dotnet-easydotnet roslyn install"
    return 0
  fi

  dotnet --info >/dev/null 2>&1 ||
    warn "dotnet --info failed after the snap install"

  if ! dotnet tool update --tool-path "$HOME/.dotnet/tools" EasyDotnet >/dev/null 2>&1; then
    run dotnet tool install --tool-path "$HOME/.dotnet/tools" EasyDotnet ||
      warn "Could not install EasyDotnet with the .NET snap"
  fi

  if [[ -x "$HOME/.dotnet/tools/dotnet-easydotnet" ]]; then
    run "$HOME/.dotnet/tools/dotnet-easydotnet" roslyn install ||
      warn "Could not install EasyDotnet Roslyn"
  else
    warn "dotnet-easydotnet was not found"
  fi
}

setup_dotnet() {
  if ! $WITH_DOTNET; then
    return 0
  fi

  if [[ "$DOTNET_SOURCE" == snap ]]; then
    setup_dotnet_snap
  else
    setup_dotnet_script
  fi
}

update_shell_rc() {
  log "Updating ~/.bashrc"
  local rc="$HOME/.bashrc"
  local tmp
  tmp="$(mktemp)"

  {
    printf '%s\n' '# >>> nvim-setup >>>'
    printf '%s\n' 'ulimit -n 8192 2>/dev/null'
    # The single-quoted strings are written literally into ~/.bashrc.
    # shellcheck disable=SC2016
    printf '%s\n' 'export PATH="$HOME/.local/bin:$PATH"'
    if $WITH_FLATPAK; then
      # shellcheck disable=SC2016
      printf '%s\n' 'export PATH="$HOME/.local/share/flatpak/exports/bin:$PATH"'
    fi
    if $WITH_DOTNET; then
      if [[ "$DOTNET_SOURCE" == snap ]]; then
        printf '%s\n' 'export DOTNET_ROOT=/snap/dotnet-sdk-100/current/usr/lib/dotnet'
        # shellcheck disable=SC2016
        printf '%s\n' 'export PATH="$PATH:$HOME/.dotnet/tools"'
      else
        # shellcheck disable=SC2016
        printf '%s\n' 'export DOTNET_ROOT="$HOME/dotnet"'
        # shellcheck disable=SC2016
        printf '%s\n' 'export PATH="$PATH:$DOTNET_ROOT:$HOME/.dotnet/tools"'
      fi
    fi
    printf '%s\n' '# <<< nvim-setup <<<'
  } >"$tmp"

  if $DRY_RUN; then
    log "[dry-run] update $rc with:"
    while IFS= read -r line; do
      log "    $line"
    done <"$tmp"
    rm -f "$tmp"
    return 0
  fi

  mkdir -p "$(dirname "$rc")"
  if [[ -e "$rc" ]]; then
    backup_path "$rc"
  fi
  touch "$rc"
  sed -i '/^# >>> nvim-setup >>>$/,/^# <<< nvim-setup <<<$/d' "$rc"
  # Drop trailing blank lines left by the previous block.
  sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$rc"
  printf '\n' >>"$rc"
  cat "$tmp" >>"$rc"
  rm -f "$tmp"
  log "Updated $rc"
}

setup_system_tuning() {
  if $SKIP_SYSTEM; then
    log "Skipping system tuning (--skip-system)"
    return 0
  fi

  log "Applying system limits"
  run_sudo install -D -m 0644 "$ASSET_DIR/99-nvim.conf" \
    /etc/security/limits.d/99-nvim.conf
  run_sudo install -D -m 0644 "$ASSET_DIR/10-nofile-systemd.conf" \
    /etc/systemd/user.conf.d/10-nofile.conf
  run_sudo install -D -m 0644 "$ASSET_DIR/99-nvim-sysctl.conf" \
    /etc/sysctl.d/99-nvim-sysctl.conf
  run_sudo sysctl --system

  if ! $DRY_RUN && systemctl --user show-environment >/dev/null 2>&1; then
    run systemctl --user daemon-reexec ||
      warn "systemctl --user daemon-reexec failed; log out and back in"
  fi

  if ! $DRY_RUN; then
    ulimit -n 8192 2>/dev/null ||
      warn "Could not raise the file limit in this shell; log out and back in"
  fi
}

bootstrap_nvim() {
  if $NO_BOOTSTRAP; then
    log "Skipping Neovim bootstrap (--no-bootstrap)"
    return 0
  fi

  if $DRY_RUN; then
    log "[dry-run] nvim --headless --cmd 'let g:codeium_enabled=0' '+Lazy! restore' +qa"
    log "[dry-run] nvim --headless --cmd 'let g:codeium_enabled=0' '+MasonToolsInstallSync' +qa"
    log "[dry-run] install Treesitter parsers"
    return 0
  fi

  have nvim || die "nvim is not available for bootstrap"

  if [[ -f "$SCRIPT_DIR/lazy-lock.json" ]]; then
    LOCK_BACKUP="$(mktemp)"
    cp "$SCRIPT_DIR/lazy-lock.json" "$LOCK_BACKUP"
  fi

  # windsurf.vim starts a language server on BufEnter. Disable it for headless
  # runs, otherwise Neovim does not exit cleanly.
  log "Installing Neovim plugins (Lazy restore)"
  nvim --headless --cmd 'let g:codeium_enabled=0' "+Lazy! restore" +qa

  log "Installing Mason tools"
  nvim --headless --cmd 'let g:codeium_enabled=0' "+MasonToolsInstallSync" +qa ||
    warn "Mason reported errors; open ':Mason' to inspect"

  log "Installing Treesitter parsers"
  local ts_script
  ts_script="$(mktemp)"
  cat >"$ts_script" <<'LUA'
local wanted = {
  "c",
  "cpp",
  "c_sharp",
  "lua",
  "vim",
  "vimdoc",
  "bash",
  "python",
  "javascript",
  "typescript",
  "json",
  "yaml",
  "markdown",
  "markdown_inline",
}

local ok, ts = pcall(require, "nvim-treesitter")
if not ok then
  vim.notify("nvim-treesitter is not available", vim.log.levels.WARN)
  return
end

local installed = {}
for _, parser in ipairs(ts.get_installed("parsers") or {}) do
  installed[parser] = true
end

local missing = {}
for _, parser in ipairs(wanted) do
  if not installed[parser] then
    missing[#missing + 1] = parser
  end
end

if #missing == 0 then
  return
end

ts.install(missing)

local finished = vim.wait(600000, function()
  local now = {}
  for _, parser in ipairs(ts.get_installed("parsers") or {}) do
    now[parser] = true
  end
  for _, parser in ipairs(missing) do
    if not now[parser] then
      return false
    end
  end
  return true
end, 1000)

if not finished then
  vim.notify("Treesitter parser installation timed out", vim.log.levels.WARN)
end
LUA

  nvim --headless --cmd 'let g:codeium_enabled=0' "+luafile $ts_script" +qa ||
    warn "Treesitter parser installation reported errors"
  rm -f "$ts_script"

  restore_lockfile
}

setup_battery() {
  if ! $WITH_BATTERY; then
    return 0
  fi

  if [[ ! -d /sys/class/power_supply/BAT0 ]]; then
    warn "BAT0 not found; skipping the battery conservation service"
    return 0
  fi

  if [[ ! -e /sys/class/power_supply/BAT0/charge_control_start_threshold ||
    ! -e /sys/class/power_supply/BAT0/charge_control_end_threshold ]]; then
    warn "BAT0 does not expose charge thresholds; skipping the battery service"
    return 0
  fi

  log "Installing the battery conservation service"
  run_sudo install -D -m 0644 "$ASSET_DIR/battery-conservation.service" \
    /etc/systemd/system/battery-conservation.service
  run_sudo systemctl daemon-reload
  run_sudo systemctl enable --now battery-conservation.service ||
    warn "Could not enable the battery service"

  if ! $DRY_RUN; then
    local field
    for field in charge_control_start_threshold charge_control_end_threshold; do
      if [[ -r "/sys/class/power_supply/BAT0/$field" ]]; then
        log "BAT0 $field=$(cat "/sys/class/power_supply/BAT0/$field")"
      fi
    done
  fi
}

validate_install() {
  if $DRY_RUN; then
    log "[dry-run] validation skipped"
    return 0
  fi

  log "Validating installation"

  nvim --version | head -n1 || warn "nvim is not available"

  if $WITH_OPENCODE; then
    opencode --version || warn "opencode is not available"
    timeout 30 opencode service start >/dev/null 2>&1 ||
      warn "Could not start the OpenCode service; run 'opencode' once manually"
    timeout 30 opencode service status || warn "OpenCode service is not healthy"
    if [[ -f "$HOME/.local/state/opencode/service.json" ||
      -f "$HOME/.local/state/opencode/service-prod.json" ]]; then
      log "OpenCode v2 service registration found"
    else
      warn "OpenCode v2 service file not found yet; run 'opencode' once"
    fi
  fi

  if $WITH_FLATPAK; then
    if flatpak remotes --user 2>/dev/null | grep -q flathub; then
      log "Flathub remote is configured"
    else
      warn "Flathub remote is missing"
    fi
  fi

  if grep -rq "service-prod.json" "$SCRIPT_DIR/lua" 2>/dev/null; then
    log "OpenCode discovery supports the service-prod.json service file"
  fi

  if ! $NO_BOOTSTRAP; then
    local tool
    for tool in clangd stylua black isort prettier prettierd; do
      if [[ -x "$HOME/.local/share/nvim/mason/bin/$tool" ]]; then
        log "Mason tool present: $tool"
      else
        warn "Mason tool missing: $tool (open ':Mason' to inspect)"
      fi
    done

    if have tree-sitter; then
      log "tree-sitter CLI: $(tree-sitter --version)"
    else
      warn "tree-sitter CLI is missing; run ':TSInstall' after installing it"
    fi
  fi
}

summary() {
  if $DRY_RUN; then
    cat <<EOF

${C_BOLD}Dry run complete${C_RESET}

  No system or configuration files were changed.
  Log: $LOG_FILE

  Review the output above, then run ./setup.sh without --dry-run.
EOF
    return 0
  fi

  cat <<EOF

${C_BOLD}Setup complete${C_RESET}

  Log:     $LOG_FILE
  Backups: $BACKUP_DIR

Next steps:
EOF

  if ! $SKIP_SYSTEM; then
    echo "  - Log out and back in (or reboot) so the raised file limits take effect."
  fi
  echo "  - Run 'nvim' and check ':checkhealth'."
  if $WITH_OPENCODE; then
    echo "  - OpenCode v2: run 'opencode' once in a project, then verify with"
    echo "    'opencode service status'. opencode.nvim reads the generated"
    echo "    service.json or service-prod.json file automatically."
  fi
  if $WITH_FLATPAK; then
    echo "  - Flatpak apps: flatpak install --user flathub <app-id>"
  fi

  if $WITH_GHOSTTY; then
    cat <<'EOF'
  - Ghostty: set the GNOME shortcut Ctrl+Alt+T to the 'ghostty' command,
    and clear the default terminal shortcut first.
EOF
  fi

  if $WITH_DOTNET; then
    cat <<EOF
  - .NET source: $DOTNET_SOURCE. Verify with 'dotnet --info'.
EOF
  fi
}

main() {
  parse_args "$@"
  preflight
  confirm

  install_base_packages
  link_fd
  install_node
  install_tree_sitter_cli
  install_snaps
  verify_nvim
  setup_flatpak
  place_configs
  setup_dotnet
  update_shell_rc
  setup_system_tuning
  bootstrap_nvim
  setup_battery
  validate_install

  summary
}

main "$@"
