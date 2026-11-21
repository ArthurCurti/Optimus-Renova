@ECHO OFF
REM ----- Message block -------------------------------------------------------------
ECHO * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
ECHO *
ECHO * PYDATVIEW.BAT
ECHO * =============
ECHO * MS_Windows batch file
ECHO * Reading a OpenFAST output file *.out and open it with pyDatViewer
ECHO * 2026-11-15, Dipl.-Ing. Andreas Manjock
ECHO *
ECHO *
REM ----- Initialisation ------------------------------------------------------------
REM
SET OUT-File=OptRenova_8MW_5p1V20.out
REM
SET pyDatView-Path=C:\Users\Matthias\Desktop\Andreas\pyDatView_v05\Python\
SET PATH=%PATH%;%pyDatView-Path%;
REM ECHO * Setting new pyDatView path ...
REM ECHO * New path = %PATH%
REM
REM ----- Completness check ----------------------------------------------------------
IF EXIST %1 SET OUT-File=%1
ECHO * Reading OpenFAST result file '%OUT-File%' ...
IF NOT EXIST %OUT-File% (
	ECHO *
	ECHO * OpenFAST result file '%OUT-File%' not found.
	ECHO * Please check file location or file name ...
	ECHO *
	PAUSE
	EXIT
	)
REM
REM ----- Running pyDatView ---------------------------------------------------------
ECHO * Loading pyDatView v0.5. Please wait ...
START pythonw.exe -c "import pydatview; pydatview.show(filenames=['%OUT-File%']);"
ECHO * Running pyDatView v0.5 ...
REM
REM ----- Closing batch job ---------------------------------------------------------
ECHO * You can close this command window now ...
ECHO *
PAUSE
REM  ================================================================================
REM  12345678901234567890123456789012345678901234567890123456789012345678901234567890
REM          10        20        30        40        50        60        70        80



