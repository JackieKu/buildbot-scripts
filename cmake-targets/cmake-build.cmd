call "%~dp0cmake-gen.cmd"
if ERRORLEVEL 1 exit /b 1
cmake --build "%CD%" --config "%Configuration%" -- %*
