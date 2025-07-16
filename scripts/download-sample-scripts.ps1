Param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptDir
)

$scripts = @{
    'Clear Browser Cache and Cookies.bat' = 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Clear%20Browser%20Cache%20and%20Cookies.bat'
    'Empty Downloads Folder.bat'         = 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Empty%20Downloads%20Folder.bat'
    'Empty Recycle Bin.ps1'              = 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Empty%20Recycle%20Bin.ps1'
    'Reset Windows Update Cache.bat'     = 'https://raw.githubusercontent.com/njvanas/AIO-Maintenance/main/scripts/Reset%20Windows%20Update%20Cache.bat'
}

foreach ($script in $scripts.GetEnumerator()) {
    try {
        $output = Join-Path $ScriptDir $script.Key
        Invoke-WebRequest -Uri $script.Value -OutFile $output -UseBasicParsing -ErrorAction Stop
        Write-Host "Downloaded: $($script.Key)"
    }
    catch {
        Write-Host "Failed to download: $($script.Key)"
    }
}
