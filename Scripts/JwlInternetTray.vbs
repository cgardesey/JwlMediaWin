' Launches the JW Library internet tray icon with no visible console window.
' Double-click this file to start the tray icon. Expect one UAC prompt (required
' for firewall changes); after that it runs silently in the system tray.

Dim fso, shell, scriptDir
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

shell.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & scriptDir & "\JwlInternetTray.ps1""", 0, False
