@ECHO OFF
REM - Add FAST.exe directory to Windows search path
	set "OpenFAST_Path=%USERPROFILE%\Documents\GitHub\Optimus-Renova\Optimus-Renova\loads_and_dynamics\"
	set "Run_Name=OptRenova8MW_5p1_V8_S1_Y0_IIA"
REM - Call FAST ---------------------------------------------------------------------
	cd /d "%OpenFAST_Path%OptRenova_8MW\DLC 5.1\DLC 5.1_8"
	"%OpenFAST_Path%openfast_x64_v4-05.exe" OptRenova_8MW_5p1V8.fst

        IF EXIST *.out REN *.out %Run_Name%.out
	IF EXIST %Run_Name%.out COPY /Y %Run_Name%.out "%OpenFAST_Path%OUT-Files\%Run_Name%.out"
	IF EXIST %Run_Name%.out COPY /Y %Run_Name%.out "C:\Users\DELL\Documents\GitHub\Optimus-Renova\Optimus-Renova\loads_and_dynamics\OptRenova_8MW\MExtremes - 5.1\Data\DLC5.1\%Run_Name%.out"

PAUSE
EXIT /B
REM  ================================================================================
REM  12345678901234567890123456789012345678901234567890123456789012345678901234567890
REM          10        20        30        40        50        60        70        80