echo off

set Win7=
set Win7.Major=6
set Win7.Minor=1

set Version=
for /f "skip=1" %%v in ('wmic os get version') do if not defined Version set Version=%%v
for /f "delims=. tokens=1-3" %%a in ("%Version%") do (
  set Version.Major=%%a
  set Version.Minor=%%b
  set Version.Build=%%c
)

set GEQ_W7=
if %Version.Major%==%Win7.Major% (
        if %Version.Minor% geq %Win7.Minor% set GEQ_W7=1
) else if %Version.Major% gtr %Win7.Major% set GEQ_W7=1

if defined GEQ_W7 (
  net use Z: \\server\%USERNAME%
)

