# Net-Set

## Synopsis

Creates a LaunchDaemon and script that will automatically redirect macOS devices to
your organization's wireless network if that network is known and available.

## Summary

If your Apple laptops and desktops are connecting to a company guest network or to an unwanted open network broadcasting in range of your organization's WiFi, `net-set` will create a LaunchDaemon and script that will redirect them back to your network. The created script is triggered by changes to `/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist` and will only modify a client's network configuration if the target network is known and available.

## Workflow

1. Ch-ch-ch-changes

Turning on the AirPort or changing WiFi networks will modify `/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist` and trigger the script.

2. Are you home?

The script first checks to see if the client device is connected to the target
network. If the client is already connected, the script verifies that unwanted
networks are removed from the network service order and then quits.

```bash
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
```

```bash
# remove every ssid in $blocked_ssids

function removeBlockedSSIDs() {
  arr="$1"
  for blocked_ssid in "${arr[@]}"; do
    /usr/sbin/networksetup -removepreferredwirelessnetwork "$wireless_device" "$blocked_ssid"
  done 
}
```

3. Do I know you?

If the client isn't already connected to the target network, the script verifies that
the client has a know connection through `/usr/sbin/networksetup`. If the target
network is known, it will continue, otherwise it will exit. This is helpful as an
absolute last resort. If a endpoint has lost it's connection to your network, this at
least allows you the opportunity to recapture it through an external network.

```bash
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
```

4. Are you free?

The script then checks to see if the target network is in range utilizing the
`airport` utility, found at
`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport`. If the target network is range, the script will move forward.

```bash
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
```

5. Cleanup time

The target network is in range. System Preferences is verified to be closed, as it
can cause unintended behavior if it's running in the background while the next
actions are performed. Blocked SSIDs are removed, WiFi is toggled off and then on
again and the client rejoins your network.


```bash
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

```

## Getting Started

##### Jump to line 10.

Set 3 values:

* Set `your_org` to the name of your organization.
* Set `dom_ext` to your organization's domain extension.
* Set `script_dir` to the path of your organization's scripts directory.

```bash
your_org="YOURORG" # the name of your org
dom_ext="org" # domain extension for your org (eg. com, org, net)
script_dir="/usr/local/$your_org/scripts" # the path to your org's scripts directory
```

##### Jump to line 34. 

**Note:** The `\` in `cat <<\EOF >` prevents variables from being interpreted until the closing `EOF`, so 3 additional values need to be set:

* Set `cat` to the value of `$script` (ex. `/usr/local/YOURORG/scripts/net-set.sh`)

```bash
/bin/cat <<\EOF > /usr/local/YOURORG/scripts/net-set.sh
```

* Set `ssid` to your organization's wireless network

```bash
ssid="YOURSSIDHERE"
```

* Populate `blocked_ssids` with the names of wireless connections that should be
  automatically removed while in range of your company's wireless network

```bash
blocked_ssids=(
  "YOURORG-GUEST"
  "LOBBY-COFFEE-WIFI"
)
```
