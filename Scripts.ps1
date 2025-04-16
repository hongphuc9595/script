# Danh sách các ứng dụng cần cài đặt
$chocoApps = @(
    'googlechrome', 
    'firefox', 
    'microsoft-teams', 
    'adobereader', 
    'teamviewer', 
    'ultraviewer.install', 
    'unikey', 
    'viber', 
    'zalo', 
    'winrar', # Đã sửa lỗi thiếu dấu phẩy ở đây
    'vcredist-all'
    'Powertoys'
)

# Hàm cài đặt Chocolatey
function Install-Chocolatey {
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Host "Chocolatey đã được cài đặt thành công." -ForegroundColor Green
    } else {
        Write-Host "Chocolatey đã được cài đặt trước đó." -ForegroundColor Yellow
    }
}

# Hàm cài đặt các ứng dụng cơ bản bằng Chocolatey
function Install-BasicApps {
    foreach ($app in $chocoApps) {
        try {
            choco install $app --force -y --allow-empty-checksums --ignorechecksum
            Write-Host "Đã cài đặt thành công $app." -ForegroundColor Green
        } catch {
            Write-Host "Không thể cài đặt $app. Lỗi: $_" -ForegroundColor Red
        }
    }
}

# Hàm cài đặt Office 2021
function Install-Office2021 {
    choco install -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Product:ProPlus2021Volume /RemoveMSI /Exclude=Groove,Lync,OneNote,OneDrive,Access"
    Write-Host "Office 2021 đã được cài đặt thành công." -ForegroundColor Green
}

# Hàm cài đặt Office 2024
function Install-Office2024 {
    choco install -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Product:ProPlus2024Retail /RemoveMSI /Exclude=Groove,Lync,OneNote,OneDrive,Access"
    Write-Host "Office 2024 đã được cài đặt thành công." -ForegroundColor Green
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

# Hàm reset IDM
function Reset-IDM {
    $script = irm is.gd/idm_reset
    if ($script) {
        iex $script
        Write-Host "IDM đã được reset thành công." -ForegroundColor Green
    } else {
        Write-Host "Không thể tải script reset IDM." -ForegroundColor Red
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
    Install-Module PSWindowsUpdate -Force -SkipPublisherCheck
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate
    Install-WindowsUpdate -AcceptAll -AutoReboot:$false
    Write-Host "Đã cài đặt các bản cập nhật Windows." -ForegroundColor Green
}

# Hàm dọn dẹp ổ đĩa
function Clean-Disk {
    Write-Host "Đang dọn dẹp ổ đĩa..." -ForegroundColor Cyan
    # Dọn Temp và Prefetch
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    # Dọn Disk Cleanup
    cleanmgr /sagerun:1
    Write-Host "Đã dọn dẹp xong ổ đĩa." -ForegroundColor Green
}

# Hàm kiểm tra và cập nhật các ứng dụng đã cài đặt
function Update-Apps {
    Write-Host "Đang cập nhật các ứng dụng..." -ForegroundColor Cyan
    choco upgrade all -y
    Write-Host "Đã cập nhật tất cả ứng dụng." -ForegroundColor Green
}

# Menu cho phép người dùng lựa chọn
$menuActions = @{
    '1' = { Install-Chocolatey }
    '2' = { Install-BasicApps }
    '3' = { Install-Office2021 }
    '4' = { Install-Office2024 }
    '5' = { Activate-Office }
    '6' = { Reset-IDM }
    '7' = { Backup-Driver }
    '8' = { Update-Windows }
    '9' = { Clean-Disk }
    '10' = { Update-Apps }
}

do {
    Write-Host "======== Menu Options ========"
    Write-Host "1. Cài đặt Chocolatey"
    Write-Host "2. Cài đặt ứng dụng cơ bản (Chocolatey)"
    Write-Host "3. Cài đặt Office 2021"
    Write-Host "4. Cài đặt Office 2024"
    Write-Host "5. Kích hoạt Office"
    Write-Host "6. Reset IDM (Internet Download Manager)"
    Write-Host "7. Backup Driver"
    Write-Host "8. Cập nhật Windows"
    Write-Host "9. Dọn dẹp ổ đĩa"
    Write-Host "10. Cập nhật tất cả ứng dụng"
    Write-Host "Q. Thoát chương trình"
    $choice = Read-Host "Nhập lựa chọn của bạn"

    if ($choice -eq 'Q') { break }

    if ($menuActions.ContainsKey($choice)) {
        & $menuActions[$choice]
    } else {
        Write-Host "Lựa chọn không hợp lệ. Vui lòng thử lại." -ForegroundColor Red
    }

} while ($true)
