:::::::::::::::::::::::::::::::::::::::::::::
::   Please put this script file at your   ::
:: Minecraft Server root with "mcrcon.exe" ::
:::::::::::::::::::::::::::::::::::::::::::::

:: Mute most of the script output
@echo off

@echo MINECRAFT SERVER AUTO-SAVING AND AUTO-BACKUP SCRIPT BY: HKPKSON @GAMINGKEN.COM
@echo OPEN-SOURCED AND NON-PROFIT USE. COPYRIGHTED 2017

::::::::::::::::::::::
:: Script Variables ::
::::::::::::::::::::::

:: Server RCON IP address
set host=127.0.0.1
:: Server RCON port
set port=25590
:: Server RCON password
set passwd=stonedfroginthepond

:: Server Map Name
set worldname="awholenewworld"
:: Backup Location (DO NOT PUT / AT THE END!!)
set backupdir="world_backups"

:: Auto-save interval (In seconds)
set /a autosaveinterval=600
:: Auto-backup interval (In rounds of autosaves)
set /a autobackupinterval=12


::::::::::::::::::::::
::      Scripts     ::
:: DON NOT CHANGE!! ::
::::::::::::::::::::::

:: Script Start
:start

:: Check for Backup Folder if exist
@if not exist "%backupdir%/" goto :makefolder

:: Check for mcrcon.exe if exist
@if not exist mcrcon.exe (
  @echo ERROR: Cannot find "mcrcon.exe"!
  @echo Please goto: https://sourceforge.net/projects/mcrcon/files/
  @echo To download the lastest "mcrcon.exe" and put it at the same folder as this .bat file.
  @pause
  @exit
)

:: Initial auto-save counter
set /a i=0

:: Wait 5sec before start
timeout /t 10

:: Auto-save script
:autosave
@echo AUTO-SAVING IN-PROGRESS...
mcrcon.exe -c -H %host% -P %port% -p %passwd% save-all
@echo AUTO-SAVING COMPLETED...

:: Auto-backup when counter is 0, then go countinue script
@echo %i% ROUNDS BEFORE AUTO-BACKUP.
if %i% == 0 goto :backup
:endbackup

:: Counter -1
set /a i=%i%-1

:: Wait for next auto-save
timeout /t %autosaveinterval%
goto :autosave

:: Backup Script
:: Author: http://www.minecraftforum.net/forums/support/server-support/server-administration/2206731-tool-auto-world-backup-using-rcon-on-windows-for
:backup
@echo AUTO-BACKUP IN-PROGRESS...
mcrcon.exe -c -H %host% -P %port% -p %passwd% "/tellraw @a [\"\",{\"text\":\"[Rcon: World backup in progress]\",\"color\":\"gray\",\"italic\":true}]"
mcrcon.exe -c -H %host% -P %port% -p %passwd% save-off
set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%
set year=%date:~-4%
set month=%date:~3,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
set day=%date:~0,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%
set datetimef=%year%%month%%day%_%hour%%min%%secs%
xcopy %worldname% "%backupdir%/%datetimef%" /s /I
set /a nextbak=%autosaveinterval%*%autobackupinterval%/60
mcrcon.exe -c -H %host% -P %port% -p %passwd% save-on
mcrcon.exe -c -H %host% -P %port% -p %passwd% "/tellraw @a [\"\",{\"text\":\"[Rcon: World backup success, next backup in %nextbak% minutes]\",\"color\":\"gray\",\"italic\":true}]"
@echo AUTO-BACKUP COMPLETED...
set /a i=%autobackupinterval%
@goto :endbackup

:makeFolder
@md "%backupdir%/"
@goto :start
