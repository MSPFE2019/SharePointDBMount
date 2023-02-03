# Add SharePoint PowerShell Snap-In 
if (!(Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

# Import CSV file from current directory
$contentDBs = Import-Csv "contentdbs.csv"

# Maximum number of upgrades that will be run at a time
$MaxThreads = 4

# Define the script block for the upgrade process
$ScriptBlock = {
    param ($Name, $WebApp, $NormalizedDataSource)

    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    Mount-SPContentDatabase -WebApplication $WebApp -Name $Name -DatabaseServer $NormalizedDataSource
    Start-Sleep 50
}

# Execute the upgrades in parallel
foreach ($contentDB in $contentDBs) {
    while (@(Get-Job | Where { $_.State -eq "Running" }).Count -ge $MaxThreads) {
        Write-Host "Waiting for open thread...($MaxThreads Maximum)"
        Start-Sleep -Seconds 3
    }
    Start-Job -Name $contentDB.Name -ScriptBlock $ScriptBlock -ArgumentList $contentDB.Name, $contentDB.webapp, $contentDB.NormalizedDataSource
}

# Wait for all jobs to complete
while (@(Get-Job | Where { $_.State -eq "Running" }).Count -ne 0) {
    Write-Host "Waiting for background jobs..."
    Get-Job
    Start-Sleep -Seconds 3
}

# Get results and remove the jobs
$Data = foreach ($Job in (Get-Job)) {
    Receive-Job $Job
    Remove-Job $Job
}

# Display the results
$Data | Format-Table -AutoSize
