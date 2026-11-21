@ECHO OFF
REM - Add FAST.exe directory to Windows search path
	SET OpenFAST_Path=D:\Mobile Desktop\HS Flensburg\2026-2027 WS\OPTIMUS Renova loads
	REM C:\Users\Matthias\Desktop\Andreas\GitHub_Desktop\Optimus-Renova\loads_and_dynamics
	SET PATH=%PATH%;%OpenFAST_Path%;
	SET Run_Name=OptRenova_8MW_5p1V24t
REM - Call FAST ---------------------------------------------------------------------
	openfast_x64_v4-05.exe %Run_Name%.fst
	IF EXIST %Run_Name%.out COPY %Run_Name%.out %OpenFAST_Path%\OUT-Files\%Run_Name%.out
PAUSE
EXIT /B
REM  ================================================================================
REM  12345678901234567890123456789012345678901234567890123456789012345678901234567890
REM          10        20        30        40        50        60        70        80
