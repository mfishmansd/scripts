function Set-HubSiteTimezone {
    param (
        [Parameter(Mandatory=$true)]
        [string]$adminUrl,

        [Parameter(Mandatory=$true)]
        [string]$hubSiteUrl,

        [Parameter(Mandatory=$true)]
        [int]$timeZoneId
    )

    # Connect to SharePoint Online with MFA
    Connect-PnPOnline -Url $adminUrl -Interactive

    # Retrieve all site collection URLs associated with the specified hub site
    $associatedSiteUrls = Get-PnPHubSiteChild -Identity $hubSiteUrl

    foreach ($siteUrl in $associatedSiteUrls) {
        Write-Host "Updating timezone for site:" $siteUrl -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -Interactive

        # Get the web object
        $web = Get-PnPWeb
        $web.Context.Load($web.RegionalSettings.TimeZones)
        $web.Context.ExecuteQuery()

        # Find and update the specific timezone
        $timeZone = $web.RegionalSettings.TimeZones | Where-Object { $_.Id -eq $timeZoneId }
        if ($timeZone -ne $null) {
            $web.RegionalSettings.TimeZone = $timeZone
            $web.Update()
            $web.Context.ExecuteQuery()
            Write-Host "Timezone updated to" $timeZone.Description "for site:" $siteUrl -ForegroundColor Green
        }
        else {
            Write-Host "Timezone with ID $timeZoneId not found for site:" $siteUrl -ForegroundColor Red
        }
    }

    Write-Host "Timezone update for all sites complete." -ForegroundColor Yellow
}

# Example usage: Set-HubSiteTimezone -adminUrl "https://klarinet-admin.sharepoint.com" -hubSiteUrl "https://klarinet.sharepoint.com" -timeZoneId 13


function Get-HubSiteTimezone {
    param (
        [Parameter(Mandatory=$true)]
        [string]$adminUrl,

        [Parameter(Mandatory=$true)]
        [string]$hubSiteUrl
    )

    # Connect to SharePoint Online with MFA
    Connect-PnPOnline -Url $adminUrl -Interactive

    # Retrieve all site collection URLs associated with the specified hub site
    $associatedSiteUrls = Get-PnPHubSiteChild -Identity $hubSiteUrl

    foreach ($siteUrl in $associatedSiteUrls) {
        Write-Host "Retrieving timezone for site:" $siteUrl -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -Interactive

        # Get the web object
        $web = Get-PnPWeb
        $web.Context.Load($web.RegionalSettings.TimeZone)
        $web.Context.ExecuteQuery()

        # Display the current timezone
        $currentTimeZone = $web.RegionalSettings.TimeZone
        Write-Host "Current timezone for site" $siteUrl "is: ID -" $currentTimeZone.Id ", Description -" $currentTimeZone.Description -ForegroundColor Magenta
    }

    Write-Host "Timezone retrieval for all sites complete." -ForegroundColor Yellow
}

# Example usage: Get-HubSiteTimezone -adminUrl "https://klarinet-admin.sharepoint.com" -hubSiteUrl "https://klarinet.sharepoint.com"
