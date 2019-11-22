#Add SharePoint PowerShell Snap-In 
			if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) { 
			Add-PSSnapin "Microsoft.SharePoint.PowerShell"} 

$dbs = Get-SPContentDatabase
        if ($dbs) {
            $dbs | % {$wa = $_.WebApplication.Url; $_ | select Name, NormalizedDataSource, @{n = "WebApp"; e = {$wa}}} | Export-Csv "contentdbs.csv" -NoTypeInformation -force
            $dbs | % {
                "$($_.Name),$($_.NormalizedDataSource)"
                Dismount-SPContentDatabase $_ -Confirm:$false
            }
        }