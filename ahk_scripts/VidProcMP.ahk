; Requires a window manager program such as Actual Window Manager that lets you set hotkeys to reposition active windows.
; In this script, hotkeys Ctrl+Alt+S, C, Z, E, and Q will reposition the last active window (MPlayer's video output) at a
; pseudorandom location on the streamed screen, based on the window manager program's hotkey setting.
CurrWin = %1%
WinWait, %CurrWin%, , 2
IfWinExist, %CurrWin%
{
	Clusterfuck := SubStr(A_Min, 0)
	If (Clusterfuck = 0) OR (Clusterfuck = 5)
	{
		SetEnv, VarA, #^s
		SetEnv, VarB, #^c
		SetEnv, VarC, #^z
		SetEnv, VarD, #^e
		SetEnv, VarE, #^q
	}
	Else If (Clusterfuck = 1) OR (Clusterfuck = 6)
	{
		SetEnv, VarA, #^c
		SetEnv, VarB, #^z
		SetEnv, VarC, #^e
		SetEnv, VarD, #^q
		SetEnv, VarE, #^s
	}
	Else If (Clusterfuck = 2) OR (Clusterfuck = 7)
	{
		SetEnv, VarA, #^z
		SetEnv, VarB, #^e
		SetEnv, VarC, #^q
		SetEnv, VarD, #^s
		SetEnv, VarE, #^c
	}
	Else If (Clusterfuck = 3) OR (Clusterfuck = 8)
	{
		SetEnv, VarA, #^e
		SetEnv, VarB, #^q
		SetEnv, VarC, #^s
		SetEnv, VarD, #^c
		SetEnv, VarE, #^z
	}
	Else If (Clusterfuck = 4) OR (Clusterfuck = 9)
	{
		SetEnv, VarA, #^q
		SetEnv, VarB, #^s
		SetEnv, VarC, #^c
		SetEnv, VarD, #^z
		SetEnv, VarE, #^e
	}
	IfExist, %A_WorkingDir%\misc\webm1.status
	{
		IfExist, %A_WorkingDir%\misc\webm2.status
		{
			IfExist, %A_WorkingDir%\misc\webm3.status
			{
				IfExist, %A_WorkingDir%\misc\webm4.status
				{
					IfExist, %A_WorkingDir%\misc\webm5.status
					{
						WinClose, %CurrWin%
						Exit
					}
					Else
					{
						FileAppend, 5, %A_WorkingDir%\misc\webm5.status
						FileAppend, 0, %A_WorkingDir%\misc\webms.wait
						WinActivate, %CurrWin%
						SendInput #^m
						SendInput %VarA%
						Sleep, 100
						FileDelete, %A_WorkingDir%\misc\webms.wait
						WinWaitClose, %CurrWin%
						FileDelete, %A_WorkingDir%\misc\webm5.status
						Exit
					}
				}
				Else
				{
					FileAppend, 4, %A_WorkingDir%\misc\webm4.status
					FileAppend, 0, %A_WorkingDir%\misc\webms.wait
					WinActivate, %CurrWin%
					SendInput #^m
					SendInput %VarB%
					Sleep, 100
					FileDelete, %A_WorkingDir%\misc\webms.wait
					WinWaitClose, %CurrWin%
					FileDelete, %A_WorkingDir%\misc\webm4.status
					Exit
				}
			}
			Else
			{
				FileAppend, 3, %A_WorkingDir%\misc\webm3.status
				FileAppend, 0, %A_WorkingDir%\misc\webms.wait
				WinActivate, %CurrWin%
				SendInput #^m
				SendInput %VarC%
				Sleep, 100
				FileDelete, %A_WorkingDir%\misc\webms.wait
				WinWaitClose, %CurrWin%
				FileDelete, %A_WorkingDir%\misc\webm3.status
				Exit
			}
		}
		Else
		{
			FileAppend, 2, %A_WorkingDir%\misc\webm2.status
			FileAppend, 0, %A_WorkingDir%\misc\webms.wait
			WinActivate, %CurrWin%
			SendInput #^m
			SendInput %VarD%
			Sleep, 100
			FileDelete, %A_WorkingDir%\misc\webms.wait
			WinWaitClose, %CurrWin%
			FileDelete, %A_WorkingDir%\misc\webm2.status
			Exit
		}
	}
	Else
	{
		FileAppend, 1, %A_WorkingDir%\misc\webm1.status
		FileAppend, 0, %A_WorkingDir%\misc\webms.wait
		WinActivate, %CurrWin%
		SendInput #^m
		SendInput %VarE%
		Sleep, 100
		FileDelete, %A_WorkingDir%\misc\webms.wait
		WinWaitClose, %CurrWin%
		FileDelete, %A_WorkingDir%\misc\webm1.status
		Exit
	}
}
Else
{
	Exit
}
