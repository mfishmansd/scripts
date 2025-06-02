# Requires: PnP.PowerShell module

function Write-Log {
    param (
        [string]$Message,
        [string]$LogFile = $LogFilePath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp`t$Message"
    Add-Content -Path $LogFile -Value $entry
}

$LogFilePath = "PnPFolderExportLog-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
Write-Log "Script started."

Write-Host "`n--- Script Started ---`n"

# Prompt for App Client ID or create new App Registration
$clientId = Read-Host "Enter your PnP PowerShell Azure AD App Client ID (leave blank to create one)"

if ([string]::IsNullOrWhiteSpace($clientId)) {
    Write-Host "No Client ID provided. Creating a new Azure AD App Registration..."
    $tenantName = Read-Host "Enter your Azure AD Tenant Name (e.g., contoso.onmicrosoft.com)"
    try {
        Write-Host "Registering Azure AD App..."
        $appReg = Register-PnPAzureADApp `
            -ApplicationName "PnP-FolderExport-$(Get-Date -Format 'yyyyMMddHHmmss')" `
            -Tenant $tenantName `
            -OutPath "." `
            -Interactive
        $clientId = $appReg.AppId
        Write-Host "App Registration created with Client ID: $clientId"
        Write-Log "App Registration created with Client ID: $clientId"
    }
    catch {
        Write-Host "App registration failed: $_"
        Write-Log "App registration failed: $_"
        throw "App registration failed. See log for details."
    }

    $consentUrl = "https://login.microsoftonline.com/common/adminconsent?client_id=$clientId"
    Write-Host "`nApp Registration created with Client ID: $clientId"
    Write-Host "You must now grant admin consent for this application."
    Write-Host "Open the following URL in a browser (as a Global Admin) and complete the consent process:"
    Write-Host $consentUrl -ForegroundColor Yellow
    Write-Log "Prompted user for admin consent. Consent URL: $consentUrl"
    $null = Read-Host "`nAfter granting consent, press Enter to continue"
}

# Prompt for site URL
$siteUrl = Read-Host "Enter SharePoint Site URL"
Write-Host "Site URL entered: $siteUrl"
Write-Log "Site URL: $siteUrl"

# Connect using App Registration
try {
    Write-Host "Connecting to SharePoint site using Client ID..."
    Connect-PnPOnline -Url $siteUrl -ClientId $clientId -Interactive
    Write-Host "Connected to site."
    Write-Log "Connected to site with Client ID $clientId"
}
catch {
    Write-Host "Failed to connect to site: $_"
    Write-Log "Failed to connect to site: $_"
    throw "Failed to connect to site. See log for details."
}

# Get document libraries
Write-Host "Getting document libraries..."
$libraries = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false }
Write-Host "Found $($libraries.Count) document libraries."
if ($libraries.Count -eq 0) {
    Write-Host "No document libraries found."
    Write-Log "No document libraries found."
    throw "No document libraries found."
}

Write-Host "`nDocument Libraries:"
$i = 1
$libraries | ForEach-Object {
    Write-Host "$i. $($_.Title)"
    $i++
}

# Select library
$libNumber = Read-Host "Enter the number of the document library"
Write-Host "Library number entered: $libNumber"
[int]$libNumberInt = $libNumber
if ($libNumberInt -lt 1 -or $libNumberInt -gt $libraries.Count) {
    Write-Host "Invalid library selection: $libNumber"
    Write-Log "Invalid library selection: $libNumber"
    throw "Invalid selection."
}
$selectedLib = $libraries[$libNumberInt - 1]
Write-Host "Selected library: $($selectedLib.Title)"
Write-Log "Selected library: $($selectedLib.Title)"

# Select depth
$depth = Read-Host "Enter how many levels deep to scan (e.g., 2 for root + 2 levels)"
Write-Host "Scan depth entered: $depth"
if (-not ($depth -as [int]) -or $depth -lt 1) {
    Write-Host "Invalid depth: $depth"
    Write-Log "Invalid depth: $depth"
    throw "Invalid depth."
}
$depth = [int]$depth
Write-Log "Scanning depth: $depth"

