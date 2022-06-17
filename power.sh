#!/usr/bin/env bash

SCRIPT_DIR="/opt/power-mgmt/"

source "$SCRIPT_DIR/power-mode.rc"
source "$SCRIPT_DIR/rapid-charge.rc"

print_usage(){
    echo " >>> power-mgmt by kernzerfall <<<"
    echo
    echo "Compatible with Lenovo 14ALC05 82LM"
    echo
    echo "commands:"
    echo "  --enable-rapid-charge   Enables rapid charge"
    echo "  --disable-rapid-charge  Disables rapid charge"
    echo "  --query-rapid-charge    Gets the current state of rapid charge"
    echo "  --intelligent-cooling   Sets the power mode to intelligent cooling"
    echo "  --performance           Sets the power mode to extreme performance"
    echo "  --battery-saving        Sets the power mode to battery saving"
    echo "  --query-power-mode      Gets the current power mode"
    echo "  --help                  Prints this help message"
}

case "$1" in
    "--enable-rapid-charge" )
        rapid_charge_set on;;
    "--disable-rapid-charge")
        rapid_charge_set off;;
    "--query-rapid-charge")
        rapid_charge_get;;
    "--intelligent-cooling")
        power_mode_set intelligent_cooling;;
    "--performance" )
        power_mode_set extreme_performance;;
    "--battery-saving") 
        power_mode_set battery_saving;;
    "--query-power-mode")
        power_mode_get;;
    "--help")
        print_usage;;
esac