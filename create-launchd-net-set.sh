#!/bin/bash

# author: Jon Christensen, date: 2018-11-20, macOS: 10.14.1, GitHub / Jamf Nation: jychri 

# --- set value(s) here --- #

your_org="YOURORG" # the name of your organization
com_org="org" # the domain type of your organization (ex. com, org, net)
name="$com_org.$your_org.net-set" # name of the project with the name of your organization
script_dir="/usr/local/$your_org/scripts" # the path to wherever your org keeps scripts
script="$script_dir/net-set.sh" # the path to the script in your org's script directory
launchd="/Library/LaunchDaemons/$name.plist" # the path to the launch daemon

# --- do not edit below --- #

# create $script_dir if missing

if [ ! -d "$script_dir" ]; then
  mkdir -p "$script_dir"
fi

# verify permission and ownership for $script_dir

/bin/chmod 755 "$script_dir"
/usr/sbin/chown root:wheel "$script_dir"

/usr/bin/touch "$script"
/bin/chmod 755 "$script"

# important! set the cat direction to match "$script"
# the '\' in cat <<\EOF prevents variables from being interpreted
# until the closing EOF

# important! set the value for ssid to the name of the ssid 
# that you explicitly allowing

# important! set the value for blocked_ssids to the names 
# of the ssids that you are 

/bin/cat <<\EOF > /usr/local/YOURORG/scripts/net-set.sh
#!/bin/bash

# author: Jon Christensen, date: 2018-11-06, macOS: 10.14, GitHub / Jamf Nation: jychri 

# --- set values here --- #

ssid="YOURSSIDHERE"

blocked_ssids=(
  "YOURBLOCKEDSSID"
  "ANOTHERBLOCKEDSSID"
)

# --- function(s) --- #

# quit System Preferences if it's running
function verifySysPrefQuit() {
  if pgrep -f "System Preferences"; then
    echo "stopping System Preferences"; killall "System Preferences"
  fi
}

# turn the Wifi off and on
function toggleWifi() {
  networksetup -setairportpower "$wireless_device" off
  networksetup -setairportpower "$wireless_device" on
}

# remove every ssid in $blocked_ssids
function removeBlockedSSIDs() {
  arr="$1"
  for blocked_ssid in "${arr[@]}"; do
    /usr/sbin/networksetup -removepreferredwirelessnetwork "$wireless_device" "$blocked_ssid"
  done 
}

# --- do not edit below --- #

# --- if $current == $ssid, clean up and exit --- #

# get the wireless device
wireless_device=$(/usr/sbin/networksetup -listallhardwareports | /usr/bin/egrep -A2 'Airport|Wi-Fi' | /usr/bin/awk '/Device/ { print $2 }')

# get the ssid of the current network
current=$(networksetup -getairportnetwork "$wireless_device" | awk -F ": " '{print $2}')

# if already on "$ssid" verify that unwanted networks are removed, then exit
if [ "$current" == "$ssid" ]; then
  echo "connected to $ssid, verifying that blocked_ssids are removed; exiting"
  removeBlockedSSIDs "${blocked_ssids[@]}"; exit
fi

# --- verify that $ssid is known --- #

# build array of known ssids
known_ssids=($(networksetup -listpreferredwirelessnetworks "$wireless_device"))

# loop over ssids looking for a match
for known_ssid in "${known_ssids[@]}"
do
    if [ "$known_ssid" == "$ssid" ] ; then
        known=true; break
    fi
done

if [ "$known" != "true" ]; then
  echo "$ssid isn't a known network; exiting"; exit
fi

# --- verify that $ssid is available --- #

# /System/Library isn't in the $PATH
airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

# build array of available ssids
available_ssids=($("$airport" -s | awk '{print $1}'))

# loop over ssids looking for a match
for available_ssid in "${available_ssids[@]}"
do
    if [ "$available_ssid" == "$ssid" ] ; then
        available=true; break
    fi
done

# verified that $ssid is available
if [ "$available" != "true" ]; then
  echo "ssid isn't available; exiting"; exit
fi

# verify that System Preferences isn't running
verifySysPrefQuit

# remove blocked ssids
for blocked_ssid in "${blocked_ssids[@]}"; do
  /usr/sbin/networksetup -removepreferredwirelessnetwork "$wireless_device" "$blocked_ssid"
done 

# get the ssid of the current network
current=$(networksetup -getairportnetwork "$wireless_device" | awk -F ": " '{print $2}')

# if not on $ssid, toggle wifi on/off
if [ "$current" != "$ssid" ]; then
  toggleWifi
fi
EOF

# no '\' preceding \EOF here; variables will be interpreted

/bin/cat <<EOF > $launchd
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>EnvironmentVariables</key>
	<dict>
		<key>PATH</key>
		<string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
	</dict>
	<key>Label</key>
	<string>$name</string>
	<key>ProgramArguments</key>
	<array>
		<string>$script</string>
	</array>
  <key>KeepAlive</key>
		<true/>
	<key>RunAtLoad</key>
	<true/>
	<key>WatchPaths</key>
	<array>
		<string>/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist</string>
	</array>
</dict>
</plist>
EOF

# verify permissions and ownership for the daemon

/bin/chmod 644 $launchd
/usr/sbin/chown root:wheel $launchd

# unload the daemon if loaded
launchctl_check=$(/bin/launchctl list | grep $name)

if [ "$launchctl_check" != "" ]; then
  /bin/launchctl unload "$launchd"
fi

# load the daemon
/bin/launchctl load $launchd
