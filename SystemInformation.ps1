param (
[String]$gpupdate=""
)


$version = "0.0.1.5"
$name = $env:computername
$user = $env:username
$Time = get-date -f yyyy-MM-dd-HH-mm-ss-ffff

Start-Transcript -Path "./KS_Systeminfo/LOG/$name/$user-$Time/KS_Systeminfo.log"


if (!(Test-Path ./KS_Systeminfo/File/$name/$user-$Time/)) {New-Item -Path ./KS_Systeminfo/File/$name/$user-$Time/ -ItemType Directory -erroraction 'silentlycontinue' | Out-Null}
if (!(Test-Path ./KS_Systeminfo/csv/)) {New-Item -Path ./KS_Systeminfo/csv/ -ItemType Directory -erroraction 'silentlycontinue' | Out-Null}
if (!(Test-Path ./KS_Systeminfo/csv/Bitlocker.csv)) {echo '"Account","Login Name","Password","Web Site","Comments"' >> ./KS_Systeminfo/csv/Bitlocker.csv}
if (!(Test-Path ./KS_Systeminfo/csv/WinVer.csv)) {echo '"Account","Login Name","Password","Web Site","Comments"' >> ./KS_Systeminfo/csv/WinVer.csv}

cls
Write-Host "-----------------------------------------------------------------------------------------------------------------------"
Write-Host "by Kilian Schwarz : https://github.com/Kilian-Schwarz"
Write-Host "Das ist die Version $version"
Write-Host "-----------------------------------------------------------------------------------------------------------------------"



if($gpupdate -eq "y"){}
else{
    $gpupdate = Read-Host -Prompt "Soll gpupdate durchgeführt werden? (y/n)"
}


cls
Write-Host "-----------------------------------------------------------------------------------------------------------------------"
Write-Host "by Kilian Schwarz : https://github.com/Kilian-Schwarz"
Write-Host "Das ist die Version $version"
Write-Host "-----------------------------------------------------------------------------------------------------------------------"

echo "Bitlocker wird abgerufen...."
manage-bde -protectors C: -get > ./KS_Systeminfo/File/$name/$user-$Time/BitLocker-$Time.txt
$env:computername >> ./KS_Systeminfo/File/$name/$user-$Time/BitLocker-$Time.txt


if($gpupdate -eq "y"){
    echo "Gruppenrichtlinien werden geladen...."
    gpupdate.exe /force > ./KS_Systeminfo/File/$name/$user-$Time/gpupdate-$Time.txt
}


echo "Gruppenrichtlinien werden abgerufen...."
gpresult /Z > ./KS_Systeminfo/File/$name/$user-$Time/gpresult-$Time.txt

echo "Benutzer werden abgerufen...."
Net user > ./KS_Systeminfo/File/$name/$user-$Time/user-$Time.txt

