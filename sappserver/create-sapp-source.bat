@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0create-sapp-source.ps1" %*
