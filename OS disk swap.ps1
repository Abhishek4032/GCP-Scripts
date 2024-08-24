# Login
gcloud auth login

# Select Project
$ProjectID = Read-Host "Enter the PROJECT of the VMs"
gcloud config set project $ProjectID

# Ensure gcloud CLI is installed and authenticated

# Prompt for VM names
$FaultyVM = Read-Host "Enter the name of the faulty VM (currently running)"
$WorkingVM = Read-Host "Enter the name of the working VM (currently stopped)"

# If want to delete restored VM use the below line as well
#$WorkingVMZone = Read-Host "Enter the zone of the Restored which you want to delete VM"

# Stop the faulty VM
Write-Host "Stopping the faulty VM ($FaultyVM)..."
gcloud compute instances stop $FaultyVM

# Stop the working VM (ensure it is already stopped)
Write-Host "Stopping the working VM ($WorkingVM)..."
gcloud compute instances stop $WorkingVM

# Get the OS disk names for both VMs
$FaultyVMDisk = gcloud compute instances describe $FaultyVM --format="value(disks[0].source)"
$WorkingVMDisk = gcloud compute instances describe $WorkingVM --format="value(disks[0].source)"

# Detach the OS disks
Write-Host "Detaching OS disk from the faulty VM ($FaultyVM)..."
gcloud compute instances detach-disk $FaultyVM --disk=$FaultyVMDisk

Write-Host "Detaching OS disk from the working VM ($WorkingVM)..."
gcloud compute instances detach-disk $WorkingVM --disk=$WorkingVMDisk

# Attach the working VM's OS disk to the faulty VM
Write-Host "Attaching OS disk from the working VM ($WorkingVM) to the faulty VM ($FaultyVM)..."
gcloud compute instances attach-disk $FaultyVM --disk=$WorkingVMDisk --boot

# Start the faulty VM
Write-Host "Starting the faulty VM ($FaultyVM)..."
gcloud compute instances start $FaultyVM

<# Delete the working VM
Write-Host "Deleting the working VM ($WorkingVM)..."
gcloud compute instances delete $WorkingVM --zone=$WorkingVMZone --quiet

Write-Host "Operation completed successfully."#>