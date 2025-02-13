@echo off
title Backup-Restore v1.8
mode con: cols=54 lines=16

setlocal enabledelayedexpansion
:menu

setlocal enabledelayedexpansion

:: Lay thon tin WMIC
for /f "skip=1 tokens=*" %%A in ('wmic bios get serialnumber 2^>nul') do if not defined SERVICE_TAG set "SERVICE_TAG=%%A"
for /f "skip=1 tokens=*" %%A in ('wmic computersystem get manufacturer 2^>nul') do if not defined BRAND set "BRAND=%%A"
for /f "skip=1 tokens=*" %%A in ('wmic computersystem get model 2^>nul') do if not defined MODEL set "MODEL=%%A"
for /f "tokens=2 delims==" %%A in ('wmic cpu get name /value') do set CPU=%%A
for /f "tokens=2 delims==" %%A in ('wmic memorychip get capacity /value') do set RAM=%%A
for /f "tokens=2 delims==" %%A in ('wmic memorychip get manufacturer /value') do set RAM_MANUFACTURER=%%A
for /f "tokens=2 delims==" %%A in ('wmic memorychip get speed /value') do set RAM_SPEED=%%A
for /f "tokens=2 delims==" %%A in ('wmic memorychip get memorytype /value') do set RAM_TYPE=%%A

:: Xoa khoang trang du thua
set "SERVICE_TAG=%SERVICE_TAG: =%"
set "BRAND=%BRAND: =%"
set "MODEL=%MODEL: =%"

:: Kiem tra neu Service Tag khong lay duoc
if not defined SERVICE_TAG (
    echo [Loi] Khong the lay Service Tag. Hay chay bang quyen Admin.
    pause
    exit /b
)


:: Menu lua chon
:menu
cls
echo ======================================================
echo      Backup + Restore Driver - Data - Wifi Utility
echo               -----Minh Hai Computer-----
echo ======================================================
echo  1. Hien thi thong tin may
echo  2. Tra cuu thong tin tu web hang
echo  3. Sao luu Driver
echo  4. Cai dat Driver da sao luu
echo  5. Sao luu du lieu (Desktop, Download, Documents)
echo  6. Doi duong dan mac dinh cua Download, Documents
echo  7. Xem va xuat mat khau WiFi da ket noi
echo  8. Thoat
echo ======================================================
set /p "choice=Nhap lua chon cua ban (1-7): "

if "%choice%"=="1" goto show_info
if "%choice%"=="2" goto open_warranty
if "%choice%"=="3" goto backup
if "%choice%"=="4" goto restore
if "%choice%"=="5" goto backup_data
if "%choice%"=="6" goto change_default_paths
if "%choice%"=="7" goto export_wifi_passwords
if "%choice%"=="8" goto end
echo Lua chon khong hop le. Vui long thu lai.
pause
goto menu


:: Sao luu du lieu
:backup_data
cls
echo ======================================================
echo                     Sao luu du lieu
echo               -----Minh Hai Computer-----
echo ======================================================
set /p O_SAO_LUU=Nhap ky tu o dia dich (VD: D, E, F): 
if not exist %O_SAO_LUU%:\ (
    echo O dia khong ton tai. Vui long nhap lai.
    pause
    goto backup_data
)
set THU_MUC_SAO_LUU=%O_SAO_LUU%:\SaoLuu

:: Hien thi lua chon
echo.
echo Chon thu muc can sao luu:
echo 1. Desktop
echo 2. Documents
echo 3. Downloads
echo 4. Tat ca (Desktop, Documents, Downloads)
set /p lua_chon=Nhap lua chon (1/2/3/4): 

if "%lua_chon%"=="1" set THU_MUC_GOC=%USERPROFILE%\Desktop
if "%lua_chon%"=="2" set THU_MUC_GOC=%USERPROFILE%\Documents
if "%lua_chon%"=="3" set THU_MUC_GOC=%USERPROFILE%\Downloads
if "%lua_chon%"=="4" set SAO_LUU_TOAN_BO=1

if not defined THU_MUC_GOC if not defined SAO_LUU_TOAN_BO (
    echo Lua chon khong hop le. Vui long thu lai.
    pause
    goto backup_data
)

:: Tao thu muc sao luu
mkdir "%THU_MUC_SAO_LUU%" 2>nul

