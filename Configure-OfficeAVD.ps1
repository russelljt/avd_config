<# 
.SYNOPSIS
  Install and configure Office for AVD session hosts
.DESCRIPTION
  Install and configure Office for AVD session host deployments, includes options for OneDrive and Teams if necessary
.PARAMETER <Parameter_Name>
  None
.INPUTS
  None
.OUTPUTS
  None at present, future revision will include logging
.NOTES
  Version:        0.1
  Author:         Jesse Russell
  Creation Date:  1/18/2023
  Purpose/Change: Initial script development
  Future versions: Include logging, accept Teams and OneDrive options as param
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>  
#>

# Variable definitions
$teamsreq = "" # Teams machine installation required (Y/N)
$onedrivereq = "Y" # OneDrive machine installation required (Y/N)
$aztenantid = "" # Azure Tenant ID

# None of these variables should need to change
$uri = "https://github.com/russelljt/avd_config/raw/master/odt_avd.zip" # Need to find correct download link
$dlfile = "c:\temp\ODT\odt_avd.zip"
$installdir = "c:\temp\ODT"

If (Test-Path $installdir) {
    Write-Host "Directory exists, proceeding with installation"
} Else {
    New-Item $installdir -ItemType Directory
    Write-Host "Directory does not exist, creating"
}

Write-host = "Downloading and extracting ODT"
Invoke-WebRequest -Uri $uri -OutFile $dlfile
Expand-Archive -Path $dlfile -DestinationPath $installdir

Write-Host = "Launching ODT installation"
Start-Process -FilePath $installdir\setup.exe -ArgumentList "/configure $installdir\avdconfig.xml"

####### OneDrive download and install block below #######
$regpath = "HKLM:\Software\Microsoft\OneDrive"
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=844652" -OutFile $installdir\OneDriveSetup.exe

if (!(test-path $regpath)){
  Write-Host "OneDrive registry key does not exist, creating"  
  New-Item -Path $regpath -Force | Out-Null
} else {
  Write-Host "OneDrive registry key exists, proceeding with installation"
}

# Add allUsersInstall option to registry and kick off install
& REG ADD "HKLM\Software\Microsoft\OneDrive" /v "AllUsersInstall" /t REG_DWORD /d 1 /reg:64
Start-Process -FilePath $installdir/OneDriveSetup.exe -ArgumentList "/allusers"

# Set onedrive to start at launch, silent user configuration, and opt into KFM silently
& REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /t REG_SZ /d "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe /background" /f
& REG ADD "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" /v "SilentAccountConfig" /t REG_DWORD /d 1 /f
& REG ADD "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" /v "KFMSilentOptIn" /t REG_SZ /d "$aztenantid" /f

####### Teams download and install block below #######
if ($teamsreq -eq "Y"){
  Write-Host "Teams required, installing Teams and prerequisites"
  Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile $installdir\vc_redist.x64.exe
  Invoke-WebRequest -Uri "https://aka.ms/msrdcwebrtcsvc/msi" -OutFile $installdir\WebRTCSvc.msi
  Invoke-WebRequest -Uri "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true" -OutFile $installdir\Teams_install.msi
  
  Start-Process -FilePath $installdir\vc_redist.x64.exe -ArgumentList "/Quiet" -Wait
  Start-Process "msiexec.exe"-ArgumentList "/i $installdir\WebRTCSvc.msi /l*v $installdir\WebRTC.log /qn" -Wait
  
  & reg add "HKLM\SOFTWARE\Microsoft\Teams" /v IsWVDEnvironment /t REG_DWORD /d 1 /f
  Start-Process "msiexec.exe" -ArgumentList "/i $installdir\Teams_install.msi /l*v $installdir\Teams.log /qn ALLUSER=1 ALLUSERS=1"
} Else {
  Write-Host "Teams not required, skipping install"
}

Restart-Computer -Force