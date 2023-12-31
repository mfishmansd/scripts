# SharePoint Hub Site Timezone Management Functions

This document provides instructions and details for using two PowerShell functions designed for managing timezones in SharePoint Online Hub Sites. These functions are part of a PnP PowerShell script.

## Prerequisites
- PnP PowerShell Module: These scripts require the PnP PowerShell module to be installed. You can install it using `Install-Module SharePointPnPPowerShellOnline`.
- Permissions: You need to have administrative privileges for the SharePoint Online environment.
- MFA (Multi-Factor Authentication) must be enabled for your account.

## Functions

### `Set-HubSiteTimezone`
This function updates the timezone for all site collections associated with a specified SharePoint Online hub site.

#### Parameters
- `adminUrl`: URL of the SharePoint admin site.
- `hubSiteUrl`: URL of the hub site whose site collections need timezone updates.
- `timeZoneId`: The ID of the timezone to set. Timezone IDs can be found in the [Microsoft documentation](https://learn.microsoft.com/en-us/previous-versions/office/sharepoint-csom/jj171282(v=office.15)#remarks).

#### Example Usage
```powershell
Set-HubSiteTimezone -adminUrl "https://tenantname-admin.sharepoint.com" -hubSiteUrl "https://tenantname.sharepoint.com" -timeZoneId 13
```

### `Get-HubSiteTimezone`
This function retrieves and displays the current timezone settings for all site collections associated with a specified SharePoint Online hub site.

#### Parameters
- `adminUrl`: URL of the SharePoint admin site.
- `hubSiteUrl`: URL of the hub site whose site collections' timezone settings you want to retrieve.

#### Example Usage
```powershell
Get-HubSiteTimezone -adminUrl "https://tenantname-admin.sharepoint.com" -hubSiteUrl "https://tenantname.sharepoint.com"
```

## Notes
- The scripts use the `-Interactive` parameter for `Connect-PnPOnline` to handle MFA-enabled accounts. You will be prompted for credentials and MFA verification.
- The output includes color-coded messages for better readability.

## Disclaimer
Ensure to test these scripts in a non-production environment before using them in production. The author is not responsible for any unintended consequences of these scripts.