:: Sao luu
if defined SAO_LUU_TOAN_BO (
    echo Dang sao luu tat ca thu muc...
    xcopy "%USERPROFILE%\Desktop" "%THU_MUC_SAO_LUU%\Desktop" /E /H /C /I /Y
    xcopy "%USERPROFILE%\Documents" "%THU_MUC_SAO_LUU%\Documents" /E /H /C /I /Y
    xcopy "%USERPROFILE%\Downloads" "%THU_MUC_SAO_LUU%\Downloads" /E /H /C /I /Y
) else (
    xcopy "%THU_MUC_GOC%" "%THU_MUC_SAO_LUU%" /E /H /C /I /Y
)

echo Sao luu hoan tat vao thu muc: %THU_MUC_SAO_LUU%
pause
goto menu




:: Hien thi thong tin may
:show_info
cls
echo ======================================================
echo                     THONG TIN MAY
echo ======================================================
echo         Hang san xuat : %BRAND%
echo         Model         : %MODEL%
echo         Service Tag   : %SERVICE_TAG%
echo         CPU           : %CPU%
echo         Dung luong RAM: %RAM%
echo         Hang SX Ram   : %RAM_MANUFACTURER%
echo         RAM Bus       : %RAM_SPEED%
echo         Loai RAM      : %RAM_TYPE%

echo ======================================================
pause
goto menu

:: Mo trang bao hanh hang
:open_warranty
cls
echo Dang kiem tra thong tin...

:: Chuyen thuong hieu ve dang chuan
set "BRAND_LC=%BRAND%"
for %%A in (DELL HP LENOVO ASUS ACER MSI GIGABYTE) do (
    echo %BRAND_LC% | find /I "%%A" >nul && set "BRAND=%%A"
)

:: Bang URL tra cuu bao hang hang
if /I "%BRAND%"=="DELL" set "URL=https://www.dell.com/support/home/en-us/product-support/servicetag/%SERVICE_TAG%"
if /I "%BRAND%"=="HP" set "URL=https://support.hp.com/us-en/checkWarranty?serialNumber=%SERVICE_TAG%"
if /I "%BRAND%"=="LENOVO" set "URL=https://support.lenovo.com/us/en/warrantylookup?serial=%SERVICE_TAG%"
if /I "%BRAND%"=="ASUS" set "URL=https://www.asus.com/support/warranty-status?serial=%SERVICE_TAG%"
if /I "%BRAND%"=="ACER" set "URL=https://www.acer.com/ac/en/US/content/acer-check-product-warranty?sn=%SERVICE_TAG%"
if /I "%BRAND%"=="MSI" set "URL=https://register.msi.com/product/serial/%SERVICE_TAG%/warranty"
if /I "%BRAND%"=="GIGABYTE" set "URL=https://www.gigabyte.com/Support/CheckWarranty?sn=%SERVICE_TAG%"

:: Kiem tra neu URL hop le va mo trinh duyet
if defined URL (
    echo Dang mo trang bao hanh cho %BRAND%...
    start "" "%URL%"
) else (
    echo [Loi] Khong tim thay trang bao hanh cho hang: %BRAND%.
)

pause
goto menu



:backup
echo Tien hanh sao luu Driver cua Windows...
set /p drive="Nhap ky tu o dia noi muon luu backup (vd: D, E): "
set backup_dir=%drive%:\backup_driver

if not exist "%backup_dir%" mkdir "%backup_dir%"
xcopy /s /e /i "C:\Windows\System32\DriverStore\FileRepository\*" "%backup_dir%"

echo Backup driver tu thu muc FileRepository da hoan tat!
goto menu

:restore
echo Chuan bi restore driver...
set /p drive="Nhap ky tu o dia noi chua Driver backup (vd: D, E): "
set backup_dir=%drive%:\backup_driver

pnputil /add-driver "%backup_dir%\*.inf" /subdirs /install

echo Restore driver da hoan tat!
goto menu



:: Thay doi duong dan mac dinh cua Download, Documents
:change_default_paths
cls
echo ======================================================
echo    Thay doi duong dan mac dinh Download, Documents
echo               -----Minh Hai Computer-----
echo ======================================================
echo.
echo Chon kieu thay doi duong dan:
echo 1. Dat duong dan ve thu muc da sao luu trong muc 5
echo 2. Chon o dia tuy y va tu tao thu muc moi
set /p "chon_kieu=Nhap lua chon (1/2): "

