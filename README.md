
#### My Configurations For ubuntu

## Fresh Ubuntu Setup

Clone the repo to the standard Neovim config path and run the installer:

```bash
git clone git@github.com:lukichoooo/nvim-config-3.git ~/.config/nvim
# No SSH key yet? Use HTTPS instead:
# git clone https://github.com/lukichoooo/nvim-config-3.git ~/.config/nvim
cd ~/.config/nvim
./setup.sh
```

Common options:

```bash
./setup.sh --with-ghostty --with-dotnet   # add Ghostty and .NET/EasyDotnet
./setup.sh --with-battery                 # ThinkPad BAT0 charge thresholds
./setup.sh --flatpak-app dev.zed.Zed      # install an optional GUI app
./setup.sh --dry-run                      # print every action, change no system/config files
./setup.sh --help
```

`setup.sh` installs Neovim, OpenCode v2, Flatpak/Flathub, the CLI toolchain,
this config, and the system limits from this README. It also installs the
`tree-sitter` CLI (required by the current `nvim-treesitter` branch) and
compiles the common parsers. Use `--no-flatpak`, `--no-opencode`,
`--no-bootstrap`, or `--skip-system` to opt out.

# Neovim Config

This configuration uses a custom clang-format style.


## Config

<details>
<summary>clang-format Style</summary>

### install Ghostty from snap

1.Disable GNOME Terminal shortcut:Go to Settings > Keyboard > Keyboard Shortcuts > View and Customize Shortcuts > Launchers. Click on Launch terminal and press Backspace to clear Ctrl+Alt+T, then click Set.

2.Add Ghostty shortcut:Scroll to the bottom of the shortcuts menu and click Custom Shortcuts. Click + (Add Shortcut) and fill in:Name: GhosttyCommand: ghosttyShortcut: Press Ctrl+Alt+T

```
nvim .config/ghostty/config.ghostty
```

```
theme = TokyoNight
mouse-hide-while-typing = true
```

</details>

<details>
<summary>clang-format Style</summary>

### location: ````nvim ~/.clang-format````

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
TabWidth: 4
UseTab: Never

SortIncludes: false

KeepEmptyLinesAtTheStartOfBlocks: true
AllowShortBlocksOnASingleLine: false
ColumnLimit: 0

ContinuationIndentWidth: 4
MaxEmptyLinesToKeep: 2
AlignAfterOpenBracket: DontAlign

BreakBeforeBinaryOperators: All

BreakBeforeBraces: Custom
BraceWrapping:
  AfterClass: true
  AfterStruct: true
  AfterEnum: true
  AfterFunction: true
  AfterNamespace: true
  AfterControlStatement: true
  BeforeElse: true
  BeforeCatch: true
```
Then save and quit (`:wq`).


### clang-format Style
### location: ````nvim ~/.config/clangd/config.yaml ````
```
CompileFlags:
  Add: [-std=c++23]
```
</details>

<details>
<summary> keys </summary>

### Swap Caps Lock - Esc globally
##### jsut use "GNOME TWEAKS"

</details>

<details>
<summary> tools for search </summary>

### Fuzzy Search (Live Grep)
Requires ripgrep

```yaml
# Install ripgrep
sudo apt install ripgrep
```

### Clipboard set same as system clipboard
Requires xclip
```yaml
# Install xclip
sudo apt install xclip
```

</details>


<details>
<summary> Opencode </summary>

Install OpenCode v2 from the snap store:

```bash
sudo snap install opencode --classic --channel=2/stable
opencode --version
opencode service start
opencode service status
```

OpenCode v2 registers its background service under
`~/.local/state/opencode/service-prod.json` (some versions use
`service.json`). The Neovim config reads either file and uses the generated
password, so run `opencode` once inside a project before using the keymaps.

</details>

<details>
<summary> SonarQube </summary>

sudo apt install default-jre

and check it via
```yaml
:SonarQubeShowConfig
``````
</details>

<details>
<summary> dotnet </summary>

```bash
export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$DOTNET_ROOT:$HOME/.dotnet/tools
```

`setup.sh --with-dotnet` installs the LTS SDK and EasyDotnet, and writes this
environment block to `~/.bashrc`.

</details>

<details>
<summary> dotnet tools </summary>

