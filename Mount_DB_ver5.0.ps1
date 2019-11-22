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
# even if Microsoft has been advised of the possibility of such damages.
##########################################################################################################

#Add SharePoint PowerShell Snap-In
if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null) {  
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"  
}


#Set param for the Start-Job 
param( $ScriptBlock = {
    param($Name,$webapp,$NormalizedDataSource) 
    
    Add-PSSnapin "Microsoft.SharePoint.PowerShell"
    Mount-SPContentDatabase -WebApplication $name.webapp -Name $Name.name -DatabaseServer $name.NormalizedDataSource
     }, 
    $Databases = Import-Csv "contentdbs.csv",#Get datbase Name and Webapp from the CSV file
    $MaxThreads = 10, # Max number of threads that can be used
    $SleepTimer = 500, # Sleep timer between Start-Jobs
    $MaxWaitAtEnd = 600, # Wait at the end of Start-Job
    )
    
	[xml]$xml = get-content "variables.xml" # Looks for the variable xml for email info
	
	
##$Databases = Get-Content $CDB

$i = 0

foreach ($Database in $Databases){
    while ($(Get-Job -state running).count -ge $MaxThreads){
        Write-Progress  -Activity "Upgrading Database 
                        -Status "Waiting for threads to close" 
                        -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" 
                        -PercentComplete ($i / $DB.count * 100)
        Start-Sleep -Milliseconds $SleepTimer
    }

    #"Starting job - "Mount and Upgrade Command
    $i++
    Start-Job -Name $_.name $ScriptBlock -ArgumentList $_
    Write-Progress  -Activity "Upgrading Database 
                        -Status "Waiting for threads to close" 
                        -CurrentOperation "$i threads created - $($(Get-Job -state running).count) threads open" 
       		         -PercentComplete ($i / $DB.count * 100)
    
}


# Getting the information back from the jobs
#Wait for all jobs
Get-Job | Wait-Job
 
#Get all job results
$UPGStatus = Get-Job | Receive-Job | ConvertTo-Html -Fragment

$ReportDate = Get-Date |select Day , DayOfWeek , Year | ConvertTo-Html -Fragment

#Get Start Time
$StartDate = Get-Date
$StartDateTime = $StartDate.ToUniversalTime()


#######################################  Convert Report to HTML #################################################################
#Create report and emaail it out to the users listed in the variable.xml file


$Header = @"
<style>
body {font-family:Calibri; font-size:10pt;}
th {background-color:#045FB4;color:white;}
td {background-color:#D8D8D8;color:black;}
</style>
"@

 
ConvertTo-Html -Head $header -Body "
<font color = blue><H1><B>SharePoint Database Mount Status Report</B></H1></font>
<font color = blue>Time Stamp -$StartDateTime</font>
<font color = blue><H4><B>Databases/Status</B></H4></font>$UPGStatus

 
<font color = blue><H4><B>" -Title "SharePoint Database Upgrade Status Report"  | Out-File "UPGSReport.html" -Encoding ascii

#######################################  Send Email ###########################################################################

 
 
 
$fromaddress = $xml.variables.fromaddress
$toaddress = $xml.variables.toaddress
$Subject = $xml.variables.subject
$smtpserver = $xml.variables.smtpserver
$body = Get-Content "UPGSReport.html
$attachment = 'UPGSReport.html'

 
 
 
$message = new-object System.Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$message.From = $fromaddress
$message.To.Add($toaddress)
$message.IsBodyHtml = $TRUE
$message.Subject =$Subject

 
 
$message.body = $body
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$smtp.Send($message)
$attachment.Dispose();
$message.Dispose();

 
#######################################  Monitoring Script End #################################################################




