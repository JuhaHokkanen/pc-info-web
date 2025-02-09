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
$gpuMemoryGB = if ($gpu[0].AdapterRAM) {[math]::Round($gpu[0].AdapterRAM / 1GB, 2)} else {0}

# Luo HTML-sisältö
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Computer Information</title>
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
        <tr><th>GPU Memory (GB)</th><td>$gpuMemoryGB</td></tr>
    </table>
</body>
</html>
"@

# Varmista, että C:\Temp hakemisto on olemassa tai käytä muuta polkua
$htmlPath = "C:\Temp\ComputerInfo.html"
if (-not (Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\" -Name "Temp" -ItemType Directory
}

# Tallenna HTML tiedostoon
$htmlContent | Out-File -FilePath $htmlPath

Write-Host "HTML-tiedosto tallennettu polkuun $htmlPath"

# GitHub-repositorio
$localRepoPath = "C:\Users\home\OneDrive\Documents\scriptit\Uusi PC INFO"  # Paikallinen polku GitHub-repositoriosi
$githubRepoUrl = "https://github.com/JuhaHokkanen/pc-info-web.git"  # GitHub-repositoryn URL

# Kopioi HTML-tiedosto GitHub-repositoriosi kansioon
Copy-Item $htmlPath -Destination "$localRepoPath\index.html"
Write-Host "ComputerInfo.html kopioitu GitHub-repositorioosi."

# Siirry paikalliseen GitHub-repositorioosi
Set-Location -Path $localRepoPath

# Lisää vain index.html tiedosto versionhallintaan
git add index.html
git commit -m "Päivitetty ComputerInfo.html"
git push origin main

Write-Host "Tietokoneen tiedot päivitetty GitHubiin."

# GitHubin päivitys käynnistää automaattisesti Azure Static Web App -sovelluksen päivityksen.
