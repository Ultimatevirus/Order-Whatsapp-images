# Configurable paths
$Source = "C:\Users\Admin\Desktop\Order Whatsapp images\fixed"
$Dest = "This PC\The Fairphone (Gen. 6)\Internal shared storage\Android\media\com.whatsapp\WhatsApp\Media\WhatsApp Images"
$ADB = "D:\Applications\platform-tools\adb.exe"

Write-Host "Starting sequential sync of updated images..." -ForegroundColor Green

# Helper functions
function Test-AdbDevice {
    $devices = & $ADB devices 2>$null
    return ($devices -match "`tdevice")
}

function Restart-Adb {
    Write-Host "🔄 Restarting ADB server..." -ForegroundColor Red
    & $ADB kill-server | Out-Null
    Start-Sleep -Seconds 2
    & $ADB start-server | Out-Null
    Start-Sleep -Seconds 2
}

# Initial ADB check
if (-not (Test-AdbDevice)) {
    Write-Host "❌ No ADB device detected. Connect phone and enable USB debugging." -ForegroundColor Red
    Pause
    exit
}

# File enumeration
$Files = Get-ChildItem -Path $Source -File
$Total = $Files.Count
$Count = 0

# Counters
$NewCount     = 0
$UpdatedCount = 0
$SkippedCount = 0

foreach ($File in $Files) {
    $Count++
    $FileName = $File.Name
    $LocalModTime = [int][double](
        $File.LastWriteTimeUtc - (Get-Date "1970-01-01")
    ).TotalSeconds

    # Ensure device is still connected
    if (-not (Test-AdbDevice)) {
        Write-Host "[ $Count/$Total ] ⚠ Device lost. Waiting..." -ForegroundColor Red
        Restart-Adb
        continue
    }

    # Get phone file timestamp
    $PhoneTimeRaw = & $ADB shell `
        "if [ -f '$Dest/$FileName' ]; then stat -c %Y '$Dest/$FileName'; else echo 0; fi" 2>$null

    # Handle ADB failure safely
    if ([string]::IsNullOrWhiteSpace($PhoneTimeRaw)) {
        Write-Host "[ $Count/$Total ] ⚠ ADB error. Retrying file: $FileName" -ForegroundColor Red
        Restart-Adb
        continue
    }

    $PhoneTime = [int]$PhoneTimeRaw.Trim()

    # Decide action
    if ($PhoneTime -eq 0) {
        $Status = "New"
        $Color  = "Cyan"
        $NewCount++
    }
    elseif ($LocalModTime -gt $PhoneTime) {
        $Status = "Updating"
        $Color  = "Yellow"
        $UpdatedCount++
    }
    else {
        Write-Host "[ $Count/$Total ] ⏭ Skipping file: $FileName" -ForegroundColor DarkGray
        $SkippedCount++
        continue
    }

    # Push file
    Write-Host "[ $Count/$Total ] $Status file: $FileName" -ForegroundColor $Color
    & $ADB push "$($File.FullName)" "$Dest/$FileName" | Out-Null
}

# Summary
Write-Host "`n=== Sync Summary ===" -ForegroundColor Green
Write-Host "Total files checked: $Total"
Write-Host "✅ New files pushed: $NewCount" -ForegroundColor Cyan
Write-Host "🔄 Updated files pushed: $UpdatedCount" -ForegroundColor Yellow
Write-Host "⏭ Skipped files: $SkippedCount" -ForegroundColor DarkGray

Pause