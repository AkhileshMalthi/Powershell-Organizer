# Start transcript logging
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$transcriptPath = "C:\PS_Organizer_Logs\organizer_log_$timestamp.txt"
Start-Transcript -Path $transcriptPath -Append

try {
    # Get the current directory
    $sourceDirectory = Get-Location

    # Get all files in the current directory
    $files = Get-ChildItem -Path $sourceDirectory -File -ErrorAction Stop

    # Initialize log array for organization
    $organizationLog = @()
    $createdDirectories = @{}

    # Define mappings for file extensions to folder names
    $extensionMappings = @{
        'docx'  = 'Microsoft Word Documents'
        'xlsx'  = 'Microsoft Excel Spreadsheets'
        'pptx'  = 'Microsoft PowerPoint Presentations'
        'pdf'   = 'Adobe PDF Documents'
        'txt'   = 'Text Files'
        'jpg'   = 'JPEG Images'
        'png'   = 'PNG Images'
        'gif'   = 'GIF Images'
        'mp3'   = 'MP3 Audio'
        'mp4'   = 'MP4 Videos'
        'zip'   = 'ZIP Archives'
        'rar'   = 'RAR Archives'
        '7z'    = '7-Zip Archives'
        'exe'   = 'Executable Files'
        'dll'   = 'Dynamic Link Libraries'
        'ps1'   = 'PowerShell Scripts'
        'bat'   = 'Batch Files'
        'cmd'   = 'Command Scripts'
        'py'    = 'Python Scripts'
        'java'  = 'Java Source Code'
        'cpp'   = 'C++ Source Code'
        'cs'    = 'C# Source Code'
        'html'  = 'HTML Documents'
        'css'   = 'CSS Stylesheets'
        'js'    = 'JavaScript Files'
        'json'  = 'JSON Data'
        'xml'   = 'XML Documents'
        'csv'   = 'CSV Files'
        'log'   = 'Log Files'
        'bak'   = 'Backup Files'
        'tmp'   = 'Temporary Files'
        # Add more mappings as needed for other file types
    }

    # Loop through each file
    foreach ($file in $files) {
        # Get the extension of the file and convert it to lowercase
        $extension = $file.Extension.TrimStart('.').ToLower()

        # Check if there's a custom folder name for the extension
        if ($extensionMappings.ContainsKey($extension)) {
            $folderName = $extensionMappings[$extension]
        } else {
            # If no custom name is defined, use the extension as folder name
            $folderName = $extension.ToUpper() + ' Files'
        }

        # Create a directory for the extension if it doesn't exist
        $extensionDirectory = Join-Path -Path $sourceDirectory -ChildPath $folderName
        if (-not (Test-Path -Path $extensionDirectory -PathType Container)) {
            New-Item -Path $extensionDirectory -ItemType Directory | Out-Null
            $createdDirectories[$extensionDirectory] = $true
        }

        # Move the file to the extension directory
        $destinationPath = Join-Path -Path $extensionDirectory -ChildPath $file.Name
        Move-Item -Path $file.FullName -Destination $destinationPath -Force

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
            Move-Item -Path $sourcePath -Destination $destinationPath -Force -ErrorAction SilentlyContinue
        }
        
        # Remove empty directories created during organization
        foreach ($directory in $createdDirectories.Keys) {
            if ((Get-ChildItem -Path $directory | Measure-Object).Count -eq 0) {
                Remove-Item -Path $directory -Force -Recurse -ErrorAction SilentlyContinue
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
finally {
    # Stop transcript logging
    Stop-Transcript
    Write-Host "`n" -NoNewline
}
