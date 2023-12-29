# Function to Install Chocolatey
function Install-Chocolatey {
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Function to Install Basic Applications using Chocolatey
function Install-BasicApps {
    choco install googlechrome firefox microsoft-teams adobereader teamviewer ultraviewer.install unikey viber zalo winrar --force -y --allow-empty-checksums --ignorechecksum
}

# Function to Install Microsoft 365 Apps for Business
function Install-Office365 {
    choco install --force -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Exclude=Groove,Lync,OneNote,OneDrive,Access"
}

# Function to Install Office 2021
function Install-Office2021 {
    choco install -y --allow-empty-checksums --ignorechecksum microsoft-office-deployment --params="/Language:en-us /32bit /Product:ProPlus2021Volume /Exclude=Groove,Lync,OneNote,OneDrive,Access"
}

# Function to Activate Office
function Activate-Office {
    irm https://massgrave.dev/get | iex
}

# Function to Reset IDM (Internet Download Manager)
function Reset-IDM {
    iex (irm is.gd/idm_reset)
}

# Function to Install Basic Applications using Winget
function Install-BasicAppsWithWinget {
    winget install --id=Google.Chrome -e
    winget install --id=Mozilla.Firefox -e
    winget install --id=TeamViewer.TeamViewer -e
    winget install --id=UniKey.UniKey -e
    winget install --id=RARLab.WinRAR -e
    winget install --id=Adobe.Acrobat.Reader.64-bit -e
    winget install --id=Microsoft.Teams -e
    winget install --id=VNGCorp.Zalo -e
    winget install --id=Viber.Viber -e
}

# Create a menu for user selection
do {
    Write-Host "======== Menu Options ========"
    Write-Host "1. Install Chocolatey"
    Write-Host "2. Install Basic Applications (Chocolatey)"
    Write-Host "3. Install Microsoft 365 Apps for Business"
    Write-Host "4. Install Office 2021"
    Write-Host "5. Activate Office"
    Write-Host "6. Reset IDM (Internet Download Manager)"
    Write-Host "7. Install Basic Applications (Winget)"
    Write-Host "Q. Exit the program"
    $choice = Read-Host "Enter your choice"
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
            Activate-Office
        }
        '6' {
            Reset-IDM
        }
        '7' {
            Install-BasicAppsWithWinget
        }
        'Q' {
            # Exit the program
            break
        }
        default {
            # Invalid choice
            Write-Host "Invalid choice. Please try again."
        }
    }
} while ($choice -ne 'Q')
