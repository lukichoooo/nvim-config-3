
#### My Configurations For ubuntu

# Neovim Config

This configuration uses a custom clang-format style.

### clang-format Style

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


### Swap Caps Lock - Esc globally
##### jsut use "GNOME TWEAKS"


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

### Font & Icons
make sure to install nerdfont (non NL version)


# OpenCode
instell opencode via npm
and open it via 
```yaml
opencode --port
``````


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

### Kitty (fastest terminal)
```yaml
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    installer=nightly

# Create symbolic links to add kitty and kitten to PATH (assuming ~/.local/bin is in
# your system-wide PATH)
# create alias for kitty
ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
# Place the kitty.desktop file somewhere it can be found by the OS
cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
# If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
# Update the paths to the kitty and its icon in the kitty desktop file(s)
sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
# Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
echo 'kitty.desktop' > ~/.config/xdg-terminals.list
gsettings set org.gnome.desktop.default-applications.terminal exec kitty
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ""
```

### Set Kitty as default everywhere
```yaml
sudo apt install nautilus-extension-gnome-terminal
gsettings set org.gnome.desktop.default-applications.terminal exec kitty
```

### Set Kitty Theme in ~/.config/kitty/kitty.conf
```yaml
# Font
font_family      FiraCode Nerd Font
font_size        10.5

# Cursor
cursor_shape     beam
cursor_blink_interval 0.5

# Window
background_opacity 0.92

# BEGIN_KITTY_THEME
# Dark Pride
include current-theme.conf
# END_KITTY_THEME
```


