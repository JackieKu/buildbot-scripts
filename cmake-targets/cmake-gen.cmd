if "%CMAKE_GENERATOR%"=="Borland Makefiles" call :borland_env

mkdir build && cd build && cmake -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%Configuration%" ..
exit /b %ERRORLEVEL%

:borland_env
	set ENV_F=%ProgramFiles(x86)%\Embarcadero\RAD Studio\9.0\bin\rsvars.bat
	if not exist "%ENV_F%" exit 1
	call "%ENV_F%"
	exit /b
