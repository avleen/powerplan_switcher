# powerplan_switcher

This script checks your process list to see which processes are currently
running. Based on that it switches the power plan your system is using.

## Why this script exists
While Windows can do a reasonable job of reducing CPU frequency while the
system is idle, there isn't a good way to tune how aggressive this is.

On my AMD 3900X system I found that even under very light load (< 5%) the
CPU was very rarely scaled down much. It may go from 4GHz to 3.5GHz before
jumping back up.
I wanted a way to keep the CPU scaled down significantly more when I'm not
doing intensive work (web browsing, emails) but still be able to ramp up
when I run CPU intensive tasks (photo and video editing, games).

Using this method my CPU frequency is reduced to 50% most of the time, which
results in a running CPU temperature around 39C and minimal fan use.

## How to use this script
If you have a relatively modern CPU which sits idle most of the time, follow
these steps and adjust to your own needs.

1. Modify your power plan settings in Windows. Choose the "Power Saver" plan,
    and click "Change advanced settings".
    Then under Processor power management > Maximum processor state, set the
    limit to 50%.
2. Fork the script and change the names of any programs you want to use in
    "Balanced" (medium) or "High performance" (high) modes.
    Note that this isn't the name of the executable, but the name that shows
    up in the output of the `Get-Process` in PowerShell.
3. Set up a new entry in Task Scheduler.
    Under General, set the user to `SYSTEM`. This prevents a window popping up
    on your screen every minute.
    Under Triggers, set this to run `One time`, and then check the box to
    repeat every minute.
    Under Actions, set the program to start, to:
    `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
    Set the arguments to: `-File "C:\<path_to_powerplan_switcher.ps1>"`

