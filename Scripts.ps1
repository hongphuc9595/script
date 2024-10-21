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
    'winrar'
    'vcredist-all'
)

$wingetApps = @(
    'Google.Chrome', 
    'Mozilla.Firefox', 
    'TeamViewer.TeamViewer', 
    'UniKey.UniKey', 
    'RARLab.WinRAR', 
    'Adobe.Acrobat.Reader.64-bit', 
    'Microsoft.Teams', 
    'VNGCorp.Zalo', 
    'Viber.Viber'
)

# Hàm cài đặt Chocolatey
function Install-Chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Write-Host "Chocolatey đã được cài đặt thành công."
}

# Hàm cài đặt các ứng dụng cơ bản bằng Chocolatey
function Install-BasicApps {
    foreach ($app in $chocoApps) {
        try {
            choco install $app --force -y --allow-empty-checksums --ignorechecksum
            Write-Host "Đã cài đặt thành công $app."
        } catch {
            Write-Host "Không thể cài đặt $app. Lỗi: $_"
        }
    }
}

# Hàm cài đặt các ứng dụng cơ bản bằng Winget
function Install-BasicAppsWithWinget {
    foreach ($app in $wingetApps) {
        try {
            winget install --id=$app -e
            Write-Host "Đã cài đặt thành công $app."
        } catch {
            Write-Host "Không thể cài đặt $app. Lỗi: $_"
        }
    }
}

# Hàm cài đặt Microsoft 365 Apps for Business
function Install-Office365 {
    choco install --force -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Exclude=Groove,Lync,OneNote,OneDrive,Access"
    Write-Host "Microsoft 365 Apps for Business đã được cài đặt thành công."
}

# Hàm cài đặt Office 2021
function Install-Office2021 {
    choco install -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Product:ProPlus2021Volume /Exclude=Groove,Lync,OneNote,OneDrive,Access"
    Write-Host "Office 2021 đã được cài đặt thành công."
}

# Hàm kích hoạt Office
function Activate-Office {
    $script = irm https://massgrave.dev/get
    if ($script) {
        iex $script
        Write-Host "Office đã được kích hoạt thành công."
    } else {
        Write-Host "Không thể tải script kích hoạt Office."
    }
}

# Hàm reset IDM
function Reset-IDM {
    $script = irm is.gd/idm_reset
    if ($script) {
        iex $script
        Write-Host "IDM đã được reset thành công."
    } else {
        Write-Host "Không thể tải script reset IDM."
    }
}

# Menu cho phép người dùng lựa chọn
$menuActions = @{
    '1' = { Install-Chocolatey }
    '2' = { Install-BasicApps }
    '3' = { Install-Office365 }
    '4' = { Install-Office2021 }
    '5' = { Activate-Office }
    '6' = { Reset-IDM }
    '7' = { Install-BasicAppsWithWinget }
}

do {
    Write-Host "======== Menu Options ========"
    Write-Host "1. Cài đặt Chocolatey"
    Write-Host "2. Cài đặt ứng dụng cơ bản (Chocolatey)"
    Write-Host "3. Cài đặt Microsoft 365 Apps for Business"
    Write-Host "4. Cài đặt Office 2021"
    Write-Host "5. Kích hoạt Office"
    Write-Host "6. Reset IDM (Internet Download Manager)"
    Write-Host "7. Cài đặt ứng dụng cơ bản (Winget)"
    Write-Host "Q. Thoát chương trình"
    $choice = Read-Host "Nhập lựa chọn của bạn"

    if ($choice -eq 'Q') { break }

    if ($menuActions.ContainsKey($choice)) {
        & $menuActions[$choice]
    } else {
        Write-Host "Lựa chọn không hợp lệ. Vui lòng thử lại."
    }

} while ($true)
