#Add SharePoint PowerShell Snap-In 
                                                if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) { 
                                                Add-PSSnapin "Microsoft.SharePoint.PowerShell"} 


###PowerShell run as Job#####

  Import-Csv "F:\contentdbs.csv"| %{

  # Define what each job does
  $ScriptBlock = {
    param($Name,$webapp,$NormalizedDataSource) 
    
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    Mount-SPContentDatabase -WebApplication $name.webapp -Name $Name.name -DatabaseServer $name.NormalizedDataSource
    Start-Sleep 50
  }

  # Execute the jobs in parallel
  Start-Job -Name $_.name $ScriptBlock -ArgumentList $_
}



# Wait for it all to complete
While (Get-Job -State "Running")
{
  Start-Sleep 10
}

# Getting the information back from the jobs
Get-Job | Wait-Job
Get-Job | Receive-Job
