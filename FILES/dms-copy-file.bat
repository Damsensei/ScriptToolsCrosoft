@echo off
set source=".\PathSrc.txt"
set destination="C:\PathRepository"

xcopy  %source% %destination% /Y