# Juha Hokkanen 8.3.2025
# PC info -skripti, joka kerää tietoja tietokoneesta ja lähettää tiedot GitHubin kautta Azuren staattiselle sivulle.

# Kerää järjestelmätiedot
try {
    $computerName = $env:COMPUTERNAME
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $osName = $os.Caption
    $osVersion = $os.Version
    $osBuild = $os.BuildNumber

    $cpu = Get-CimInstance -ClassName Win32_Processor
    $processorName = $cpu.Name
    $processorCores = $cpu.NumberOfCores
    $processorThreads = $cpu.ThreadCount

    $totalMemory = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)

    $gpu = Get-CimInstance -ClassName Win32_VideoController
    $gpuName = $gpu[0].Name

    $bios = Get-CimInstance -ClassName Win32_BIOS
    $biosInfoManufacturer = $bios.Manufacturer
    $biosInfoVersion = $bios.BIOSVersion
    $biosInfoReleaseDate = $bios.ReleaseDate

    # Kerää nykyisen käyttäjän kansion koon
    $currentUserPath = $env:USERPROFILE
    $userFolderSize = (Get-ChildItem -Path $currentUserPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $userFolderSizeGB = [math]::Round([double]$userFolderSize / 1GB, 2)

    $bootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    
    # Kerää C-kovalevyn koko
    $cDrive = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'"
    $cDriveSizeGB = [math]::Round(($cDrive.Size - $cDrive.FreeSpace) / 1GB, 2)
    

    # Hanki nykyinen päivämäärä ja kellonaika
    $currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
} catch {
    Write-Host "Virhe järjestelmätietojen hakemisessa: $_"
    exit 1
}

# Luo HTML-sisältö
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Computer Information</title>
    <style>
        body { font-family: Arial, sans-serif; }
        h1, h2, p { text-align: center; }
        table { margin: 0 auto; width: 90%; border-collapse: collapse; }
        table, th, td { border: 1px solid black; }
        th, td { padding: 8px; text-align: left; }
        footer { margin-top: 20px; font-size: 0.8em; text-align: center; }
    </style>
</head>
<body>
    <h1>Computer Information</h1>
    <table>
        <tr><th>Computer Name</th><td>$computerName</td></tr>
        <tr><th>OS Name</th><td>$osName</td></tr>
        <tr><th>OS Version</th><td>$osVersion</td></tr>
        <tr><th>OS Build</th><td>$osBuild</td></tr>
        <tr><th>Processor</th><td>$processorName</td></tr>
        <tr><th>Processor Cores</th><td>$processorCores</td></tr>
        <tr><th>Processor Threads</th><td>$processorThreads</td></tr>
        <tr><th>Total Memory (GB)</th><td>$totalMemory</td></tr>
        <tr><th>GPU</th><td>$gpuName</td></tr>
        <tr><th>BIOS Manufacturer</th><td>$biosInfoManufacturer</td></tr>
        <tr><th>BIOS Version</th><td>$biosInfoVersion</td></tr>
        <tr><th>BIOS Release date</th><td>$biosInfoReleaseDate</td></tr>
        <tr><th>Last Boot time</th><td>$bootTime</td></tr>
    </table>
    <h2>Current User Folder Size</h2>
    <table>
        <tr><th>User</th><th>Size (GB)</th></tr>
        <tr><td>$env:USERNAME</td><td>$userFolderSizeGB</td></tr>
    </table>
<h2>Used Space on C: Drive</h2>
    <table>
        <tr><th>Drive</th><th>Used Space (GB)</th></tr>
        <tr><td>C:</td><td>$cDriveSizeGB</td></tr>
    </table>
    <h2>Data Retrieved At</h2>
    <p>$currentDateTime</p>
    <footer>
        <p>&copy; 2025 Juha Hokkanen. All rights reserved.</p>
    </footer>
</body>
</html>
"@

# Luo ja tallenna HTML-tiedosto
$htmlPath = "C:\Temp\ComputerInfo.html"
if (-not (Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory | Out-Null
}
$htmlContent | Out-File -FilePath $htmlPath
Write-Host "HTML-tiedosto tallennettu polkuun $htmlPath"

Start-Process "C:\Temp\ComputerInfo.html"

# Päivitä tiedot GitHub-repositorioon
$localRepoPath = "$env:USERPROFILE\OneDrive\Documents\scriptit\Uusi PC INFO"
if (-not (Test-Path -Path $localRepoPath)) {
    Write-Host "Virhe: GitHub-repositoriota ei löydy polusta $localRepoPath. Tarkista polku."
    exit 1
}
Copy-Item $htmlPath -Destination "$localRepoPath\index.html" -Force
Set-Location -Path $localRepoPath
try {
    git add index.html
    git commit -m "Päivitetty ComputerInfo.html $currentDateTime"
    git push origin main
    Write-Host "Tietokoneen tiedot päivitetty GitHubiin."
} catch {
    Write-Host "Virhe GitHub-pushin aikana: $_"
    exit 1
}

# Odota 60 sekuntia ennen verkkosivun tarkistusta
Write-Host "Odotetaan 1 minuutti ennen Azure-sivun avaamista..."
Start-Sleep -Seconds 60

$webAppUrl = "https://lively-tree-073188d03.4.azurestaticapps.net/"
try {
    $response = Invoke-WebRequest -Uri $webAppUrl -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "Verkkosivu on saavutettavissa, avataan nyt."
        Start-Process $webAppUrl
    } else {
        Write-Host "Verkkosivua ei voitu avata, palvelin vastasi tilakoodilla: $($response.StatusCode)"
    }
} catch {
    Write-Host "Virhe tarkistettaessa verkkosivua: $_"
}