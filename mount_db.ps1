  
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
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)
-eq $null) {Add-PSSnapin "Microsoft.SharePoint.PowerShell"} 


###PowerShell run as Job#####
foreach($Object in $Objects) { #Where $Objects is a collection of objects to process. It may be a computers list, for example.
    $Check = $false #Variable to allow endless looping until the number of running jobs will be less than $maxConcurrentJobs.
    while ($Check -eq $false) {
        if ((Get-Job -State 'Running').Count -lt $maxConcurrentJobs) {
  Import-Csv "contentdbs.csv"| %{

  # Define what each job does
  $ScriptBlock = {
    param($Name,$webapp,$NormalizedDataSource) 
    
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    Mount-SPContentDatabase -WebApplication $name.webapp -Name $Name.name -DatabaseServer $name.NormalizedDataSource
    Start-Sleep 50
  }

  # Execute the jobs in parallel
  Start-Job -Name $_.name $ScriptBlock -ArgumentList $_
  $Check = $true #To stop endless looping and proceed to the next object in the list
}



# Wait for it all to complete
While (Get-Job -State "Running")
{
  Start-Sleep 10
}

# Getting the information back from the jobs
Get-Job | Wait-Job
Get-Job | Receive-Job
