# Net-Set

Creates a LaunchDaemon and a companion script that will redirect Apple laptops and
desktops to your organization's wireless network.

## Summary

If your macOS devices are connecting to a company guest network or to an unwanted open
network broadcasting in range of your organization's WiFi, this script will create a
LaunchDaemon and script that will redirect them to safety.

## Getting Started

Set the script values, test thoroughly and then send out with your management tool of
choice.

```bash
# the name of your organization
your_org="YOURORG" 

# the domain type of your organization (ex. com, org, net)
com_org="org" 

# name of the project with the name of your organization
name="$com_org.$your_org.net-set" 

# the path to wherever your org keeps scripts
script_dir="/usr/local/$your_org/scripts" 

# the path to the script within your org's script directory
script="$script_dir/net-set.sh" 

# the path to daemon set by this script
launchd="/Library/LaunchDaemons/$name.plist" 
```

### Prerequisites

None.
