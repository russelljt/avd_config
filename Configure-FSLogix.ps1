<# 
.SYNOPSIS
  Install and configure FSLogix profile container
.DESCRIPTION
  Install and configure FSLogix profile container for AVD session hosts deployments, does not manage Office containers or Cloud Cache
.PARAMETER <Parameter_Name>
  None
.INPUTS
  None
.OUTPUTS
  None at present, future revision will include logging
.NOTES
  Version:        1.0
  Author:         Jesse Russell
  Creation Date:  1/17/2023
  Purpose/Change: Initial script development
  Future versions: Include logging, accept profile container location as param
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>  
#>

# Variable definitions
$profcont = "<placeholder>" # Enter the Azure Files profile container location path
$profsize = 30000 # Enter the profile size in MB (30000 is default)

# None of these variables should need to change
$uri = "https://aka.ms/fslogix/download"
$dlfile = "c:\temp\FSLogix\FSLogix.zip"
$installdir = "c:\temp\FSLogix"

If (Test-Path $installdir) {
    Write-Host "Directory exists, proceeding with installation"
} Else {
    New-Item $installdir -ItemType Directory
    Write-Host "Directory does not exist, creating and downloading"
    Invoke-WebRequest -Uri  $uri -OutFile $dlfile
    Expand-Archive -Path $dlfile -DestinationPath $installdir
}

Start-Process -FilePath $installdir\x64\Release\FSLogixAppsSetup.exe -ArgumentList "/install /quiet /norestart"
Wait-Process -Name "FSLogixAppsSetup"

###### Begin configuring profile containers ######
Write-Host "Install complete, configuring registry settings"
$regpath = 'HKLM:\SOFTWARE\FSLogix\Profiles'

If (!(Test-Path $regpath)) {
    New-Item -Path $regpath -Force | Out-Null
    Write-Host "Registry key for container profile settings does not exist, creating registry key"
} else {
    Write-Host "Registry key for container profile settings exists, creating profile settings"
}

New-ItemProperty -Path $regpath -Name 'FlipFlopProfileDirectoryName' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $regpath -Name 'IsDynamic' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $regpath -Name 'PreventLoginWithFailure' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $regpath -Name 'PreventLoginWithTempProfile' -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $regpath -Name 'SizeInMBs' -Value $profsize -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $regpath -Name 'VHDLocations' -Value $profcont -PropertyType String -Force | Out-Null
New-ItemProperty -Path $regpath -Name 'VolumeType' -Value "VHDX" -PropertyType String -Force | Out-Null

# Remove-Item -Path $installdir -Recurse -Force