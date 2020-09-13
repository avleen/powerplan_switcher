# This service will look for running processes every 10 seconds.
# Based on the results it will switch the current power plan to be more
# performant, or more energy saving.

# Debug
# Set-PSDebug -Trace 1

# Config
$low_plan_name = "Power saver"
$medium_plan_name = "Balanced"
$high_plan_name = "High performance"

$medium_processes = "Nothing","Foo"
$high_processes = "Lightroom","World of Warcraft"

# Get the list of power plans on the system
$installed_plans = powercfg.exe /LIST
function GetPowerPlans {
    param (
        $plan_name
    )
    $plan_line = $installed_plans | Select-String "\($plan_name\)"
    return (($plan_line)-Split " ")[3]
}

function GetActivePlan {
    $plan_line = $installed_plans | Select-String "\*$"
    $active_plan = (($plan_line) -Split " ")[3]
    return $active_plan
}

function Logger {
    param (
        $message
    )
    Write-EventLog -LogName "Windows PowerShell" `
    -Source "PowerShell" `
    -EventId 3001 `
    -EntryType Information `
    -Message "$message"
}
# Get the UUIDs for each power plan, we need this to switch between them
$low_plan_uuid = GetPowerPlans($low_plan_name)
$medium_plan_uuid = GetPowerPlans($medium_plan_name)
$high_plan_uuid = GetPowerPlans($high_plan_name)

# Turn the list of processes into a regex pattern to search for
$medium_processes = [string]::Join("|", $medium_processes)
$high_processes = [string]::Join("|", $high_processes)

$active_plan = GetActivePlan

# Check which processes are running
$process_list = Get-Process
$high_running = ($process_list | Select-String -Pattern $high_processes).Length
$medium_running = ($process_list | Select-String -Pattern $medium_processes).Length

# Switch plans if needed
if ($high_running -ge 1) {
    if ($active_plan -eq $high_plan_uuid) {
        exit
    }
    Logger("Changing to $high_plan_name plan")
    powercfg.exe /SETACTIVE $high_plan_uuid
} elseif ($medium_running -ge 1) {
    if ($active_plan -eq $medium_plan_uuid) {
        exit
    }    
    Logger("Changing to $medium_plan_name plan")
    powercfg.exe /SETACTIVE $medium_plan_uuid
} elseif ($active_plan -ne $low_plan_uuid) {
    Logger("Changing to $low_plan_name plan")
    powercfg.exe /SETACTIVE $low_plan_uuid
}