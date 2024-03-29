try {
    # Get the current directory
    $sourceDirectory = Get-Location

    # Get all files in the current directory
    $files = Get-ChildItem -Path $sourceDirectory -File -ErrorAction Stop

    # Initialize log array for organization
    $organizationLog = @()
    $createdDirectories = @{}

    # Loop through each file
    foreach ($file in $files) {
        # Get the extension of the file and convert it to lowercase
        $extension = $file.Extension.TrimStart('.').ToLower()

        # Create a directory for the extension if it doesn't exist
        $extensionDirectory = Join-Path -Path $sourceDirectory -ChildPath $extension
        if (-not (Test-Path -Path $extensionDirectory -PathType Container)) {
            New-Item -Path $extensionDirectory -ItemType Directory -ErrorAction Stop | Out-Null
            $createdDirectories[$extensionDirectory] = $true
        }

        # Move the file to the extension directory
        $destinationPath = Join-Path -Path $extensionDirectory -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction Stop

        # Add log entry for organization
        $organizationLogEntry = @{
            'FileName' = $file.Name
            'SourceDirectory' = $file.DirectoryName
            'DestinationDirectory' = $extensionDirectory
        }
        $organizationLog += New-Object PSObject -Property $organizationLogEntry
    }

    # Output organization log
    Write-Host "`nFiles organized successfully.`n" -ForegroundColor Green
    $organizationLog | Format-Table -AutoSize

    # Ask for undo
    Write-Host -NoNewline "`nDo you want to undo the organization? (Y/N) " -ForegroundColor Yellow
    $undo = Read-Host
    if ($undo -eq "Y") {
        # Undo organization by moving files back
        foreach ($logEntry in $organizationLog) {
            $sourcePath = Join-Path -Path $logEntry.DestinationDirectory -ChildPath $logEntry.FileName
            $destinationPath = Join-Path -Path $logEntry.SourceDirectory -ChildPath $logEntry.FileName
            Move-Item -Path $sourcePath -Destination $destinationPath -Force -ErrorAction Stop
        }
        
        # Remove empty directories created during organization
        foreach ($directory in $createdDirectories.Keys) {
            if ((Get-ChildItem -Path $directory | Measure-Object).Count -eq 0) {
                Remove-Item -Path $directory -Force -Recurse -ErrorAction Stop
            }
        }
        
        Write-Host "`nOrganization undone. Files restored to their original locations.`n" -ForegroundColor Green
    } else {
        Write-Host "`nUndo skipped.`n" -ForegroundColor Yellow
    }
} catch {
    Write-Host "`nAn error occurred:`n$_" -ForegroundColor Red
    Write-Host "`nError details:`n" -ForegroundColor Red
    Write-Host "`nException Type:`t" -NoNewline -ForegroundColor Red
    Write-Host $_.Exception.GetType().FullName -ForegroundColor Yellow
    Write-Host "Message:`t`t" -NoNewline -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Write-Host "Item Name:`t`t" -NoNewline -ForegroundColor Red
    Write-Host $_.Exception.ItemName -ForegroundColor Yellow
    Write-Host "Position Message:`t" -NoNewline -ForegroundColor Red
    Write-Host $_.InvocationInfo.PositionMessage -ForegroundColor Yellow
}
