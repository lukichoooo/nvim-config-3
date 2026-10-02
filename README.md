
#### My Configurations For ubuntu

# Neovim Config

This configuration uses a custom clang-format style.


## Config

### install Ghostty from snap

1.Disable GNOME Terminal shortcut:Go to Settings > Keyboard > Keyboard Shortcuts > View and Customize Shortcuts > Launchers. Click on Launch terminal and press Backspace to clear Ctrl+Alt+T, then click Set.2.Add Ghostty shortcut:Scroll to the bottom of the shortcuts menu and click Custom Shortcuts. Click + (Add Shortcut) and fill in:Name: GhosttyCommand: ghosttyShortcut: Press Ctrl+Alt+T

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

instell opencode via snap store
and open it via 
```yaml
opencode
``````
you can use it after you cd /path-to-project && opencode

</details>

<details>
<summary> dotnet </summary>

```
export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools   
```

</details>

<details>
<summary> dotnet tools </summary>

```yaml
dotnet tool install --global EasyDotnet
export PATH="$PATH:/home/luka/.dotnet/tools"
dotnet-easydotnet roslyn install
``````
and add it to path

</details>


<details>
<summary> install luarocks </summary>

```yaml
``````

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
