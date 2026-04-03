# Hàm cài đặt ứng dụng cần thiết qua Winget
function Install-Apps {
    Write-Host "Đang cài đặt các ứng dụng cần thiết..." -ForegroundColor Cyan

    $apps = @(
        @{ Name = "Google Chrome";           Id = "Google.Chrome" }
        @{ Name = "Mozilla Firefox";         Id = "Mozilla.Firefox" }
        @{ Name = "WinRAR";                  Id = "RARLab.WinRAR" }
        @{ Name = "7-Zip";                   Id = "7zip.7zip" }
        @{ Name = "Zalo";                    Id = "VNG.ZaloPC" }
        @{ Name = "Viber";                   Id = "Viber.Viber" }
        @{ Name = "VC++ Redistributable";    Id = "Microsoft.VCRedist.2015+.x64" }
        @{ Name = ".NET Desktop Runtime 8";  Id = "Microsoft.DotNet.DesktopRuntime.8" }
        @{ Name = "UniKey";                  Id = "UniKey.UniKey" }
        @{ Name = "UltraViewer";             Id = "DucFabulous.UltraViewer" }
        @{ Name = "TeamViewer";              Id = "TeamViewer.TeamViewer" }
    )

    foreach ($app in $apps) {
        Write-Host "  → Đang cài: $($app.Name)..." -ForegroundColor Yellow
        winget install --exact --silent $app.Id --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✔ $($app.Name) đã cài thành công." -ForegroundColor Green
        } else {
            Write-Host "    ✘ $($app.Name) cài thất bại hoặc đã có sẵn." -ForegroundColor Red
        }
    }

    Write-Host "`n✅ Hoàn tất cài đặt ứng dụng!" -ForegroundColor Green
}

# Hàm cài đặt Office 2024 LTSC tự động qua ODT
function Install-Office {
    Write-Host "`n📦 Bắt đầu cài đặt Microsoft Office 2024 LTSC..." -ForegroundColor Cyan

    # Kiểm tra quyền Admin
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "  ✘ Cần chạy với quyền Administrator." -ForegroundColor Red
        return
    }

    # Tạo thư mục làm việc
    $workDir = "$env:TEMP\ODT_Office2024"
    if (-not (Test-Path $workDir)) { New-Item -ItemType Directory -Path $workDir -Force | Out-Null }

    try {
        # Bước 1: Cài ODT qua winget (luôn lấy bản mới nhất)
        Write-Host "  → [1/4] Đang cài Office Deployment Tool qua Winget..." -ForegroundColor Yellow
        winget install --exact --silent Microsoft.OfficeDeploymentTool --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) { throw "Không thể cài Office Deployment Tool qua winget." }

        # Tìm setup.exe từ ODT vừa cài
        $odtInstallPath = "${env:ProgramFiles}\Microsoft Office\root\ODT"
        $odtAltPath     = "${env:ProgramFiles(x86)}\Microsoft Office\root\ODT"
        $setupPath = if (Test-Path "$odtInstallPath\setup.exe") { "$odtInstallPath\setup.exe" }
                     elseif (Test-Path "$odtAltPath\setup.exe") { "$odtAltPath\setup.exe" }
                     else {
                         # Fallback: tìm setup.exe trong toàn bộ Program Files
                         Get-ChildItem "C:\Program Files*" -Recurse -Filter "setup.exe" -ErrorAction SilentlyContinue |
                             Where-Object { $_.DirectoryName -like "*Office*" } |
                             Select-Object -First 1 -ExpandProperty FullName
                     }

        if (-not $setupPath) { throw "Không tìm thấy setup.exe sau khi cài ODT." }
        Write-Host "    ✔ Đã cài ODT. setup.exe: $setupPath" -ForegroundColor Green

        # Bước 2: Tạo thư mục làm việc (bỏ bước giải nén thủ công)
        Write-Host "  → [2/4] Đang chuẩn bị thư mục làm việc..." -ForegroundColor Yellow
        Write-Host "    ✔ Sẵn sàng." -ForegroundColor Green

        # Bước 3: Tạo file config.xml cho Office 2024 LTSC Full
        Write-Host "  → [3/4] Đang tạo cấu hình cài đặt..." -ForegroundColor Yellow
        $configXml = @"
