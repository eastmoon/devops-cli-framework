@rem
@rem Copyright 2020 the original author jacky.eastmoon
@rem All commad module need 3 method :
@rem [command]        : Command script
@rem [command]-args   : Command script options setting function
@rem [command]-help   : Command description
@rem Basically, CLI will not use "--options" to execute function, "--help, -h" is an exception.
@rem But, if need exception, it will need to thinking is common or individual, and need to change BREADCRUMB variable in [command]-args function.
@rem NOTE, batch call [command]-args it could call correct one or call [command] and "-args" is parameter.
@rem

@rem ------------------- batch setting -------------------
@rem setting batch file
@rem ref : https://www.tutorialspoint.com/batch_script/batch_script_if_else_statement.htm
@rem ref : https://poychang.github.io/note-batch/

@echo off
setlocal
setlocal enabledelayedexpansion

@rem ------------------- execute script -------------------
for %%a in ("%cd%") do (set PROJECT_NAME=%%~na)
docker run -ti --rm ^
  -v "//var/run/docker.sock:/var/run/docker.sock" ^
  -e CLI_REPO_NAME=%PROJECT_NAME% ^
  -e CLI_REPO_DIR="/usr/local/repo" ^
  -e CLI_REPO_MAPPING_DIR="%cd%" ^
  -v %cd%:/usr/local/repo ^
  -v %cd%\do.rc:/usr/local/devops/do.rc:ro ^
  -v %cd%\do.yml:/usr/local/devops/do.yml:ro ^
  devops-cli-fw %*
