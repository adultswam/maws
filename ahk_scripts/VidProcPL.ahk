NirPath := "C:\dev\nircmd\nircmd.exe"
WinWait, ahk_class mpv
FileDelete, %A_WorkingDir%\misc\playing.status
FileAppend, 1, %A_WorkingDir%\misc\playing.status
Run, %NirPath% muteappvolume SlingFront.exe 1
WinWaitClose, ahk_class mpv
FileDelete, %A_WorkingDir%\misc\playing.status
FileAppend, 0, %A_WorkingDir%\misc\playing.status
Run, %NirPath% muteappvolume SlingFront.exe 0