# Prepare output
$script:output = @()
$script:statusCount = 0

function Get-FolderStructure {
    param(
        [string]$FolderPath,     # Site-relative path, e.g., "Shared Documents/SomeSubFolder"
        [int]$CurrentDepth,
        [int]$MaxDepth,
        [string]$CurrentServerRelativePath,
        [bool]$IsRoot = $false
    )

    if ([string]::IsNullOrEmpty($FolderPath) -or [string]::IsNullOrEmpty($CurrentServerRelativePath)) {
        Write-Host "Skipped empty FolderPath."
        Write-Log "Skipped empty FolderPath."
        return
    }

    Write-Host "Scanning folder: $FolderPath (Level $CurrentDepth/$MaxDepth)"
    $folderItems = Get-PnPListItem -List $selectedLib -PageSize 1000 -Fields "FileLeafRef","FileDirRef","FSObjType"
    Write-Host " - Items returned: $($folderItems.Count)"
    #foreach ($item in $folderItems) {
    #     Write-Host "   Item Name: $($item.FieldValues['FileLeafRef']) - FSObjType: $($item.FieldValues['FSObjType']) - FileDirRef: $($item.FieldValues['FileDirRef'])"
    # }

    # Only items whose FileDirRef matches this folder's server-relative path are direct children
    $theseItems = $folderItems | Where-Object { $_.FieldValues['FileDirRef'] -eq $CurrentServerRelativePath }
    $folders = $theseItems | Where-Object { $_.FieldValues["FSObjType"] -eq 1 }
    $files = $theseItems | Where-Object { $_.FieldValues["FSObjType"] -eq 0 }

    Write-Host " - Child folders: $($folders.Count), Child files: $($files.Count)"

    $script:statusCount++
    Write-Progress -Activity "Scanning Folders" -Status "$FolderPath" -PercentComplete 0

    $script:output += [PSCustomObject]@{
        "FolderName"   = Split-Path $FolderPath -Leaf
        "RelativePath" = $FolderPath
        "ChildFiles"   = ($files | Measure-Object).Count
        "ChildFolders" = ($folders | Measure-Object).Count
    }

    if ($CurrentDepth -lt $MaxDepth) {
        foreach ($folder in $folders) {
            $subfolderName = $folder.FieldValues['FileLeafRef']
            $subfolderPath = [System.IO.Path]::Combine($FolderPath, $subfolderName) -replace '\\','/'
            $subfolderServerRelative = $CurrentServerRelativePath + "/" + $subfolderName
            Get-FolderStructure -FolderPath $subfolderPath -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth -CurrentServerRelativePath $subfolderServerRelative -IsRoot:$false
        }
    }
}


# Get site-relative root folder url (not server-relative!)
$web = Get-PnPWeb
$rootFolderUrl = $selectedLib.RootFolder.ServerRelativeUrl
$siteRelativePath = $rootFolderUrl.Substring($web.ServerRelativeUrl.Length).TrimStart("/")
$startFolderPath = if ([string]::IsNullOrEmpty($siteRelativePath)) { $selectedLib.RootFolder.Name } else { $siteRelativePath }
# Calculate server-relative root path for this library
$serverRelativeRoot = $selectedLib.RootFolder.ServerRelativeUrl
Write-Host "Root folder site-relative path: $startFolderPath"
Write-Log "Starting scan. Library: $($selectedLib.Title), Root: $startFolderPath, Depth: $depth"

Get-FolderStructure -FolderPath $startFolderPath -CurrentDepth 0 -MaxDepth $depth -CurrentServerRelativePath $serverRelativeRoot -IsRoot:$true

Write-Host "`nScan complete. Output row count: $($script:output.Count)"

# Export to CSV (after all recursion)
$csvPath = "FolderStructure-$($selectedLib.Title)-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
$script:output | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
Write-Host "`nExport complete. CSV saved to: $csvPath"
Write-Log "Exported CSV: $csvPath"
Write-Log "Script completed."

Write-Host "`n--- Script Finished ---`n"
