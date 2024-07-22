# The name of the laptop's monitor, for example "eDP-1"
laptop_monitor_name=$1
laptop_monitor_enable_param=$2

# Get the JSON data
data=$(hyprctl monitors all -j)

# Use jq to extract the element with "name" set to "$laptop_monitor_name"
laptop_monitor_entry=$(echo "$data" | jq ".[] | select(.name == \"$laptop_monitor_name\")")

# Check the "disabled" value of the "$laptop_monitor_name" element
if echo "$laptop_monitor_entry" | jq -e ".disabled == true"; then
    echo "Internal monitor is disabled; enabling..."
    hyprctl keyword monitor "$laptop_monitor_enable_param"
else
    # Check if there is at least one other element with "disabled" set to false
    other_enabled=$(echo "$data" | jq ".[] | select(.name != \"$laptop_monitor_name\" and .disabled == false)")
    if [ -n "$other_enabled" ]; then
      echo "Internal monitor is enabled; disabling..."
      hyprctl keyword monitor "$laptop_monitor_name,disable"
    else
      echo "Not disabling internal monitor, because there is no other monitor enabled!"
      dunstify -t 5000 "I refuse to disable 'eDP-1'" "Because it's the last enabled monitor."
    fi
fi

