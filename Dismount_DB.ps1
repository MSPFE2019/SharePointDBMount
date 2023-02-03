# Add SharePoint PowerShell Snap-In 
if (!(Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue)) {
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
}

# Get all SharePoint Content Databases and Export to CSV
$contentDBs = Get-SPContentDatabase

if ($contentDBs) {
    $contentDBs | Select-Object Name, NormalizedDataSource, @{Name = "WebApp"; Expression = {$_.WebApplication.Url}} | Export-Csv "contentdbs.csv" -NoTypeInformation -Force
    $contentDBs | ForEach-Object {
        "$($_.Name),$($_.NormalizedDataSource)"
        Dismount-SPContentDatabase $_ -Confirm:$False
    }
}
