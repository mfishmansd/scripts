# Get-FolderSizesWithDepthAndProgress.ps1

## Overview

`Get-FolderSizesWithDepthAndProgress.ps1` is a PowerShell script designed to recursively calculate the size of folders within a specified directory up to a user-defined depth. The script provides real-time progress updates and outputs the results to a CSV file.

## Features

- **Recursive Folder Size Calculation**: Calculates the total size of each folder, including subfolders and files, up to a specified depth.
- **User-Defined Parameters**: Allows users to specify the root directory, output CSV file location, and maximum depth of recursion.
- **Progress Indicator**: Displays a progress bar to keep track of the script’s execution status.
- **CSV Export**: Outputs the folder sizes and paths to a CSV file for easy analysis and reporting.

## Parameters

- `-RootFolder` (string): The root directory from which the folder size calculation begins.
- `-OutputFile` (string): The path where the output CSV file will be saved.
- `-MaxDepth` (int): The maximum depth of recursion into the directory structure (default is 3).

## Usage

1. **Copy the Script**: Download or copy the `Get-FolderSizesWithDepthAndProgress.ps1` file to your local machine.
2. **Run PowerShell as Administrator**: Open PowerShell with administrative privileges.
3. **Execute the Script**:
    ```powershell
    .\Get-FolderSizesWithDepthAndProgress.ps1 -RootFolder "C:\path\to\directory" -OutputFile "C:\path\to\output\FolderSizes.csv" -MaxDepth 3
    ```
4. **Check the Output**: The script will generate a CSV file at the specified location with the folder sizes and paths.

## Example

To calculate folder sizes starting from `C:\temp`, recurse up to 3 levels deep, and save the results to `C:\temp\FolderSizes.csv`, use the following command:

```powershell
.\Get-FolderSizesWithDepthAndProgress.ps1 -RootFolder "C:\temp" -OutputFile "C:\temp\FolderSizes.csv" -MaxDepth 3


# Export-SharePointFolders.ps1

## Overview

`Export-SharePointFolders.ps1` is a PowerShell script that recursively exports the folder structure of a SharePoint Online document library to a CSV file. The script prompts for your site, lets you pick a document library, and reports progress as it works.

## Features

- **Document Library Selection**: Lists all libraries and lets you choose.
- **Recursive Folder Export**: Exports all folders, subfolders, and counts of files/folders up to your chosen depth.
- **Progress Indicator**: Shows script progress in the console.
- **CSV Export**: Outputs folder paths and counts for easy reporting.

## Parameters / Prompts

- **Client ID**: Enter your Azure AD App Client ID (with Sites.Read.All permission). If blank, the script tries to register a new app.
- **Tenant Name**: Your Azure AD tenant (e.g., `contoso.onmicrosoft.com`).
- **Site URL**: SharePoint Online site to scan.
- **Library**: Select from detected document libraries.
- **Depth**: How many folder levels to recurse.

## Usage

1. **Copy the Script**: Download or copy `Export-SharePointFolders.ps1` to your machine.
2. **Install PnP.PowerShell**:  
    ```powershell
    Install-Module PnP.PowerShell -Scope CurrentUser
    ```
3. **Run the Script in PowerShell**:  
    ```powershell
    ./Export-SharePointFolders.ps1
    ```
4. **Follow Prompts**: Enter your client ID, tenant, site URL, pick a library, and set recursion depth.
5. **Check Output**: The script generates a CSV file with folder names, paths, and child file/folder counts.

## Example

```powershell
./Export-SharePointFolders.ps1
```
_Follow the interactive prompts as they appear._

## Notes for macOS Users

- If you get "App registration failed...keychain" errors, manually register your Azure AD app in the Azure Portal and enter the Client ID when prompted.
- You may need to clear cached tokens:
    ```
    security delete-generic-password -s "PnP.PowerShell" ~/Library/Keychains/login.keychain-db 2>/dev/null
    ```
- Make sure your app has `Sites.Read.All` permission with admin consent.

---
