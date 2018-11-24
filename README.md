# Net-Set

Creates a LaunchDaemon and a companion script that will redirect Apple laptops and
desktops to your organization's wireless network.

## Summary

If your macOS devices are connecting to a company guest network or to an unwanted open
network broadcasting in range of your organization's WiFi, this script will create a
LaunchDaemon and script that will redirect them to safety.

## Getting Started

Open `create-launchd-net-set.sh`, jump to line 10 and set values for `your_org`,
`dom_ext` and `script_dir`.

```bash
your_org="YOURORG" # the name of your organization
dom_ext="org" # domain extension for your organization (eg. com, org, net)
script_dir="/usr/local/$your_org/scripts" # the path to your org's scripts directory
```

Then jump to line 34, read the comments and set the values for the script that will
be written to `$script`. The `\` in `cat <<\EOF >` prevents variables from being
interpreted, so you'll need set the output for `cat`, the value `ssid` and the values
in `blocked_ssids`.

### Prerequisites

There are no prerequisites for this script. Just clone it, configure it, *test it*
and then send it out to your clients.
