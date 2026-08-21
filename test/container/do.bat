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
  -e CLI_REPO_NAME=%PROJECT_NAME% ^
  -e CLI_REPO_DIR="/usr/local/repo" ^
  -v %cd%:/usr/local/repo ^
  -v %cd%\do.rc:/usr/local/devops/do.rc:ro ^
  -v %cd%\do.yml:/usr/local/devops/do.yml:ro ^
  devops-cli-fwk:bash %*
