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
