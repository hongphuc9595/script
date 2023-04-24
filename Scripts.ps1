# Function cài đặt Chocolatey
function Install-Chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Function cài đặt các ứng dụng cơ bản từ Chocolatey
function Install-BasicApps {
    choco install googlechrome firefox microsoft-teams adobereader teamviewer ultraviewer.install unikey viber zalo winrar --force -y --allow-empty-checksums --ignorechecksum
}

# Function cài đặt Microsoft 365 Apps for Business
function Install-Office365 {
    choco install --force -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Exclude=Groove,Lync,OneNote,OneDrive,Access"

}

# Function cài đặt Office 2021
function Install-Office2021 {
    choco install -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Product:ProPlus2021Volume /Exclude=Groove,Lync,OneNote,OneDrive,Access"
}

# Function cài đặt Ultraviewer từ Winget
function Install-Ultraviewer {
    winget install ultraviewer
}

# Function Activate Office
function Activate-Office {
    irm https://massgrave.dev/get | iex
}

# Tạo menu lựa chọn
do {
    Write-Host "======== Menu Lựa Chọn ========"
    Write-Host "1. Cài đặt Chocolatey"
    Write-Host "2. Cài đặt ứng dụng cơ bản"
    Write-Host "3. Cài đặt Microsoft 365 Apps for Business"
    Write-Host "4. Cài đặt Office 2021"
    Write-Host "5. Cài đặt Ultraviewer từ Winget"
    Write-Host "6. Activate Office"
    Write-Host "Q. Thoát chương trình"
    $choice = Read-Host "Nhập lựa chọn của bạn"
    switch ($choice) {
        '1' {
            Install-Chocolatey
        }
        '2' {
            Install-BasicApps
        }
        '3' {
            Install-Office365
        }
        '4' {
            Install-Office2021
        }
        '5' {
            Install-Ultraviewer
        }
        '6' {
            Activate-Office
        }
        'Q' {
            # Thoát chương trình
            break
        }
        default {
            # Lựa chọn không hợp lệ
            Write-Host "Lựa chọn không hợp lệ. Vui lòng thử lại."
        }
    }
} while ($choice -ne 'Q' )
