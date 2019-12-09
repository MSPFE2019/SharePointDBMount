# SharePointDBMount
Script for SharePoint Dismount and Mount Script for patching

Dismount_DB.ps1 dismounts the database(s) from web application(s) and create contentdbs.csv(this files in need by Mount_Db.ps1).

Mount_DB.ps1 mounts the database(s) at 4 at time and trigger database upgrade. (reads from contentdbs.csv)