<Configuration ID="Office2024-LTSC-Full">
  <Add OfficeClientEdition="64" Channel="PerpetualVL2024">
    <Product ID="ProPlus2024Volume" PIDKEY="XJ2XN-FW8RK-P4HMP-DKDBV-GCVGB">
      <Language ID="vi-vn" />
      <Language ID="en-us" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Publisher" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Groove" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Property Name="DeviceBasedLicensing" Value="0" />
  <Property Name="SCLCacheOverride" Value="0" />
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <AppSettings>
    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />
    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />
    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />
  </AppSettings>
  <Display Level="None" AcceptEULA="TRUE" />
  <Logging Level="Standard" Path="%TEMP%" />
</Configuration>
"@
        $configPath = "$workDir\config.xml"
        $configXml | Out-File -FilePath $configPath -Encoding UTF8 -Force
        Write-Host "    ✔ Đã tạo config.xml (Office 2024 LTSC, 64-bit, Tiếng Việt + Tiếng Anh)." -ForegroundColor Green

        # Bước 4: Tải và cài Office
        Write-Host "  → [4/4] Đang tải và cài Office 2024 (~3GB, có thể mất 15-30 phút)..." -ForegroundColor Yellow
        Write-Host "         Vui lòng không tắt máy hoặc đóng cửa sổ này!" -ForegroundColor DarkYellow
        Start-Process -FilePath $setupPath -ArgumentList "/configure `"$configPath`"" -Wait -ErrorAction Stop
        Write-Host "    ✔ Đã cài đặt Office 2024 LTSC thành công!" -ForegroundColor Green

        # Dọn dẹp file tạm
        Remove-Item -Path $workDir -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "`n✅ Office 2024 LTSC đã được cài đặt!" -ForegroundColor Green
        Write-Host "   Gồm: Word, Excel, PowerPoint, Outlook, OneNote" -ForegroundColor White
        Write-Host "   Dùng option [3] Kích hoạt Office để active sau khi cài." -ForegroundColor Cyan

    } catch {
        Write-Host "  ✘ Lỗi trong quá trình cài Office: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "    Vui lòng kiểm tra kết nối internet và thử lại." -ForegroundColor Yellow
    }
}

# Hàm kích hoạt Office
function Activate-Office {
    $script = irm https://get.activated.win
    if ($script) {
        iex $script
        Write-Host "Office đã được kích hoạt thành công." -ForegroundColor Green
    } else {
        Write-Host "Không thể tải script kích hoạt Office." -ForegroundColor Red
    }
}

