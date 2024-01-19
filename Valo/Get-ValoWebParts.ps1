<#
.SYNOPSIS
This script retrieves and exports data about Valo web parts from all pages in a specified SharePoint hub site and its associated sites.

.DESCRIPTION
The script connects to a specified SharePoint hub site, processes the hub site, retrieves the list of associated sites, iterates through each site and all pages in the "site pages" library,
and collects data about any Valo web parts it finds on each page. The collected data is exported to a CSV file.

.PARAMETER HubSiteURL
The URL of the SharePoint hub site to process.

.PARAMETER ReportOutput
The path where the CSV report will be saved.

.EXAMPLE
.\Get-ValoWebParts.ps1 -HubSiteURL "https://klarinetdemo.sharepoint.com/sites/hub" -ReportOutput "C:\temp\Webparts-in-use.csv"

.NOTES
Make sure to have the PnP.PowerShell module installed before running this script.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$HubSiteURL,

    [Parameter(Mandatory=$false)]
    [string]$ReportOutput = "C:\temp\Webparts-in-use.csv"
)

# Import the required module
Import-Module PnP.PowerShell
Write-Host "Module Imported" -ForegroundColor Green

[System.Collections.ArrayList]$ResultCollection = @()

# Get all sites associated with the hub site
$AssociatedSites = Get-PnPHubSiteChild -Identity $HubSiteURL
Write-Host "Associated sites retrieved" -ForegroundColor Green

$TotalSites = $AssociatedSites.Count + 1  # +1 for the hub site
$ProcessedSites = 0

# Define a function to process a single site
function Process-Site {
    param (
        [string]$SiteURL,
        [int]$SiteNumber
    )

    # Connect to the site
    Connect-PnPOnline -Url $SiteURL -Interactive
    Write-Host "Connected to $SiteURL" -ForegroundColor Cyan

    Write-Host "Processing Site $SiteURL" -ForegroundColor Cyan
    $PagesLib = Get-PnPList -Identity "Site Pages"
    Write-Host "`tPages library retrieved" -ForegroundColor Yellow

    $Pages = Get-PnPListItem -List $PagesLib
    Write-Host "`tPages list items retrieved" -ForegroundColor Yellow

    # Update the progress bar
    Write-Progress -Activity "Processing Site $SiteNumber of $TotalSites" -Status "$ProcessedSites sites processed" -PercentComplete (($ProcessedSites / $TotalSites) * 100)

    # Iterate through all Pages
    foreach ($Page in $Pages)
    {
        Write-Host "`t`Processing Page $($Page.FieldValues.FileLeafRef)" -ForegroundColor Green
   
        $PageURL = $Page.FieldValues.FileRef
        $PageName = $PageURL -replace '^.*\/(.*?)\.aspx$', '$1'
        $ClientSidePage = Get-PnPClientSidePage -Identity $PageName -ErrorAction SilentlyContinue
    
        if ($null -ne $ClientSidePage) {
            Write-Host "`tClient Side Page information retrieved" -ForegroundColor Green
            $WebParts = $ClientSidePage.Controls
            Write-Host "`tWeb Parts information retrieved" -ForegroundColor Green
                
            # Get All Web Parts data
            foreach ($WebPart in $WebParts)
            {
                if ($WebPart.Title -like "*Valo*") {
                    Write-Host "`t`tValo Web Part found" -ForegroundColor Magenta
                    $Result = New-Object PSObject
                    $Result | Add-Member -Type NoteProperty -Name "Site URL" -Value $SiteURL
                    $Result | Add-Member -Type NoteProperty -Name "Page" -Value $PageURL
                    $Result | Add-Member -Type NoteProperty -Name "Web Part Title" -Value $WebPart.Title
                    $Result | Add-Member -Type NoteProperty -Name "Web Part Type" -Value $WebPart.PropertiesJson.ToString()
            
                    $null = $ResultCollection.Add($Result)
                }
            }
        }
        else {
            Write-Host "`tNo client side page information found for page $PageName" -ForegroundColor Red
        }
    }

    # Disconnect from the site
    #Disconnect-PnPOnline
    #Write-Host "Disconnected from $SiteURL" -ForegroundColor Cyan

    $script:ProcessedSites++  # Increment the number of processed sites
}
# Connect to the Hub Site to get associated sites
Connect-PnPOnline -Url $HubSiteURL -Interactive

# Process the hub site itself
Process-Site -SiteURL $HubSiteURL -SiteNumber 1

# Iterate through each associated site
$SiteNumber = 2  # Start numbering with 2 since the hub site was 1
foreach ($Site in $AssociatedSites) {
    Process-Site -SiteURL $Site -SiteNumber $SiteNumber
    $SiteNumber++
}

# Export results to CSV
$ResultCollection | Export-Csv $ReportOutput -NoTypeInformation
Write-Host "Results exported to $ReportOutput" -ForegroundColor Green
