<#
.SYNOPSIS
This script adds a specified user as an admin to all sites in a specified SharePoint hub site and its associated sites.

.DESCRIPTION
The script connects to the SharePoint Online Admin Center, retrieves all sites associated with a specified hub site, and adds a specified user as an admin to each site. It handles scenarios where the user might already be an admin.

.PARAMETER AdminSiteURL
The URL of the SharePoint Online Admin Center, usually formatted as https://<tenant>-admin.sharepoint.com.

.PARAMETER HubSiteURL
The URL of the SharePoint hub site from which associated sites will be retrieved.

.PARAMETER UserPrincipalName
The User Principal Name (email address) of the user to be added as an admin.

.EXAMPLE
.\Add-UserAsAdminToHubSites.ps1 -AdminSiteURL "https://contoso-admin.sharepoint.com" -HubSiteURL "https://contoso.sharepoint.com/sites/hub" -UserPrincipalName "user@contoso.com"

.NOTES
Ensure the PnP.PowerShell module is installed and you have administrative permissions to add site collection administrators.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$AdminSiteURL, 

    [Parameter(Mandatory=$true)]
    [string]$HubSiteURL,

    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName
)

# Import the required module
Import-Module PnP.PowerShell
Write-Host "Module Imported" -ForegroundColor Green

# Connect to the SharePoint Admin Center
Connect-PnPOnline -Url $AdminSiteURL -Interactive
Write-Host "Connected to SharePoint Admin Site" -ForegroundColor Cyan

# Retrieve all sites associated with the specified hub site
$AssociatedSites = Get-PnPHubSiteChild -Identity $HubSiteURL
Write-Host "Retrieved associated sites for the hub site" -ForegroundColor Green

# Function to add a specified user as an admin to a site
function Add-UserAsAdmin {
    param (
        [string]$SiteURL,
        [string]$UserName
    )

    # Connect to the site
    Connect-PnPOnline -Url $SiteURL -Interactive
    Write-Host "Connected to $SiteURL" -ForegroundColor Cyan

    # Attempt to add the specified user as a site collection administrator
    try {
        Set-PnPSite -Owners $UserName
        Write-Host "User $UserName added as admin to $SiteURL" -ForegroundColor Green
    } catch {
        Write-Host "Failed to add admin: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Disconnect from the site
    Disconnect-PnPOnline -ErrorAction Ignore
    Write-Host "Disconnected from $SiteURL" -ForegroundColor Cyan
}

# Iterate through each associated site and add the user as admin
foreach ($Site in $AssociatedSites) {
    Add-UserAsAdmin -SiteURL $Site -UserName $UserPrincipalName
}

# Disconnect from the SharePoint Admin Center
Disconnect-PnPOnline
Write-Host "All operations completed." -ForegroundColor Green
