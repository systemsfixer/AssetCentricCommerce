@echo off
REM Quick Commit Script for AssetCentricCommerce (Windows)
REM Usage: scripts\quick-commit.bat "Your commit message"
REM Or run without message for interactive prompt

setlocal enabledelayedexpansion

REM Check if we're in a git repository
git rev-parse --git-dir >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Not in a git repository!
    exit /b 1
)

REM Check if we're in the correct repository
for /f "delims=" %%i in ('git rev-parse --show-toplevel') do set "REPO_PATH=%%i"
for %%f in ("!REPO_PATH!") do set "REPO_NAME=%%~nxf"
if not "!REPO_NAME!"=="AssetCentricCommerce2" if not "!REPO_NAME!"=="AssetCentricCommerce" (
    echo [WARNING] Repository name is '!REPO_NAME!', expected 'AssetCentricCommerce' or 'AssetCentricCommerce2'
    set /p "CONTINUE=Continue anyway? (y/N): "
    if /i not "!CONTINUE!"=="y" (
        echo [ERROR] Aborted by user
        exit /b 1
    )
)

REM Check current branch
for /f "delims=" %%i in ('git branch --show-current') do set "CURRENT_BRANCH=%%i"
if not "!CURRENT_BRANCH!"=="main" (
    echo [WARNING] Currently on branch '!CURRENT_BRANCH!', not 'main'
    set /p "CONTINUE=Continue anyway? (y/N): "
    if /i not "!CONTINUE!"=="y" (
        echo [ERROR] Aborted by user
        exit /b 1
    )
)

REM Check for uncommitted changes (both tracked and untracked)
git diff-index --quiet HEAD -- >nul 2>&1
set "TRACKED_CHANGES=!errorlevel!"
for /f %%i in ('git ls-files --others --exclude-standard') do set "UNTRACKED_FILES=1"
if "!TRACKED_CHANGES!"=="0" if not defined UNTRACKED_FILES (
    echo [WARNING] No changes detected to commit
    exit /b 0
)

REM Show current status
echo [INFO] Current git status:
git status --short
echo.

REM Get commit message
set "COMMIT_MESSAGE="
if "%~1"=="" (
    echo Enter commit message (or press Ctrl+C to cancel):
    set /p "COMMIT_MESSAGE="
    if "!COMMIT_MESSAGE!"=="" (
        echo [ERROR] Commit message cannot be empty
        exit /b 1
    )
) else (
    set "COMMIT_MESSAGE=%*"
)

echo [INFO] Commit message: '!COMMIT_MESSAGE!'
echo.

REM Confirm before proceeding
set /p "PROCEED=Proceed with staging, committing, and pushing? (Y/n): "
if /i "!PROCEED!"=="n" (
    echo [ERROR] Aborted by user
    exit /b 1
)

REM Stage all changes
echo [INFO] Staging all changes...
git add .

REM Show what will be committed
echo [INFO] Files to be committed:
git diff --cached --name-status
echo.

REM Commit changes
echo [INFO] Committing changes...
git commit -m "!COMMIT_MESSAGE!"

REM Push to remote
echo [INFO] Pushing to remote repository...
git push origin !CURRENT_BRANCH!

echo [SUCCESS] Successfully committed and pushed changes!
for /f "delims=" %%i in ('git log -1 --format^=%%h - %%s') do echo [SUCCESS] Commit: %%i

REM Show remote repository URL
for /f "delims=" %%i in ('git remote get-url origin') do echo [INFO] Remote repository: %%i

endlocal
