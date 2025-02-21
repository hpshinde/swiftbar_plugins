#!/usr/bin/env bash
# <xbar.title>Hosts Manager</xbar.title>
# <xbar.version>1.0</xbar.version>
# <xbar.author>Harshal Shinde</xbar.author>
# <xbar.desc>Manage and switch hosts files on macOS</xbar.desc>
# <xbar.image>PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSIjRDlEOUQ5Ij48cGF0aCBkPSJNNDU2LjE4LTE5MlE0NDYtMTkyIDQzOS0xOTguOXQtNy0xNy4xdi0yMjdMMTk3LTcyOXEtOS0xMi0yLjc0LTI1LjVRMjAwLjUxLTc2OCAyMTYtNzY4aDUyOHExNS40OSAwIDIxLjc0IDEzLjVRNzcyLTc0MSA3NjMtNzI5TDUyOC00NDN2MjI3cTAgMTAuMi02Ljg4IDE3LjEtNi44OSA2LjktMTcuMDYgNi45aC00Ny44OFpNNDgwLTQ5OGwxNjItMTk4SDMxN2wxNjMgMTk4Wm0wIDBaIi8+PC9zdmc+</xbar.image>
# <xbar.dependencies>Bash, zsh</xbar.dependencies>

ICON="| templateImage=PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjBweCIgdmlld0JveD0iMCAtOTYwIDk2MCA5NjAiIHdpZHRoPSIyMHB4IiBmaWxsPSIjRDlEOUQ5Ij48cGF0aCBkPSJNNDU2LjE4LTE5MlE0NDYtMTkyIDQzOS0xOTguOXQtNy0xNy4xdi0yMjdMMTk3LTcyOXEtOS0xMi0yLjc0LTI1LjVRMjAwLjUxLTc2OCAyMTYtNzY4aDUyOHExNS40OSAwIDIxLjc0IDEzLjVRNzcyLTc0MSA3NjMtNzI5TDUyOC00NDN2MjI3cTAgMTAuMi02Ljg4IDE3LjEtNi44OSA2LjktMTcuMDYgNi45aC00Ny44OFpNNDgwLTQ5OGwxNjItMTk4SDMxN2wxNjMgMTk4Wm0wIDBaIi8+PC9zdmc+"

# Paths
MYHOSTS="$HOME/Library/Mobile Documents/com~apple~CloudDocs/dotfiles/myhosts.txt"
FGSP_SCRIPT="/Users/data/Library/Mobile Documents/com~apple~CloudDocs/dotfiles/update_hosts.zsh"
ETC_HOSTS="/etc/hosts"

echo "$ICON"
echo "---"
echo "Activate MyHosts | bash='$0' param1=myhosts terminal=false"
echo "Activate FGSP.hosts | bash='$0' param1=fgsp terminal=false"
echo "---"

# Function to replace hosts file
activate_myhosts() {
  if [[ -f "$MYHOSTS" ]]; then
    osascript -e "tell application \"Terminal\" to do script \"echo 'Switching hosts file...'; sudo cp '$MYHOSTS' '$ETC_HOSTS'; sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; echo 'Hosts file updated.'; osascript -e 'display notification \\\"myhosts.txt activated\\\" with title \\\"Hosts Manager\\\"'\""
  else
    osascript -e 'display notification "myhosts.txt not found" with title "Hosts Manager"'
  fi
}

# Function to execute FGSP script in Terminal with sudo
activate_fgsp() {
  if [[ -f "$FGSP_SCRIPT" ]]; then
    osascript -e "tell application \"Terminal\" to do script \"echo 'Running FGSP.hosts update...'; sudo zsh '$FGSP_SCRIPT'\""
    osascript -e 'display notification "FGSP.hosts script executed" with title "Hosts Manager"'
  else
    osascript -e 'display notification "update_hosts.zsh not found" with title "Hosts Manager"'
  fi
}

# Automatic daily execution via launchctl
setup_auto_execution() {
  PLIST="$HOME/Library/LaunchAgents/com.harshalswiftbar.hostsmanager.plist"

  cat <<EOF > "$PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.harshalswiftbar.hostsmanager</string>
    <key>ProgramArguments</key>
    <array>
      <string>/usr/bin/osascript</string>
      <string>-e</string>
      <string>tell application "Terminal" to do script \"echo 'Running FGSP.hosts update...'; sudo zsh '$FGSP_SCRIPT'\"</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
      <key>Hour</key>
      <integer>15</integer>
      <key>Minute</key>
      <integer>0</integer>
    </dict>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
EOF

  launchctl unload "$PLIST" 2>/dev/null
  launchctl load "$PLIST"
  osascript -e 'display notification "Scheduled FGSP update at 3PM (Terminal will open)" with title "Hosts Manager"'
}

# Argument handling
if [[ "$1" == "myhosts" ]]; then
  activate_myhosts
  exit 0
elif [[ "$1" == "fgsp" ]]; then
  activate_fgsp
  exit 0
elif [[ "$1" == "setup" ]]; then
  setup_auto_execution
  exit 0
fi

echo "Setup Auto-Run FGSP.hosts at 3PM | bash='$0' param1=setup terminal=false"
