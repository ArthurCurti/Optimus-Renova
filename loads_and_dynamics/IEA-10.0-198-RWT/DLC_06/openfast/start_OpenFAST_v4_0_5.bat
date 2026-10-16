@ECHO OFF
REM - Add FAST.exe directory to Windows search path ---------------------------------
ECHO * Actual Windows search path is:
ECHO * ------------------------------
ECHO * %PATH%
ECHO *
	set PATH=%PATH%C:\Users\DELL\Downloads\IEA-10.0-198-RWT\IEA-10.0-198-RWT\openfast;
ECHO * New Windows search path including FAST directory is:
ECHO * ----------------------------------------------------
ECHO * %PATH%
ECHO *
REM - Call FAST ---------------------------------------------------------------------
	openfast_x64_v4.exe IEA-10.0-198-RWT.fst
PAUSE
EXIT /B
