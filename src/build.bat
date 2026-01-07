@echo off

REM --- Compile UNITS first ---
echo ============================
echo Compiling UNITS
echo ============================

cd units
for %%F in (*.pas) do call C:\TP7\BIN\TPC.EXE %%F -B -Q
cd ..

REM --- Compile PROGRAMS ---
echo ============================
echo Compiling PROGRAMS
echo ============================

for %%F in (*.pas) do call C:\TP7\BIN\TPC.EXE %%F -B -Q -Uunits

echo.
echo Build complete.
exit