@call "%~dp0cmake-env.cmd"

md build >NUL 2>&1
cd build || exit /b 1

:loop
if "%~1"=="" exit /b 0
call :%~1
if ERRORLEVEL 1 exit /b 1
shift
goto loop

exit /b

:gen
	cmake -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE="%Configuration%" %CMAKE_OPTS% ..
	exit /b

:build
	cmake --build "%CD%" --config "%Configuration%" -- %CMAKE_BUILDER_OPTIONS%
	exit /b

:test
	ctest -C "%Configuration%" -j 2
	if ERRORLEVEL 1 (
		echo %ERRORLEVEL%:FAILED>TEST_RESULT
	) else (
		echo 0:OK>TEST_RESULT
	)
	exit /b 0

:pack
	cpack -C "%Configuration%"
	exit /b
