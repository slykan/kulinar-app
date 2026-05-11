# Kulinar.app Web Deploy Script
# Run from PowerShell: .\deploy_web.ps1

$ftpHost    = "ftp.kulinar.app"
$ftpUser    = "web@kulinar.app"
$ftpPass    = "YOUR_FTP_PASSWORD"
$ftpBase    = "ftp://$ftpHost/public_html"
$localBase  = "$PSScriptRoot\build\web"
$privacySource = "$PSScriptRoot\web\privacy.html"
$privacyTarget = "$localBase\privacy.html"

function Upload-File($localPath, $remotePath) {
    $uri = [System.Uri]$remotePath
    $request = [System.Net.FtpWebRequest]::Create($uri)
    $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $request.Credentials = [System.Net.NetworkCredential]::new($ftpUser, $ftpPass)
    $request.UseBinary = $true
    $request.UsePassive = $true
    $request.KeepAlive = $false
    $content = [System.IO.File]::ReadAllBytes($localPath)
    $request.ContentLength = $content.Length
    $stream = $request.GetRequestStream()
    $stream.Write($content, 0, $content.Length)
    $stream.Close()
    try { $request.GetResponse().Close() } catch {}
}

function Upload-Dir($localDir, $remoteDir) {
    Get-ChildItem -Path $localDir | ForEach-Object {
        $remotePath = "$remoteDir/$($_.Name)"
        if ($_.PSIsContainer) {
            Upload-Dir $_.FullName $remotePath
        } else {
            Write-Host "Uploading $($_.Name)..."
            try {
                Upload-File $_.FullName $remotePath
            } catch {
                Write-Host "  SKIP: $($_.Name) - $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "Starting upload to $ftpBase ..." -ForegroundColor Cyan
if (Test-Path $privacySource) {
    if (!(Test-Path $localBase)) {
        New-Item -ItemType Directory -Force -Path $localBase | Out-Null
    }
    Copy-Item -Path $privacySource -Destination $privacyTarget -Force
    Write-Host "Prepared privacy.html for upload." -ForegroundColor Cyan
}
Upload-Dir $localBase $ftpBase
Write-Host "Done!" -ForegroundColor Green
