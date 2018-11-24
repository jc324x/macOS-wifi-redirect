# Net-Set

Creates a LaunchDaemon and a companion script that will redirect Apple laptops and desktops to your organization's wireless network.

## Summary

If your macOS devices are connecting to a company guest network or to an unwanted open network broadcasting in range of your organization's WiFi, this script will create a LaunchDaemon and script that will redirect them to safety. The companion script is triggered by changes to `/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist` and will only modify a client's network configuration if the target network is in range and accessible.

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