if "%chon_kieu%"=="1" (
    set /p "O_MOI=Nhap ky tu o dia da sao luu (VD: D, E, F): "
    if not exist %O_MOI%:\ (
        echo O dia khong ton tai. Vui long nhap lai.
        pause
        goto change_default_paths
    )
    set "NEW_DOWNLOAD=%O_MOI%:\SaoLuu\Downloads"
    set "NEW_DOCUMENTS=%O_MOI%:\SaoLuu\Documents"
) else if "%chon_kieu%"=="2" (
    set /p "O_MOI=Nhap ky tu o dia muon dat lam mac dinh (VD: D, E, F): "
    if not exist %O_MOI%:\ (
        echo O dia khong ton tai. Vui long nhap lai.
        pause
        goto change_default_paths
    )
    set "NEW_DOWNLOAD=%O_MOI%:\Download"
    set "NEW_DOCUMENTS=%O_MOI%:\Documents"
) else (
    echo Lua chon khong hop le. Vui long thu lai.
    pause
    goto change_default_paths
)

:: Tao thu muc moi neu chua ton tai
if not exist "%NEW_DOWNLOAD%" mkdir "%NEW_DOWNLOAD%"
if not exist "%NEW_DOCUMENTS%" mkdir "%NEW_DOCUMENTS%"

:: Di chuyen du lieu neu thu muc ton tai
echo Dang cap nhat du lieu...

if exist "%USERPROFILE%\Downloads\*" (
    echo Di chuyen file tu Downloads...
    move /Y "%USERPROFILE%\Downloads\*" "%NEW_DOWNLOAD%" >nul
)

if exist "%USERPROFILE%\Documents\*" (
    echo Di chuyen file tu Documents...
    move /Y "%USERPROFILE%\Documents\*" "%NEW_DOCUMENTS%" >nul
)

:: Cap nhat Registry de thay doi duong dan mac dinh
echo Dang thay doi duong dan mac dinh...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_EXPAND_SZ /d "%NEW_DOWNLOAD%" /f >nul 2>&1
if %errorlevel% neq 0 (
    echo [Loi] Khong the thay doi duong dan Download. 
    pause
    goto menu
)

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Personal" /t REG_EXPAND_SZ /d "%NEW_DOCUMENTS%" /f >nul 2>&1
if %errorlevel% neq 0 (
    echo [Loi] Khong the thay doi duong dan Documents. 
    pause
    goto menu
)

:: Khoi dong lai Explorer de ap dung thay doi
taskkill /f /im explorer.exe
start explorer.exe

echo Da thay doi duong dan mac dinh thanh:
echo - Download: %NEW_DOWNLOAD%
echo - Documents: %NEW_DOCUMENTS%
echo Toan bo file cu da duoc di chuyen vao thu muc moi!
echo Can khoi dong lai may de ap dung hoan toan!
pause
goto menu

:: Xuat danh sach WiFi va mat khau ra file txt va mo file
:export_wifi_passwords
cls
echo ======================================================
echo             DANH SACH WIFI VA MAT KHAU
echo ======================================================

:: Tao file ket qua
set "OUTPUT_FILE=%CD%\WiFi_Passwords.txt"
echo ========== DANH SACH WIFI VA MAT KHAU ========== > "%OUTPUT_FILE%"
echo. >> "%OUTPUT_FILE%"

:: Lay danh sach tat ca profile WiFi da luu
for /f "tokens=2 delims=:" %%A in ('netsh wlan show profiles ^| findstr "All User Profile"') do (
    set "WIFI_NAME=%%A"
    set "WIFI_NAME=!WIFI_NAME:~1!"

    :: Lay mat khau WiFi
    for /f "tokens=2 delims=:" %%B in ('netsh wlan show profile name^="!WIFI_NAME!" key^=clear ^| findstr "Key Content"') do (
        set "WIFI_PASS=%%B"
        set "WIFI_PASS=!WIFI_PASS:~1!"
        echo WiFi: !WIFI_NAME!
        echo Mat khau: !WIFI_PASS!
        echo --------------------------------
        
        echo WiFi: !WIFI_NAME! >> "%OUTPUT_FILE%"
        echo Mat khau: !WIFI_PASS! >> "%OUTPUT_FILE%"
        echo -------------------------------- >> "%OUTPUT_FILE%"
    )
)

:: Mo file sau khi xuat
notepad "%OUTPUT_FILE%"

echo.
echo Da xuat danh sach WiFi va mat khau ra file: "%OUTPUT_FILE%"
pause
goto menu




:end
exit
