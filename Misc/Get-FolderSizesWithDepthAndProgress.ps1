function Get-FolderSizes {
    param (
        [string]$RootFolder,
        [string]$OutputFile,
        [int]$MaxDepth = 3
    )

    function Get-FolderSize {
        param (
            [string]$Path,
            [int]$Level = 0
        )

        # Update progress
        $global:currentItem++
        $percentComplete = [math]::Round(($global:currentItem / $global:totalItems) * 100, 2)
        Write-Progress -Activity "Calculating folder sizes" -Status "Processing $Path" -PercentComplete $percentComplete

        # Get the size of the current folder
        $folderSize = (Get-ChildItem -Path $Path -Recurse -File | Measure-Object -Property Length -Sum).Sum

        # Create a custom object to store the folder's information
        $folderInfo = [PSCustomObject]@{
            Path = $Path
            SizeMB = [Math]::Round($folderSize / 1MB, 2)  # Size in MB
        }

        # Add the folder info to the global array
        $global:folderSizes += $folderInfo

        # If the current level is less than the max depth, recurse into subfolders
        if ($Level -lt $MaxDepth) {
            Get-ChildItem -Path $Path -Directory | ForEach-Object {
                Get-FolderSize -Path $_.FullName -Level ($Level + 1)
            }
        }
    }

    # Initialize the global array to store folder sizes
    $global:folderSizes = @()
    $global:currentItem = 0

    # Calculate the total number of items for the progress indicator
    $global:totalItems = (Get-ChildItem -Path $RootFolder -Recurse -Directory).Count

    # Get the folder sizes starting from the specified directory
    Get-FolderSize -Path $RootFolder

    # Output the results to a CSV file
    $global:folderSizes | Export-Csv -Path $OutputFile -NoTypeInformation

    Write-Output "Folder sizes have been exported to $OutputFile"
}

# Example usage
Get-FolderSizes -RootFolder "C:\temp" -OutputFile "C:\temp\FolderSizes.csv" -MaxDepth 3
