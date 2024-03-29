# SharePointDBMount
Script for SharePoint Dismount and Mount Script for patching

Dismount_DB.ps1 

This PowerShell script performs the following tasks:

- Checks if the "Microsoft.SharePoint.PowerShell" snap-in is installed. If it is not installed, it adds the snap-in.
- Retrieves all SharePoint content databases using the Get-SPContentDatabase cmdlet.
- Exports the content database information to a CSV file named "contentdbs.csv". The exported fields are Name, NormalizedDataSource, and WebApp.
- Loops through each content database and dismounts it using the Dismount-SPContentDatabase cmdlet. It confirms the dismount action without prompting the user for confirmation.


The script assumes that you have the appropriate permissions to execute SharePoint PowerShell cmdlets and access SharePoint content databases.

Please note that dismounting a content database may cause downtime for the SharePoint farm or web application that is using it. It is important to understand the impact of this action before executing this script.



Mount_DB.ps1

This PowerShell script performs upgrades on SharePoint content databases in parallel, using a CSV file to specify the databases to upgrade.

The first section of the script checks if the SharePoint PowerShell Snap-In is loaded and, if not, loads it.

The second section of the script imports a CSV file named "contentdbs.csv" that should be located in the same directory as the script. This CSV file should contain a list of content databases to upgrade, with each database specified on a separate line and the following columns:

Name: The name of the content database.
WebApp: The name of the web application associated with the content database.
NormalizedDataSource: The server name where the content database is located.
The third section of the script defines a script block that will be executed for each content database. The script block mounts the content database and waits for 50 seconds to give the mount process time to complete.

The fourth section of the script uses a foreach loop to execute the upgrades in parallel, using Start-Job to create a new background job for each content database. The maximum number of parallel upgrades is controlled by the $MaxThreads variable, which is set to 4 in this example. The while loop that precedes the Start-Job command checks if the maximum number of parallel upgrades has been reached and waits if necessary for a slot to become available.

The fifth section of the script waits for all background jobs to complete before proceeding. The while loop checks if any jobs are still running and waits if necessary.

The sixth section of the script gets the results of each job and removes the jobs.

Finally, the script displays the results in a formatted table.

