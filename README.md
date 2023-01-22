# AVD Configuration script collection

A collection of tools to streamline configuration of AVD session hosts

## Using the toolset

After creating a storage account and share to host FSLogix profile data, Configure-AzFileShareAVD can be run on a domain-joined computer to join the storage account to the domain and mount the share as Z to prepare for setting NTFS permissions.

Configure-FSLogix.ps1 installs and configures basic profile container settings for the profile container agent.

Configure-OfficeAVD.ps1 will run the Office Deployment Tool using the included avdconfig.xml, install OneDrive for all users, install Teams and prereqs (optional), and set all registry settings for a multi-session host. 
