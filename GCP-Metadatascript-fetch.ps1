# Define a function to fetch VM details
function Get-VMDetails {
  param (
      [string]$projectId
  )
  
  # Authenticate with GCP using the gcloud CLI
  #gcloud auth activate-service-account --key-file="path-to-your-service-account-key.json"
  
  # Set the project
  gcloud config set project $projectId
  
  # Fetch VM instances
  $instances = gcloud compute instances list --format=json | ConvertFrom-Json
  
  $vmDetailsList = @()
  
  foreach ($instance in $instances) {
      $instanceName = $instance.name
      $zone = $instance.zone
      
      # Get metadata for the instance to check if scripts are setup
      $metadata = gcloud compute instances describe $instanceName --zone=$zone --format=json | ConvertFrom-Json
      $startupScript = $metadata.metadata.items | Where-Object { $_.key -eq 'startup-script' }
      
      if ($startupScript) {
          $vmDetails = [PSCustomObject]@{
              ProjectId = $projectId
              InstanceName = $instanceName
              Zone = $zone.Split('/')[-1];
              StartupScript = $startupScript.value
          }
          $vmDetailsList += $vmDetails
      }
  }
  
  return $vmDetailsList
}

# Get list of all projects
function Get-AllProjects {
  $projects = gcloud projects list --format=json | ConvertFrom-Json
  return $projects
}

# Main script execution
$allVmDetails = @()
$projects = Get-AllProjects

foreach ($project in $projects) {
  $projectId = $project.projectId
  Write-Output "Fetching VMs for project: $projectId"
  
  $vmDetails = Get-VMDetails -projectId $projectId
  
  if ($vmDetails) {
      $allVmDetails += $vmDetails
  } else {
      Write-Output "No scripts found for project: $projectId"
  }
}

# Export the data to a CSV file
$csvFilePath = "C:\D Drive\VMsWithStartupScripts.csv"
$allVmDetails | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Output "Data exported to $csvFilePath"