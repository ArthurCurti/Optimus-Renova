@ECHO OFF
REM - Add FAST.exe directory to Windows search path
	SET OpenFAST_Path=C:\Users\DELL\Documents\GitHub\Optimus-Renova\Optimus-Renova\loads_and_dynamics
	REM C:\Users\DELL\Documents\GitHub\Optimus-Renova\Optimus-Renova\loads_and_dynamics\OptRenova_8MW
	SET PATH=%PATH%;%OpenFAST_Path%;
	SET Run_Name=OptRenova_8MW_6p2Y210
REM - Call FAST ---------------------------------------------------------------------
	openfast_x64_v4-05.exe %Run_Name%.fst
	IF EXIST %Run_Name%.out COPY %Run_Name%.out %OpenFAST_Path%\OUT-Files\%Run_Name%.out
PAUSE
EXIT /B
REM  ================================================================================
REM  12345678901234567890123456789012345678901234567890123456789012345678901234567890
REM          10        20        30        40        50        60        70        80
