# Requirements:-

#	Your system should have GCP Cloud SDK install. 
#	Your system should have PowerShell script execution permission on your laptop.
#	Also please execute “gcloud auth login” command in Cloud SDK before executing the script to get into the GCP API.

# How to run:-

# Copy and paste the text file on your system. 
#	Rename the file extension from .txt to .ps1.
#	Open PowerShell > CD to the directory where you saved the file > type file name and press tab key> it will show you the file with ./ prefix. > press enter.
#	Once completed, it will save the files in your document folder with the specific project name. 











$PR = Get-GcpProject | Where-Object {($_.Name -match "KD-") -or ($_.Name -match "test-poc-01")} -ErrorAction SilentlyContinue
foreach($p in $PR){
$PRID = $P.ProjectId
$GCEDISK= Get-GceDisk -Project "$PRID"
foreach($disk in $GCEDISK){
$InUSE = $disk.Users.Split('/')[-1]
$info = [ordered]@{
         'Project' = $PRID;
            'Name' = $disk.Name;
            'ID'   = $disk.Id;
        'Size (GB)'= $disk.SizeGB;
    'CreationDate' = $disk.CreationTimestamp;
    'Disk Type'    = $disk.Type.Split('/')[-1];
    'Zone'         = $disk.Zone.Split('/')[-1];
    'In Use by'    = $InUSE
            }
$obj = New-Object -TypeName psobject -Property $info
Write-Output $obj | Export-csv -Path $env:USERPROFILE\Documents\"$PRID"disk.csv -NoTypeInformation -Append
}
}