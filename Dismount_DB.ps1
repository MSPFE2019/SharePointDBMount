##########################################################################################################
# Disclaimer
# The sample scripts are not supported under any Microsoft standard support program or service.
#
# The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all
# implied warranties including, without limitation, any implied warranties of merchantability or of fitness
# for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and
# documentation remains with you. In no event shall Microsoft, its authors, or anyone else involved in the
# creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without
# limitation, damages for loss of business profits, business interruption, loss of business information,
# or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, 
# even if Microsoft has been advised of the possibility of such damages.
##########################################################################################################

#Add SharePoint PowerShell Snap-In 
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)-eq $null) {Add-PSSnapin "Microsoft.SharePoint.PowerShell"} 

####Import CSV file from current directory 
  Import-Csv "contentdbs.csv"| % {
   $MaxThreads = 4 ###Number of Upgrades that will be ran at a time - max 10
   while (@(Get-Job | Where { $_.State -eq "Running" }).Count -ge $MaxThreads)
   {  Write-Host "Waiting for open thread...($MaxThreads Maximum)"
      Start-Sleep -Seconds 3
   }
   ### Mount of the database - trigger database upgrade
  $ScriptBlock = {
    param($Name,$webapp,$NormalizedDataSource) 
    
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    Mount-SPContentDatabase -WebApplication $name.webapp -Name $Name.name -DatabaseServer $name.NormalizedDataSource
    Start-Sleep 50
  }

  # Execute the jobs in parallel
  Start-Job -Name $_.name $ScriptBlock -ArgumentList $_
}
while (@(Get-Job | Where { $_.State -eq "Running" }).Count -ne 0) ##Check for running jobs
{  Write-Host "Waiting for background jobs..."
   Get-Job    #Just showing all the jobs
   Start-Sleep -Seconds 3
}
 
Get-Job       #Just showing all the jobs
$Data = foreach ($Job in (Get-Job)) {
   Receive-Job $Job
   Remove-Job $Job
}
 
$Data | Select Name, PSBeginTime, PSEndTime
