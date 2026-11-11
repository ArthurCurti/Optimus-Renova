@ECHO OFF
REM - Add FAST.exe directory to Windows search path ---------------------------------
ECHO * Actual Windows search path is:
ECHO * ------------------------------
ECHO * %PATH%
ECHO *
     set PATH=%PATH%c:\Users\Matthias\Desktop\Andreas\OPTIMUS_Renova;
ECHO * New Windows search path including FAST directory is:
ECHO * ----------------------------------------------------
ECHO * %PATH%
ECHO *
REM - PAUSE
REM - Call FAST ---------------------------------------------------------------------
	 openfast_x64_v4-05.exe OptRenova_8MW.fst
PAUSE
EXIT /B
