@echo off
if "%CMAKE_GENERATOR%"=="" call :SetGenerator
call :SetEnv

pushd E:\software\_util_\KuUtils
call vars.cmd
if not "%_env_set%"=="" call extvars.cmd %_env_set%
popd

@echo on
@exit /b 0

:SetGenerator
	if "%label%"=="borland" (
		set CMAKE_GENERATOR=Borland Makefiles
		exit /b
	)
	exit /b

:SetEnv
	if "%CMAKE_GENERATOR%"=="Borland Makefiles" (
		set _env_set=borland
		exit /b
	)
	exit /b