# Hàm thực thi Backup Driver
function Backup-Driver {
    iex (irm https://raw.githubusercontent.com/hongphuc9595/script/refs/heads/master/run%20backup%20driver)
    Write-Host "Backup Driver đã được thực thi." -ForegroundColor Green
}

# Hàm cập nhật Windows
function Update-Windows {
    Write-Host "Đang kiểm tra cập nhật Windows..." -ForegroundColor Cyan

    # Kiểm tra quyền Admin
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "  ✘ Cần chạy với quyền Administrator để cập nhật Windows." -ForegroundColor Red
        return
    }

    # Kiểm tra kết nối internet
    try {
        $connected = Test-Connection -ComputerName "www.microsoft.com" -Count 1 -Quiet -ErrorAction Stop
        if (-not $connected) {
            Write-Host "  ✘ Không có kết nối internet. Vui lòng kiểm tra mạng và thử lại." -ForegroundColor Red
            return
        }
    } catch {
        Write-Host "  ✘ Không có kết nối internet. Vui lòng kiểm tra mạng và thử lại." -ForegroundColor Red
        return
    }
    Write-Host "  ✔ Kết nối internet OK." -ForegroundColor Green

    try {
        # Cài đặt module PSWindowsUpdate nếu chưa có
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-Host "  → Đang cài đặt module PSWindowsUpdate..." -ForegroundColor Yellow
            Install-Module PSWindowsUpdate -Force -SkipPublisherCheck -Scope CurrentUser -ErrorAction Stop
            Write-Host "  ✔ Module PSWindowsUpdate đã cài thành công." -ForegroundColor Green
        }

        Import-Module PSWindowsUpdate -ErrorAction Stop

        # Kiểm tra các bản cập nhật có sẵn
        Write-Host "  → Đang tìm các bản cập nhật..." -ForegroundColor Yellow
        $updates = Get-WindowsUpdate -ErrorAction Stop
        $updateCount = ($updates | Measure-Object).Count

        if ($updateCount -eq 0) {
            Write-Host "  ✔ Windows đã được cập nhật mới nhất. Không có bản cập nhật nào." -ForegroundColor Green
            return
        }

        Write-Host "  📦 Tìm thấy $updateCount bản cập nhật:" -ForegroundColor Cyan
        $updates | ForEach-Object {
            Write-Host "    - $($_.Title)" -ForegroundColor White
        }

        # Cài đặt các bản cập nhật
        Write-Host "`n  → Đang cài đặt $updateCount bản cập nhật..." -ForegroundColor Yellow
        Install-WindowsUpdate -AcceptAll -AutoReboot:$false -ErrorAction Stop
        Write-Host "  ✔ Đã cài đặt thành công $updateCount bản cập nhật Windows." -ForegroundColor Green

        # Hỏi người dùng có muốn khởi động lại không
        $rebootChoice = Read-Host "`n  Bạn có muốn khởi động lại máy tính ngay bây giờ? (Y/N)"
        if ($rebootChoice -eq 'Y' -or $rebootChoice -eq 'y') {
            Write-Host "  → Đang khởi động lại máy tính..." -ForegroundColor Yellow
            Restart-Computer -Force
        } else {
            Write-Host "  ℹ Bạn nên khởi động lại máy tính sớm để hoàn tất cập nhật." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ✘ Lỗi khi cập nhật Windows: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Hàm dọn dẹp ổ đĩa
function Clean-Disk {
    Write-Host "`n🧹 Đang dọn dẹp ổ đĩa..." -ForegroundColor Cyan

    # Đo dung lượng trống trước khi dọn
    $driveBefore = (Get-PSDrive C).Free
    $errors = @()

    # 1. Dọn Temp hệ thống
    Write-Host "  → Dọn thư mục Temp hệ thống..." -ForegroundColor Yellow
    try {
        $sizeBefore = (Get-ChildItem "$env:TEMP" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        $sizeAfter = (Get-ChildItem "$env:TEMP" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $freed = [math]::Round(($sizeBefore - $sizeAfter) / 1MB, 2)
        Write-Host "    ✔ Đã giải phóng ~$freed MB từ Temp hệ thống." -ForegroundColor Green
    } catch { $errors += "Temp hệ thống: $($_.Exception.Message)" }

    # 2. Dọn Temp người dùng (LocalAppData)
    Write-Host "  → Dọn thư mục Temp người dùng..." -ForegroundColor Yellow
    try {
        $localTemp = "$env:LOCALAPPDATA\Temp"
        $sizeBefore = (Get-ChildItem $localTemp -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item "$localTemp\*" -Recurse -Force -ErrorAction SilentlyContinue
        $sizeAfter = (Get-ChildItem $localTemp -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $freed = [math]::Round(($sizeBefore - $sizeAfter) / 1MB, 2)
        Write-Host "    ✔ Đã giải phóng ~$freed MB từ Temp người dùng." -ForegroundColor Green
    } catch { $errors += "Temp người dùng: $($_.Exception.Message)" }

    # 3. Dọn Prefetch
    Write-Host "  → Dọn Prefetch..." -ForegroundColor Yellow
    try {
        $sizeBefore = (Get-ChildItem "C:\Windows\Prefetch" -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
        $sizeAfter = (Get-ChildItem "C:\Windows\Prefetch" -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        $freed = [math]::Round(($sizeBefore - $sizeAfter) / 1MB, 2)
        Write-Host "    ✔ Đã giải phóng ~$freed MB từ Prefetch." -ForegroundColor Green
    } catch { $errors += "Prefetch: $($_.Exception.Message)" }

    # 4. Dọn Windows Update cache
    Write-Host "  → Dọn Windows Update cache..." -ForegroundColor Yellow
    try {
        Stop-Service -Name wuauserv -Force -ErrorAction Stop
        $sizeBefore = (Get-ChildItem "C:\Windows\SoftwareDistribution\Download" -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction Stop
        $freed = [math]::Round($sizeBefore / 1MB, 2)
        Write-Host "    ✔ Đã giải phóng ~$freed MB từ Windows Update cache." -ForegroundColor Green
    } catch { $errors += "Windows Update cache: $($_.Exception.Message)" }

    # 5. Xóa DNS cache
    Write-Host "  → Xóa DNS cache..." -ForegroundColor Yellow
    try {
        Clear-DnsClientCache -ErrorAction Stop
        Write-Host "    ✔ Đã xóa DNS cache." -ForegroundColor Green
    } catch { $errors += "DNS cache: $($_.Exception.Message)" }

    # 6. Dọn Recycle Bin
    Write-Host "  → Dọn Recycle Bin..." -ForegroundColor Yellow
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "    ✔ Đã dọn sạch Recycle Bin." -ForegroundColor Green
    } catch { $errors += "Recycle Bin: $($_.Exception.Message)" }

    # 7. Disk Cleanup
    Write-Host "  → Chạy Disk Cleanup..." -ForegroundColor Yellow
    cleanmgr /sagerun:1
    Write-Host "    ✔ Đã chạy Disk Cleanup." -ForegroundColor Green

    # Báo cáo tổng kết
    $driveAfter = (Get-PSDrive C).Free
    $totalFreed = [math]::Round(($driveAfter - $driveBefore) / 1MB, 2)
    Write-Host "`n✅ Hoàn tất dọn dẹp! Tổng dung lượng đã giải phóng: ~$totalFreed MB" -ForegroundColor Green

    if ($errors.Count -gt 0) {
        Write-Host "`n⚠ Một số lỗi xảy ra:" -ForegroundColor Yellow
        $errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
    }
}

# Hàm tối ưu hiệu suất hệ thống
function Optimize-Performance {
    Write-Host "`n🚀 Đang tối ưu hiệu suất hệ thống..." -ForegroundColor Cyan

    # 1. Bật High Performance power plan
    Write-Host "  → Bật chế độ High Performance..." -ForegroundColor Yellow
    powercfg -setactive SCHEME_MIN
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✔ Đã bật High Performance power plan." -ForegroundColor Green
    } else {
        Write-Host "    ✘ Không thể bật High Performance power plan." -ForegroundColor Red
    }

    # 2. Tắt Hibernate
    Write-Host "  → Tắt Hibernate..." -ForegroundColor Yellow
    powercfg -h off
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✔ Đã tắt Hibernate." -ForegroundColor Green
    } else {
        Write-Host "    ✘ Không thể tắt Hibernate." -ForegroundColor Red
    }

    # 3. Tắt Visual Effects (chuyển sang Adjust for best performance)
    Write-Host "  → Tắt Visual Effects..." -ForegroundColor Yellow
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Value 2 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "    ✔ Đã tắt Visual Effects (Best Performance)." -ForegroundColor Green

    # 4. Tắt Transparency
    Write-Host "  → Tắt Transparency..." -ForegroundColor Yellow
    $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (-not (Test-Path $themePath)) {
        New-Item -Path $themePath -Force | Out-Null
    }
    Set-ItemProperty -Path $themePath -Name "EnableTransparency" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Write-Host "    ✔ Đã tắt Transparency." -ForegroundColor Green

    Write-Host "`n✅ Hoàn tất tối ưu hiệu suất hệ thống!" -ForegroundColor Green
}

# Menu cho phép người dùng lựa chọn
$menuActions = @{
    '1' = { Install-Apps }
    '2' = { Install-Office }
    '3' = { Activate-Office }
    '4' = { Backup-Driver }
    '5' = { Update-Windows }
    '6' = { Clean-Disk }
    '7' = { Optimize-Performance }
}

do {
    Write-Host "======== Menu Options ========"
    Write-Host "1. Cài đặt ứng dụng cần thiết (Winget)"
    Write-Host "2. Cài đặt Office 2024 LTSC (tự động)"
    Write-Host "3. Kích hoạt Office"
    Write-Host "4. Backup Driver"
    Write-Host "5. Cập nhật Windows"
    Write-Host "6. Dọn dẹp ổ đĩa"
    Write-Host "7. Tối ưu hiệu suất hệ thống"
    Write-Host "Q. Thoát chương trình"
    $choice = Read-Host "Nhập lựa chọn của bạn"

    if ($choice -eq 'Q') { break }

    if ($menuActions.ContainsKey($choice)) {
        & $menuActions[$choice]
    } else {
        Write-Host "Lựa chọn không hợp lệ. Vui lòng thử lại." -ForegroundColor Red
    }

} while ($true)