echo "arp wird geladen...."
arp -a > ./KS_Systeminfo/File/$name/$user-$Time/arp-$Time.txt
echo "driverquery wird geladen...."
driverquery > ./KS_Systeminfo/File/$name/$user-$Time/driverquery-$Time.txt
echo "mac wird überprüft...."
getmac > ./KS_Systeminfo/File/$name/$user-$Time/getmac-$Time.txt
echo "IP-Adresse wird überprüft...."
ipconfig /all > ./KS_Systeminfo/File/$name/$user-$Time/ipconfig-$Time.txt
echo "Network Stats werden geladen..."
net use > ./KS_Systeminfo/File/$name/$user-$Time/netuse-$Time.txt
echo "Network Stats wird ausgegeben..."
netstat -aefnopqrstxy > ./KS_Systeminfo/File/$name/$user-$Time/netstat-$Time.txt
echo "Seriennummer wird für die Assetliste ausgegeben..."
wmic os get "SerialNumber" > ./KS_Systeminfo/File/$name/$user-$Time/osnummer-$Time.txt
echo "systeminfo wird geladen..."
systeminfo > ./KS_Systeminfo/File/$name/$user-$Time/systeminfo-$Time.txt
echo "Win32_BIOS wird geladen..."
Get-WmiObject -Class Win32_BIOS > ./KS_Systeminfo/File/$name/$user-$Time/Win32_BIOS-SN-$Time.txt
echo "softwarelicensingservice wird überprüft..."
wmic path softwarelicensingservice get OA3xOriginalProductKey > ./KS_Systeminfo/File/$name/$user-$Time/OA3xOriginalProductKey-$Time.txt
echo "Angeschlossende Bildschirme werden geladen..."
echo "ManufacturerName, SerialnumberID, ProductCodeID, UserFriendlyName" > ./KS_Systeminfo/File/$name/$user-$Time/Bildschirme-$Time.txt
get-wmiobject wmimonitorid -namespace root\wmi|foreach-object{($_.ManufacturerName + $_.SerialnumberID + $_.ProductCodeID + $_.UserFriendlyName|foreach-object{[char]$_}) -join „“} >> ./KS_Systeminfo/File/$name/$user-$Time/Bildschirme-$Time.txt
echo "Disks werden geladen..."
GET-WMIOBJECT win32_diskdrive > ./KS_Systeminfo/File/$name/$user-$Time/win32_diskdrive-$Time.txt

echo "Systemversion wird überprüft und ausgegeben..."

echo --------------------------------------- >> ./KS_Systeminfo/File/Version-$Time.txt
get-date -f MM-dd-yyyy-HH:MM:ss >> ./KS_Systeminfo/File/Version-$Time.txt
$env:computername >> ./KS_Systeminfo/File/Version-$Time.txt
[environment]::OSVersion.Version >> ./KS_Systeminfo/File/Version-$Time.txt



echo "csv-Dateien werden erstellt..."

echo "BitLocker csv wird bearbeitet..."


#BITLOCKER CSV ----------------------------------------------------------------
$inputFile= manage-bde -protectors C: -get


$csv_Bitlocker_ID = $inputFile| Select-string '    Numerisches Kennwort:' -Context 0,1
$csv_Bitlocker_Key = $inputFile| Select-string '      Kennwort:' -Context 0,1



$csv_Bitlocker_key_F = $csv_Bitlocker_key  -replace( " ","") -replace( "Kennwort:","") -replace("`n","") -replace("`r","") -replace("`r`n","") -replace(">","")

$csv_Bitlocker_ID_F  = $csv_Bitlocker_ID  -replace( " ","") -replace( "NumerischesKennwort:","") -replace("`n","") -replace("`r","") -replace("`r`n","") -replace("ID:{","") -replace("}","") -replace(">","")

$csv_Bitlocker =  '"' + $name + '_Bitlocker_' +  $Time +'","' + $csv_Bitlocker_ID_F + '","' + $csv_Bitlocker_key_F +'","",""'

$csv_Bitlocker >> ./KS_Systeminfo/csv/Bitlocker.csv

#BITLOCKER CSV ----------------------------------------------------------------

echo "Windows Version csv wird bearbeitet..."
#Windows Version  ----------------------------------------------------------------
$sv_sysinf = systeminfo | Select-string 'Betriebssystemversion:'
$sv_sysinf_F = $sv_sysinf -replace("Betriebssystemversion:                         ","")

$csv_sysinv =  '"' + $name + '_Windows-Version_' +  $Time +'","' + $sv_sysinf_F + '","","",""'
$csv_sysinv >>  ./KS_Systeminfo/csv/WinVer.csv
#Windows Version  ----------------------------------------------------------------


cls
Write-Host "-----------------------------------------------------------------------------------------------------------------------"
Write-Host "by Kilian Schwarz : https://github.com/Kilian-Schwarz"
Write-Host "Das ist die Version $version"
Write-Host "-----------------------------------------------------------------------------------------------------------------------"


echo "Vielen Dank"
echo "Ich wünsche ihenen noch einen schönen Tag."
echo "Bleibt Gesund"
timeout /T 3 /nobreak
exit