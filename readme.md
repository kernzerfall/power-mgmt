# power-mgmt

![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black) ![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?logo=gnu-bash&logoColor=white)

Power management utility for Lenovo 14ALC05 82LM. Supports changing
the **Power Mode** (albeit this functionality has been integrated into
powerdevil since the time I wrote this) and Enabling/Disabling **Rapid 
Charge**.

### Notice

This utility messes around with ACPI functions that I deducted
from a DSDT dump of *my* own device. I'm not responsible in any way
if it breaks *your* device.


## Functions

### Setters

Argument|ACPI Function|Value
-|-|-|
`--enable-rapid-charge`|`\_SB.PCI0.LPC0.EC0.VPC0.SBMC`|`0x07`
`--disable-rapid-charge`|`\_SB.PCI0.LPC0.EC0.VPC0.SBMC`|`0x08`
`--battery-saving`|`\_SB.PCI0.LPC0.EC0.VPC0.DYTC` | `0x0013B001`
`--intelligent-cooling`|`\_SB.PCI0.LPC0.EC0.VPC0.DYTC` |`0x000FB001`
`--performance`|`\_SB.PCI0.LPC0.EC0.VPC0.DYTC` |`0x0012B001`

### Getters

Argument|ACPI Function
-|-|
`--query-rapid-charge`|`\_SB.PCI0.LPC0.EC0.FCGM`
`--query-power-mode`|`\_SB.PCI0.LPC0.EC0.QTMD` <br> `\_SB.PCI0.LPC0.EC0.STMD`