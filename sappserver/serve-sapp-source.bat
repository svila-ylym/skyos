@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve-sapp-source.ps1" %*
