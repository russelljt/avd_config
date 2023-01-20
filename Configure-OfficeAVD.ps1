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
$uri = "https://www.microsoft.com/en-us/download/confirmation.aspx?id=49117" # Need to find correct download link
$dlfile = "c:\temp\ODT\ODT.exe"
$installdir = "c:\temp\ODT"

If (Test-Path $installdir) {
    Write-Host "Directory exists, proceeding with installation"
} Else {
    New-Item $installdir -ItemType Directory
    Write-Host "Directory does not exist, creating and downloading installer"
    Invoke-WebRequest -Uri $uri -OutFile $dlfile
}

Start-Process -FilePath $dlfile -ArgumentList "/quiet /extract:$installdir"
Start-Process -FilePath $installdir\setup.exe -ArgumentList "/configure avdconfig.xml"

####### OneDrive download and install block below #######

Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=844652" -OutFile $installdir\OneDriveSetup.exe

Start-Process -Path $installdir/OneDriveSetup.exe -ArgumentList "/allusers"

<#
REG ADD "HKLM\Software\Microsoft\OneDrive" /v "AllUsersInstall" /t REG_DWORD /d 1 /reg:64
REG ADD "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /t REG_SZ /d "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe /background" /f

REG ADD "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" /v "SilentAccountConfig" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" /v "KFMSilentOptIn" /t REG_SZ /d "<your-AzureAdTenantId>" /f
#>

####### Teams download and install block below #######
