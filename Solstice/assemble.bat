:: in order to enable "comparsion with previous version" and "restoring backup" functions
:: make 2 copies of <!solstice.nes> and rename them as <!solstice.old> and <!solstice.bak>

:: disable unnecessary console messages if possible
echo off

:: create a copy of previous compiled version
if exist !solstice.old (copy !solstice.nes !solstice.old)

:: launch preparation script and wait until finished
start /wait lua53 preparations.lua

:: -U = no need to use .import
:: -l = create listing file
:: -g = create debug file
ca65 -U -l copy_bank_00.lst -g copy_bank_00.asm
ca65 -U -l copy_bank_01.lst -g copy_bank_01.asm
ca65 -U -l copy_bank_02.lst -g copy_bank_02.asm
ca65 -U -l copy_bank_FF.lst -g copy_bank_FF.asm

:: assemble code into binaries
ld65 -C ld65.cfg -o PRG_ROM.bin --dbgfile _debug.txt ^
    copy_bank_00.o ^
    copy_bank_01.o ^
    copy_bank_02.o ^
    copy_bank_FF.o

:: join header and prg into a single ROM file
copy /B header.bin + PRG_ROM.bin !solstice.nes

:: join listing files into a single file
copy /A copy_*.lst _listing.txt

:: delete leftover garbage and copies
del *.o + PRG_ROM.bin + copy_*

:: create a copy of .nl file for original ROM
if exist original_rom.nes (copy !solstice.nes.ram.nl original_rom.nes.ram.nl)

:: check file size and display corresponding message
setlocal enableextensions
FOR %%A IN ("!solstice.nes") DO set "size=%%~zA"
if %size% EQU 131088 (
    echo.
    echo -----------------------------------------------
    echo Done! Look for !solstice.nes file in your folder.
    if exist !solstice.bak (
        echo.
        fc /A /B /T !solstice.nes !solstice.bak > nul && echo Perfect match || echo Differences found 
        echo.
        copy !solstice.nes !solstice.bak
        echo Backup created
    )
    echo -----------------------------------------------
    echo Script will close automatically in 10 seconds.
    timeout /T 10 > nul
) else (
    echo.
    echo --------------------------------------------------
    echo Something's wrong, check log for more information. 
    if exist !solstice.bak (
        echo.
        copy !solstice.bak !solstice.nes
        echo Backup restored
    )
    echo --------------------------------------------------
    echo.
    pause
)