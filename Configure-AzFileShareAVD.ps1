<# 
.SYNOPSIS
  Join Azure Files storage account to AD and mount the share
.DESCRIPTION
  Download and install AzFilesHybrid module, then join the storage account to Active Directory
  Adapted from https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable?WT.mc_id=Portal-Microsoft_Azure_FileStorage#run-join-azstorageaccount
.PARAMETER <Parameter_Name>
  None
.INPUTS
  None
.OUTPUTS
  None at present, future revision will include logging
.NOTES
  Version:        1.0
  Author:         Jesse Russell
  Creation Date:  1/19/2023
  Purpose/Change: Initial script development
  Future versions: Include logging, accept params  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>  
#>

$uri = "https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.2.5/AzFilesHybrid.zip"
$installdir = "C:\temp\AzFilesHybrid"
$dlfile = "AzFilesHybrid.zip"
$installer = "$installdir\$dlfile"

# Define parameters
$SubscriptionId = "" # Azure subscription ID
$ResourceGroupName = "" # The name of the existing Resource Group that holds the storage account to join to AD
$StorageAccountName = "" # The name of the existing Storage Account to join to AD
$DomainAccountType = "ComputerAccount" # Default is set as ComputerAccount, can also be ServiceLogonAccount 
$EncryptionType = "AES256" # "AES256" or "RC4" or "AES256,RC4"

# Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Check download location and create temp install directory 
If (Test-Path $installdir) {
    Write-Host "Directory exists, proceeding with installation"
} Else {
    New-Item $installdir -ItemType Directory
    Write-Host "Directory does not exist, creating and downloading installer"
}

# Download and expand AzHybridFiles PS Module
Invoke-WebRequest -Uri $uri -OutFile $dlfile
Expand-Archive -Path $installer -DestinationPath $installdir

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
.\CopyToPSPath.ps1 

# Import AzFilesHybrid module
Unblock-File -Path "$env:USERPROFILE\documents\WindowsPowershell\Modules\AzFilesHybrid\0.2.5.0\AzFilesHybrid.psm1"
Import-Module -Name AzFilesHybrid

# Login with an Azure AD credential that has either storage account owner or contributor Azure role 
# assignment. If you are logging into an Azure environment other than Public (ex. AzureUSGovernment) 
# you will need to specify that.
# See https://learn.microsoft.com/azure/azure-government/documentation-government-get-started-connect-with-ps
# for more information.
Connect-AzAccount

# Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 

# Register the target storage account with your active directory environment
Join-AzStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -DomainAccountType $DomainAccountType -EncryptionType $EncryptionType

<#
# Mount the file share as the Z drive to proceed with setting NTFS permissions
$connectTestResult = Test-NetConnection -ComputerName taofavddp.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$storageaccountname.file.core.windows.net\profiles" -Persist

} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
#>