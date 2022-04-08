@echo off
if [%1]==[] goto usage
set explicit_version=true
if %1 == major set explicit_version=false
if %1 == minor set explicit_version=false
if %1 == patch set explicit_version=false
if "%explicit_version%" == "true" (
    call cider version %1 >NUL
) else (
    call cider bump %1 >NUL
)

FOR /F "tokens=* USEBACKQ" %%F IN (`cider version`) DO (
    SET new_ver=%%F
)

@echo New version: %new_ver%
@echo Changes to release:
call cider describe
call cider release
call git commit -am "Version v%new_ver%"
call git tag -a v%new_ver% -m "Release v%new_ver%"
call git push --tags
exit /B 0

:usage
@echo Usage: %0 ^<version number or major, minor, patch^>
exit /B 1
