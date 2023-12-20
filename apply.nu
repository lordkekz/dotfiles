#!/bin/env nu

let x = $in
let y = if ($x | describe) == "string" {
    $x | from nuon
} else {
    $x
}

print ($y | table -e)

let username = $env.USER;
let hostname = hostname;

print "Hello there!"
print ("Detected user: " + $username)
print ("Detected hostname: " + $hostname)

let isWSL = ("WSL_DISTRO_NAME" in ($env | columns))
print (if $isWSL {
    "Detected WSL_DISTRO_NAME: " + $env.WSL_DISTRO_NAME
} else {
    "Detected no WSL Distro."
})

let isWAYLAND = ("WAYLAND_DISPLAY" in ($env | columns))
print (if $isWAYLAND {
    "Detected WAYLAND_DISPLAY: " + $env.WAYLAND_DISPLAY
} else {
    "Detected no WAYLAND."
})

let guiSelectionList = ["Yes, it's a desktop" "No, just a terminal"]
let guiSelectionList = if ($isWAYLAND and (not $isWSL)) { $guiSelectionList } else { $guiSelectionList | reverse }
let isGraphicalDesktop = ($guiSelectionList | input list -f "Is this a graphical desktop?") == "Yes, it's a desktop"

let guessedHomeConfigName = if $isGraphicalDesktop {
    $username + "@" + "Desk"
} else {
    $username + "@" + "Term"
}

let homeConfigList = (
    $y.homeConfigs |
    enumerate |
    upsert distance {|e| $e.item | str distance $guessedHomeConfigName } |
    sort-by distance |
    get item
)
let homeConfig = ($homeConfigList | input list -f "Select a user config:")

let hostConfig = if (which nixos-rebuild | is-empty) { null } else {
    let hostConfigList = (
        $y.hostConfigs |
        enumerate |
        upsert distance {|e| $e.item | str distance $hostname } |
        sort-by distance |
        get item
    )
    ($hostConfigList | input list -f "Select a host config:")
}

print "Please review the selection:"
print (if $isGraphicalDesktop == "Yes, it's a desktop" {
    "- This is a graphical desktop."
} else {
    "- This is just a terminal."
})

print (if $homeConfig == "" {
    "- No homeConfig will be applied."
} else {
    "- We will try to apply the homeConfig '" + $homeConfig + "'"
})

print (if $hostConfig == null {
    "- No hostConfig will be applied (because `nixos-rebuild` was not found)."
} else if $hostConfig == "" {
    "- No hostConfig will be applied."
} else {
    "- We will try to apply the hostConfig '" + $hostConfig + "'"
})

let isContinue = (["Make it so!" "Abort"] | input list -f "Continue?") == "Make it so!"

if $isContinue {
    if ($hostConfig != null and $hostConfig != "") {
        print "\nApplying hostConfig."
        try {
            let command = "nixos-rebuild switch -L -v --flake .#" + $hostConfig
            print ("Running: " + $command)
            $command | sh -
        }
    }

    if ($homeConfig != "") {
        print "\nApplying homeConfig."
        try {
            let command = "home-manager switch -L -v --flake .#" + $homeConfig
            print ("Running: " + $command)
            $command | sh -
        }
    }

    print "Done."
} else {
    print "Aborted."
}
