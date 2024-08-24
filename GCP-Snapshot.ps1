$VMName = Read-host "Enter the VM Name"
$TicketNumber = Read-host "Enter the Ticket number"
$GD = (Get-Date).GetDateTimeFormats()[5]
$GCProject = Get-GcpProject | Where-Object {($_.name -match "KD-") -or ($_.name -match "test-poc")}
foreach($Pr in $GCProject){
$GCPRID = $pr.projectid
$GCIN= Get-GceInstance -Project "$GCPRID" | Where-Object {$_.name -eq "$VMName"}
$GCINDISK = $GCIN.Disks
foreach($GCIND in $GCINDISK){
if($GCIND.boot -eq $true){
$sourceinfo = $GCIND.Source.Split('/')[-5]
$GCINDD= $GCIND.DeviceName
  Write-host "$GCINDD is a Boot disk"
  Write-host "Capturing Snapshot of Boot Disk $GCINDD" -ForegroundColor Yellow
  Get-GceDisk -Project "$sourceinfo" | Where-Object {$_.Name -eq "$GCINDD"} | Add-GceSnapshot -Name "$TicketNumber-$VMName-osdisk-$GD"
  Write-host "Capturing Snapshot of Boot Disk $GCINDD completed" -ForegroundColor Green
  Write-Output "$TicketNumber-$VMName-OSDISK-$GD" | Out-File $env:USERPROFILE\documents\snapshotinfo"$GD".txt -Append
}
else{
$GCINDD1= $GCIND.DeviceName
  Write-host "$GCINDD1 is a data disk"
  Write-host "Capturing Snapshot of Data Disk $GCINDD1" -ForegroundColor Yellow
  Get-GceDisk -Project "$sourceinfo" | Where-Object {$_.Name -eq "$GCINDD1"} |  Add-GceSnapshot -Name "$TicketNumber-$VMName-$GCINDD1-$GD"
  Write-host "Capturing Snapshot of Data Disk $GCINDD1 completed" -ForegroundColor Green
  Write-Output "$TicketNumber-$VMName-$GCINDD1-$GD" | Out-File $env:USERPROFILE\documents\snapshotinfo"$GD".txt -Append
}
}
}