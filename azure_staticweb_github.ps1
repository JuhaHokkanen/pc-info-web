# Juha Hokkanen 9.2.2025
# PC info scripti joka kerää tietoja tietokoneesta ja lähettää tiedot Githubin kautta Azuren static sivulle.

# Kerää järjestelmätiedot
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
$userFolderSize = (Get-ChildItem -Path $currentUserPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
$userFolderSizeGB = [math]::Round($userFolderSize / 1GB, 2)

# Hanki nykyinen päivämäärä ja kellonaika
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Luo HTML-sisältö
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Computer Information</title>
<style>
        body {
            font-family: Arial, sans-serif;
        }
        h1,h2,p {
        text-align: center;
        }
        table {
            margin: 0 auto;
            width: 90%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
        footer {
            margin-top: 20px;
            font-size: 0.8em;
            text-align: center;
        }
    </style>
</head>
<body>
    <h1>Computer Information</h1>
    <table border="1">
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
     </table>
    <h2>Current User Folder Size</h2>
    <table border="1">
        <tr><th>User</th><th>Size (GB)</th></tr>
        <tr><td>$env:USERNAME</td><td>$userFolderSizeGB</td></tr>
    </table>
    <h2>Data Retrieved At</h2>
    <p>$currentDateTime</p>
    <footer>
        <p>&copy; 2025 Juha Hokkanen. All rights reserved.</p>
    </footer>
</body>
</html>
"@

# Varmista, että C:\Temp hakemisto on olemassa
$htmlPath = "C:\Temp\ComputerInfo.html"
if (-not (Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory
}

# Tallenna HTML tiedostoon
$htmlContent | Out-File -FilePath $htmlPath

Write-Host "HTML-tiedosto tallennettu polkuun $htmlPath"

# GitHub-repositorio
$localRepoPath = "C:\Users\home\OneDrive\Documents\scriptit\Uusi PC INFO"  # Paikallinen polku GitHub-repositoriosi

# Kopioi HTML-tiedosto GitHub-repositoriosi kansioon
Copy-Item $htmlPath -Destination "$localRepoPath\index.html"
Write-Host "ComputerInfo.html kopioitu GitHub-repositorioosi."

# Siirry paikalliseen GitHub-repositorioosi
Set-Location -Path $localRepoPath

# Lisää index.html tiedosto versionhallintaan ja tee commit
git add index.html
git commit -m "Päivitetty ComputerInfo.html $currentDateTime"

# Puske muutokset GitHubiin
git push origin main

Write-Host "Tietokoneen tiedot päivitetty GitHubiin."

# Avataan sivusto selaimessa
$webAppUrl = "https://lively-tree-073188d03.4.azurestaticapps.net/"
Start-Process $webAppUrl