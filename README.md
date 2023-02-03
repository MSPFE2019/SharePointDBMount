# SharePointDBMount
Script for SharePoint Dismount and Mount Script for patching

Dismount_DB.ps1 dismounts the database(s) from web application(s) and create contentdbs.csv(this files in need by Mount_Db.ps1).

Mount_DB.ps1
This script performs the following actions:

- It adds the SharePoint PowerShell snap-in, if it is not already added.
- It imports a CSV file named "contentdbs.csv" from the current directory.
- It sets the maximum number of upgrades to run at a time to 4.
- It defines a script block for the upgrade process that mounts a content database and waits for 50 seconds.
- It executes the upgrades in parallel, using a maximum of 4 threads at a time. It waits for open threads if the maximum number of threads is reached.
- It waits for all jobs to complete and retrieves the results.
- It removes the jobs and displays the results in a table format.
