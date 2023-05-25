Set WshShell = CreateObject("WScript.Shell") 
  WshShell.Run chr(34) & "path_to_project\scripts\startup.bat" & Chr(34), 0
Set WshShell = Nothing