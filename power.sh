#!/usr/bin/env bash

# Make sure you have acpi_call set up and the module is loaded
ACPI_CALL="/proc/acpi/call"
ACPI_BASE_PATH='\_SB.PCI0.LPC0.EC0'

# Store the user that is calling the script
# Used to decide whether to use sudo
USER=$(id -u)

# Global variable for functions to store their return values
# Use with caution, may get overwritten by intermediary functions
ret=""

# ACPI path to set power mode
POWER_MODE_SET="${ACPI_BASE_PATH}.VPC0.DYTC"

# Power modes
declare -A POWER_MODE_VALUES=(
    ["extreme_performance"]="0x0012B001"
    ["battery_saving"]="0x0013B001"
    ["intelligent_cooling"]="0x000FB001"
)

# ACPI path to set the value of rapid charge
RAPID_CHARGE_SET="${ACPI_BASE_PATH}.VPC0.SBMC"

# ACPI path to get the value of rapid charge
RAPID_CHARGE_QUERY="${ACPI_BASE_PATH}.FCGM"

declare -A RAPID_CHARGE_SET_VALUES=(
    ['on']='0x07'
    ['off']='0x08'
)


# Runs an acpi call. If the calling script has a `ret`
# global variable, the result will be saved there.
run_acpi_call(){
    PRIV=""
    if [[ $USER -ne 0 ]]; then
        PRIV="sudo"
    fi

    echo "$@" | $PRIV tee $ACPI_CALL > /dev/null
    ret="$($PRIV cat $ACPI_CALL | cut -d '' -f1)"
}

# Gets power mode
power_mode_get(){
    # Get QTMD and STMD bits
    run_acpi_call "$ACPI_BASE_PATH.QTMD"
    QTMD="$ret"
    run_acpi_call "$ACPI_BASE_PATH.STMD"
    STMD="$ret"

    # Interpret results
    printf "current mode: "
    if [[ "$QTMD" = "0x0" ]] && [[ "$STMD" = "0x0" ]]; then
        echo "extreme_performance"
    elif [[ "$QTMD" = "0x1" ]] && [[ "$STMD" = "0x0" ]]; then
        echo "battery_saving"
    elif [[ "$QTMD" = "0x0" ]] && [[ "$STMD" = "0x1" ]]; then
        echo "intelligent_cooling"
    fi
}

# Sets power mode
power_mode_set(){
    CMD="${POWER_MODE_VALUES[$1]}"
    if [[ "$CMD" = "" ]]; then
        echo "power_mode_set: invalid power mode"
        echo "available: [ extreme_performance battery_saving intelligent_cooling ]"
        return 1
    fi

    run_acpi_call "$POWER_MODE_SET $CMD"
    power_mode_get
}

# Sets rapid charge to on or off
rapid_charge_set(){
    if [[ $# -ne 1 ]]; then
        echo "rapid_charge_set: invalid argc"
        return 1
    elif [[ $1 != "on" ]] && [[ $1 != "off" ]]; then
        echo "rapid_charge_set: invalid argument"
        return 1
    fi

    run_acpi_call "$RAPID_CHARGE_SET ${RAPID_CHARGE_SET_VALUES[$1]}"
    rapid_charge_get
}

# Gets the current rapid charge status
rapid_charge_get(){
    if [[ $# -ne 0 ]]; then
        echo "rapid_charge_get: no arguments must be supplied"
        return 1
    fi

    run_acpi_call "$RAPID_CHARGE_QUERY"
    if [[ "$ret" = "0x0" ]]; then
        echo "rapid charge OFF"
    elif [[ "$ret" = "0x1" ]]; then
        echo "rapid charge ON"
    else
        echo "rapid_charge_get: unknown result > $ret"
    fi
}

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
