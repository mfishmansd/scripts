# Get-ValoWebParts.ps1

## Overview
This script retrieves and exports data about Valo web parts from all pages in a specified SharePoint hub site and its associated sites. It connects to the hub site, retrieves associated sites, processes the pages in the "Site Pages" library for each site, and identifies Valo web parts in use. The collected data is exported to a CSV file.

---

## Prerequisites

1. **PnP.PowerShell Module**
   - Ensure you have the PnP.PowerShell module installed.
   - Install using the following command if not already installed:
     ```powershell
     Install-Module -Name PnP.PowerShell -Force
     ```

2. **SharePoint Permissions**
   - Ensure you have the necessary permissions to access the hub site and its associated sites.

---

## Parameters

### Mandatory Parameters

- **HubSiteURL**
  - The URL of the SharePoint hub site to process.
  - Example: `https://contoso.sharepoint.com/sites/hub`

- **ClientId**
  - The Client ID for authenticating with SharePoint.

### Optional Parameters

- **ReportOutput**
  - The path where the CSV report will be saved.
  - Default: `C:\temp\Webparts-in-use.csv`

---

## Usage

### Example

```powershell
.\Get-ValoWebParts.ps1 -HubSiteURL "https://contoso.sharepoint.com/sites/hub" -ClientId "your-client-id" -ReportOutput "C:\temp\Webparts-in-use.csv"
```

---

## Script Workflow

1. **Import Required Module**
   - Loads the `PnP.PowerShell` module.

2. **Connect to SharePoint**
   - Authenticates with the specified SharePoint hub site using the provided `HubSiteURL` and `ClientId`.

3. **Retrieve Associated Sites**
   - Gathers all sites connected to the hub site.

4. **Process Pages in "Site Pages" Library**
   - Iterates through each page in the "Site Pages" library of each site.
   - Collects data about Valo web parts found on the pages.

5. **Export Results**
   - Outputs the collected data to a CSV file at the specified path.

---

## Output

- A CSV file containing the following details for each Valo web part found:
  - **Site URL**: The URL of the site containing the web part.
  - **Page**: The page where the web part is located.
  - **Web Part Title**: The title of the Valo web part.
  - **Web Part Type**: The type of the web part (JSON representation of properties).

---

## Notes

- Ensure you have sufficient permissions to access all associated sites and their pages.
- Use the `-Interactive` flag for the `Connect-PnPOnline` command to enable multi-factor authentication.
- The script skips pages where client-side page information is unavailable.

---

## License

This script is provided as-is without any warranty. Use at your own risk.
