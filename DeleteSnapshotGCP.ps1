# Requirements:-

# Your system should have GCP Cloud SDK install.
# You should have PowerShell script execution permission on your laptop.

# How to run:-

# Copy and paste the text file on your system.
# Rename the file extension from .txt to .ps1.
# Open PowerShell > CD to the directory where you saved the file > type DeleteSnapshotGCP and press tab key> it will show you the file with ./ prefix. > press enter.
# It will ask you to enter the project name and count of months for how much older snapshots needs to be deleted. Type project name and month counts in numeric and hit enter post entering every info.
# It will show you the snapshot name which will be deleted and confirm the post deletion as well. 













$CutoffMonth = Read-Host "Enter the month counts for how much older snapshots needs to be deleted as per the current date"
$Project = Read-Host "Enter the Project Name"
$dt = (get-date).AddMonths(-$CutoffMonth)
$DTN = $dt.GetDateTimeFormats()[101]
$GCESN = Get-GceSnapshot -Project "$project" | Where-Object {$_.CreationTimestamp -le $DTN}
Foreach($GC in $GCESN){
$GCEPN = $GC.Name.Split('/')[-1]
Write-host "Removing Snapshot $GCEPN" -ForegroundColor Yellow
Remove-GceSnapshot -Name $GCEPN -Project $Project
Write-host "Snapshot $GCEPN has been deleted" -ForegroundColor Green
}
