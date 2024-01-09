# Get-ValoWebParts PowerShell Script

## Synopsis
This script retrieves and exports data about Valo web parts from all pages in a specified SharePoint hub site and its associated sites.

## Description
The script connects to a specified SharePoint hub site, processes the hub site, retrieves the list of associated sites, iterates through each site and all pages in the "site pages" library, and collects data about any Valo web parts it finds on each page. The collected data is exported to a CSV file.

## Prerequisites
- PnP.PowerShell module must be installed.

## Parameters

### HubSiteURL
- Description: The URL of the SharePoint hub site to process.
- Mandatory: Yes

### ReportOutput
- Description: The path where the CSV report will be saved.
- Mandatory: No
- Default: "C:\\temp\\Webparts-in-use.csv"

## Usage
```powershell
.\Get-ValoWebParts.ps1 -HubSiteURL "https://klarinetdemo.sharepoint.com/sites/hub" -ReportOutput "C:\\temp\\Webparts-in-use.csv"