```yaml
dotnet tool install --global EasyDotnet
export PATH="$PATH:$HOME/.dotnet/tools"
dotnet-easydotnet roslyn install
``````
and add it to path

</details>


<details>
<summary> install luarocks </summary>

```bash
sudo apt install luarocks
```

</details>

<details>
<summary> fix ulimits </summary>

Fixes the `:checkhealth` warning:
`ulimit -n: 1024, recommended >= 4096 for neovim file watching`.

### 1. Raise the limit for login shells

* **Quit without saving:** Type `:q!` and press **Enter**.
* **Open file:** Run `sudo nvim /etc/security/limits.d/99-nvim.conf`
* **Paste lines:**
  ```text
  * soft nofile 8192
  * hard nofile 8192
    ```
* **Save & exit:** Type :wq and press Enter.

### 2. Why that alone was not enough (Ghostty + systemd)

This is why `:checkhealth` still warned `ulimit -n: 1024` even after step 1.

Ghostty runs every terminal surface inside a **transient systemd user scope**
(`app-ghostty-surface-transient-*.scope`). Units spawned by the systemd *user*
manager do **not** use `/etc/security/limits.d/*.conf` (that only applies via
PAM at login); they use the manager's `DefaultLimitNOFILE`, whose **soft** value
is `1024`. That `1024` is inherited by the shell and by Neovim, overriding
step 1. The **hard** limit is still `8192`, so a normal user can raise the soft
limit back up.

See it for yourself inside a Ghostty shell:
```bash
ulimit -Sn    # 1024  (soft limit Neovim complained about)
ulimit -Hn    # 8192  (hard limit — this is the ceiling we can reach)
```
The same reason also applies to a `systemd-run --user` unit:
```bash
systemd-run --user --wait bash -c 'grep "Max open files" /proc/self/limits'
# -> 1024  8192
```

### 3. The fix

Two ways — use either or both.

**a) Per-shell (no root)** — add to `~/.bashrc`:
```bash
ulimit -n 8192 2>/dev/null
```
Covers anything launched from a shell. (Ghostty starts the shell as
`bash --posix`, but its shell integration sources `~/.bashrc`, so this applies.)

**b) System-wide (needs sudo)** — raise the systemd **user** manager default so
every scope (including Ghostty surfaces) inherits it directly:
```bash
sudo mkdir -p /etc/systemd/user.conf.d
printf '[Manager]\nDefaultLimitNOFILE=8192\n' | sudo tee /etc/systemd/user.conf.d/10-nofile.conf
systemctl --user daemon-reexec   # or just log out and back in
```

</details>

<details>
<summary>might Need</summary>

### Increase File watchers Size in Linux

```yaml
# Check current limits
cat /proc/sys/fs/inotify/max_user_instances

# Open /etc/sysctl.conf in Neovim (or any editor) with sudo:
sudo nvim /etc/sysctl.conf

# Add this line at the end of the file:
fs.inotify.max_user_watches=524288

# Save and exit (:wq in Neovim).
# Reload sysctl settings to apply immediately:
sudo sysctl -p

# After this, the setting will persist across reboots.
```

On Linux, there are two limits you need to check:

fs.inotify.max_user_instances – max number of inotify instances per user (default 128).

fs.inotify.max_user_watches – max number of files watched per user (you already increased this).

You need to increase the instances as well:

### Make permanent (edit in nvim or any editor)
```yaml
sudo nvim /etc/sysctl.conf
# Add this line
fs.inotify.max_user_instances=1024

# Reload sysctl
sudo sysctl -p
```

### Font & Icons
make sure to install nerdfont (non NL version)

# Laptop Battery-Life Safety

### Create systemd service 
```yaml
sudo nvim /etc/systemd/system/battery-conservation.service
```

### Paste this
```yaml
[Unit]
Description=Lenovo ThinkPad Battery Conservation Mode
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold && echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'
RemainAfterExit=true

[Install]
WantedBy=multi-user.target

# Runs at boot:
# "echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold"
# "echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold" 
```

### Enable service
```yaml
sudo systemctl daemon-reload
sudo systemctl enable battery-conservation.service
sudo systemctl start battery-conservation.service
```

### Verify Thresholds
```yaml
cat /sys/class/power_supply/BAT0/charge_control_start_threshold
cat /sys/class/power_supply/BAT0/charge_control_end_threshold
```

## remember!!! its better to keep your battery plugged in always
## because it uses the power from cable, and battery is off 

### Get Discord Presence ("andweeb/presence.nvim") Working
2. Snap Discord only — fix the IPC socket
```
ln -sf "$XDG_RUNTIME_DIR/snap.discord/discord-ipc-0" "$XDG_RUNTIME_DIR/discord-ipc-0"
```

3. Make it permanent across reboots
```
mkdir -p ~/.config/user-tmpfiles.d
echo 'L %t/discord-ipc-0 - - - - snap.discord/discord-ipc-0' > ~/.config/user-tmpfiles.d/discord-rpc.conf
systemctl --user enable --now systemd-tmpfiles-setup.service
```

</details>
