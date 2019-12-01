#Persistent
#Include HTTPRequest.ahk
myPID := DllCall("GetCurrentProcessId")
FileDelete, %A_WorkingDir%\vidprocpl.pid
FileAppend, %myPID%, %A_WorkingDir%\vidprocpl.pid

FileDelete, %A_WorkingDir%\playing.status
FileAppend, 1, %A_WorkingDir%\playing.status

FileDelete, %A_WorkingDir%\chanlocale.bkp
FileRead, ChanLocaleBKP, %A_WorkingDir%\chanlocale.txt
FileAppend, %ChanLocaleBKP%, %A_WorkingDir%\chanlocale.bkp
FileDelete, %A_WorkingDir%\chanlocale.txt
FileAppend, VID, %A_WorkingDir%\chanlocale.txt
WinSet Bottom,, Windows Media Center
Sleep, 500

Gosub, ComDeterminePlaylist


ComDeterminePlaylist:
	EnvAdd, VdNm, 1
	FileRead, VidPlaylist, %A_WorkingDir%\mpvplaylist.txt
	PlaylistPos := RegExMatch(VidPlaylist, ".+?\r\n")
	If (PlaylistPos = 1)
	{
		FileRead, MPVQueueNum, %A_WorkingDir%\mpvqueuenum.txt
		EnvSub, MPVQueueNum, 1
		FileDelete, %A_WorkingDir%\mpvqueuenum.txt
		FileAppend, %MPVQueueNum%, %A_WorkingDir%\mpvqueuenum.txt
		Gosub, ComProcessPlaylist
	}
	Else If (PlaylistPos = 0)
	{
		FileDelete, %A_WorkingDir%\mpvqueuenum.txt
		FileAppend, -1, %A_WorkingDir%\mpvqueuenum.txt
		GoSub, ComEndPlaylist
	}


ComProcessPlaylist:
	FileReadLine, VidPath, %A_WorkingDir%\mpvplaylist.txt, 1
	WinClose, Twitch - Pale Moon
	VidPlaylist := RegExReplace(VidPlaylist, ".+?\r\n", "", "", 1)
	FileDelete, %A_WorkingDir%\mpvplaylist.txt
	FileAppend, %VidPlaylist%, %A_WorkingDir%\mpvplaylist.txt
	IfInString, VidPath, home://
	{
		StringSplit, VidStringArray, VidPath, /
		StringSplit, VidFlagsArray, VidPath, ?
		If (VidStringArray0 != 4)
		{
			VidCompositePath = wat-wrongnumdelim
		}
		Else If (VidStringArray0 = 4)
		{
			FilePathFilename := VidStringArray4
			StringReplace, FilePathFilenameFixed, FilePathFilename, %A_Space%, _, All ; requested file's whitespace turn to underscore for ease of matching in the pl files
			VidFlagTime := VidFlagsArray2
			StringReplace, VidFlagTime, VidFlagTime, t=, %A_Space%--start=,
			FileRead FilePaths, %A_WorkingDir%\mpvpaths.txt
			StringReplace FilePaths, FilePaths, `n, `n, All UseErrorLevel
			FilePathsLines := ErrorLevel
			Loop, read, %A_WorkingDir%\mpvpaths.txt
			{
				IfInString, A_LoopReadLine, %VidStringArray3%
				{
					StringSplit, FilePathArray, A_LoopReadLine, 
					FilePathDir := FilePathArray3
					If (FilePathArray1 = 0) ; dont try to interpret filenames
					{
						VidCompositePath = %FilePathDir%%FilePathFilename%%VidFlagTime%
					}
					Else If (FilePathArray1 = 1) ; try to interpret filenames
					{
						FileRead FilePlaylist, %FilePathArray3%
						StringReplace FilePlaylist, FilePlaylist, `n, `n, All UseErrorLevel
						FilePlaylistLines := ErrorLevel
						IfInString, FilePathFilenameFixed, random
						{
							StringReplace, FilePathFilenameFixed, FilePathFilenameFixed, _, %A_Space%,
							StringSplit, FilePathFilenameFixedArray, FilePathFilenameFixed, %A_Space%
							If (FilePathFilenameFixedArray2) ; if it's a targetted random ie "famguy/random season3"
							{
								IniRead, ClampRandPreviousString, %FilePathArray3%, ClampRandomSearch, ClampRandomString ; SECTION ClampRandomSearch KEY ClampRandomString
								IfInString, FilePathFilenameFixedArray2, %ClampRandPreviousString% ; continue previous clamped playlist
								{
									IniRead, ClampRandAlreadyPlayed, %FilePathArray3%, ClampRandomList, ClampRandomLines ; SCT ClampRandomList KEY ClampRandomLines
									IniRead, ClampRandIgnoreThese, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines ; ClampRandomIgnoreList ClampRandomIgnoreLines
									ClampRandDisabledLines = ¦%ClampRandAlreadyPlayed%¦¦%ClampRandIgnoreThese%¦
									Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
									ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
									ClampRandPlaylistWhileLine = 101
									while (RegExMatch(ClampRandDisabledLines, ClampRandPlaylistLine))
									{
										Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
										ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
										If (ClampRandPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampRandomList, ClampRandomLines
											ClampRandAlreadyPlayed = ¦0¦
											ClampRandDisabledLines = ¦0¦¦%ClampRandIgnoreThese%¦
											ClampRandPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampRandPlaylistWhileLine++
										}
									}
									IniWrite, %ClampRandPlaylistLine%%ClampRandAlreadyPlayed%, %FilePathArray3%, ClampRandomList, ClampRandomLines
									StringReplace ClampRandPlaylistLine, ClampRandPlaylistLine, ¦, , All
									FileReadLine, ClampRandPlaylistPick, %FilePathArray3%, %ClampRandPlaylistLine%
									StringSplit, ClampRandPlaylistArray, ClampRandPlaylistPick, 
									ClampRandPlstFilename := ClampRandPlaylistArray1
									ClampRandWinTitleName := ClampRandPlaylistArray2
									ClampRandFriendlyName := ClampRandPlaylistArray3
									VidCompositePath = %ClampRandPlstFilename%%VidFlagTime%%A_Space%%ClampRandWinTitleName%
								}
								Else ; erase previous clamp string and start new playlist with new string
								{
									IniDelete, %FilePathArray3%, ClampRandomSearch, ClampRandomString
									IniWrite, %FilePathFilenameFixedArray2%, %FilePathArray3%, ClampRandomSearch, ClampRandomString
									IniDelete, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
									ClampRandPlaylistLoopLine = 101
									Loop ; loop read the playlist file to determine the lines to avoid while clamping
									{
										If (ClampRandPlaylistLoopLine > FilePlaylistLines)
										{
											Break
										}
										FileReadLine, ClampRandPlaylistLoop, %FilePathArray3%, %ClampRandPlaylistLoopLine%
										StringSplit, ClampRandFilePlaylistArray, ClampRandPlaylistLoop, 
										IfInString, ClampRandFilePlaylistArray3, %FilePathFilenameFixedArray2%
										{
											ClampRandPlaylistLoopLine++
										}
										Else
										{
											IniRead, ClampRandIgnored, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
											IniDelete, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
											IniWrite, ¦%ClampRandPlaylistLoopLine%¦%ClampRandIgnored%, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
											ClampRandPlaylistLoopLine++
										}
									}
									IniDelete, %FilePathArray3%, ClampRandomList, ClampRandomLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampRandomList, ClampRandomLines
									IniRead, ClampRandIgnoreThese, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
									ClampRandDisabledLines = ¦%ClampRandIgnoreThese%¦
									Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
									ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
									ClampRandPlaylistWhileLine = 101
									while (RegExMatch(ClampRandDisabledLines, ClampRandPlaylistLine))
									{
										Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
										ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
										If (ClampRandPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampRandomList, ClampRandomLines
											ClampRandAlreadyPlayed = ¦0¦
											ClampRandDisabledLines = ¦0¦¦%ClampRandIgnoreThese%¦
											ClampRandPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampRandPlaylistWhileLine++
										}
									}
									IniWrite, %ClampRandPlaylistLine%%ClampRandAlreadyPlayed%, %FilePathArray3%, ClampRandomList, ClampRandomLines
									StringReplace ClampRandPlaylistLine, ClampRandPlaylistLine, ¦, , All
									FileReadLine, ClampRandPlaylistPick, %FilePathArray3%, %ClampRandPlaylistLine%
									StringSplit, ClampRandPlaylistArray, ClampRandPlaylistPick, 
									ClampRandPlstFilename := ClampRandPlaylistArray1
									ClampRandWinTitleName := ClampRandPlaylistArray2
									ClampRandFriendlyName := ClampRandPlaylistArray3
									VidCompositePath = %ClampRandPlstFilename%%VidFlagTime%%A_Space%%ClampRandWinTitleName%
								}
							}
							Else ; else if it's a normal random ie "famguy/random"
							{
								IniRead, RandAlreadyPlayed, %FilePathArray3%, RandomList, RandomLines
								IniRead, RandIgnoreThese, %FilePathArray3%, RndIgnoreList, RndIgnoreLines
								RandDisabledLines = ¦%RandAlreadyPlayed%¦¦%RandIgnoreThese%¦
								Random, RandPlaylistLine, 101, %FilePlaylistLines%
								RandPlaylistLine = ¦%RandPlaylistLine%¦
								while (RegExMatch(RandDisabledLines, RandPlaylistLine))
								{
									Random, RandPlaylistLine, 101, %FilePlaylistLines%
									RandPlaylistLine = ¦%RandPlaylistLine%¦
									;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine%`r`n, %A_WorkingDir%\test.txt
									If (A_Index > FilePlaylistLines) ; if matched every time
									{
										IniDelete, %FilePathArray3%, RandomList, RandomLines
										RandAlreadyPlayed = ¦0¦
										;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine% AM`r`n, %A_WorkingDir%\test.txt
										Break
									}
									Else ; if havent matched
									{
										;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine% PM`r`n, %A_WorkingDir%\test.txt
										Vamoose = vamoose
									}
								}
								IniWrite, %RandPlaylistLine%%RandAlreadyPlayed%, %FilePathArray3%, RandomList, RandomLines
								;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine% NM`r`n, %A_WorkingDir%\test.txt
								StringReplace RandPlaylistLine, RandPlaylistLine, ¦, , All
								FileReadLine, RandPlaylistPick, %FilePathArray3%, %RandPlaylistLine%
								StringSplit, RandPlaylistArray, RandPlaylistPick, 
								RandPlstFilename := RandPlaylistArray1
								RandWinTitleName := RandPlaylistArray2 ; RandWinTitleName = --title="👻 it is a mystery"
								RandFriendlyName := RandPlaylistArray3
								VidCompositePath = %RandPlstFilename%%VidFlagTime%%A_Space%%RandWinTitleName%
							}
						}
						Else IfInString, FilePathFilenameFixed, shuffle
						{
							StringReplace, FilePathFilenameFixed, FilePathFilenameFixed, _, %A_Space%,
							StringSplit, FilePathFilenameFixedArray, FilePathFilenameFixed, %A_Space%
							If (FilePathFilenameFixedArray2) ; if it's a targetted shuffle ie "famguy/shuffle season3"
							{
								IniRead, ClampRandPreviousString, %FilePathArray3%, ClampRandomSearch, ClampRandomString ; SECTION ClampRandomSearch KEY ClampRandomString
								IfInString, FilePathFilenameFixedArray2, %ClampRandPreviousString% ; continue previous clamped playlist
								{
									IniRead, ClampRandAlreadyPlayed, %FilePathArray3%, ClampRandomList, ClampRandomLines ; SCT ClampRandomList KEY ClampRandomLines
									IniRead, ClampRandIgnoreThese, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines ; ClampRandomIgnoreList ClampRandomIgnoreLines
									ClampRandDisabledLines = ¦%ClampRandAlreadyPlayed%¦¦%ClampRandIgnoreThese%¦
									Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
									ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
									ClampRandPlaylistWhileLine = 101
									while (RegExMatch(ClampRandDisabledLines, ClampRandPlaylistLine))
									{
										Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
										ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
										If (ClampRandPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampRandomList, ClampRandomLines
											ClampRandAlreadyPlayed = ¦0¦
											ClampRandDisabledLines = ¦0¦¦%ClampRandIgnoreThese%¦
											ClampRandPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampRandPlaylistWhileLine++
										}
									}
									FileAppend, %VidPath%`r`n, %A_WorkingDir%\mpvplaylist.txt
									FileRead, MPVQueueNum, %A_WorkingDir%\mpvqueuenum.txt
									EnvAdd, MPVQueueNum, 1
									FileDelete, %A_WorkingDir%\mpvqueuenum.txt
									FileAppend, %MPVQueueNum%, %A_WorkingDir%\mpvqueuenum.txt
									IniWrite, %ClampRandPlaylistLine%%ClampRandAlreadyPlayed%, %FilePathArray3%, ClampRandomList, ClampRandomLines
									StringReplace ClampRandPlaylistLine, ClampRandPlaylistLine, ¦, , All
									FileReadLine, ClampRandPlaylistPick, %FilePathArray3%, %ClampRandPlaylistLine%
									StringSplit, ClampRandPlaylistArray, ClampRandPlaylistPick, 
									ClampRandPlstFilename := ClampRandPlaylistArray1
									ClampRandWinTitleName := ClampRandPlaylistArray2
									ClampRandFriendlyName := ClampRandPlaylistArray3
									VidCompositePath = %ClampRandPlstFilename%%VidFlagTime%%A_Space%%ClampRandWinTitleName%
								}
								Else ; erase previous clamp string and start new playlist with new string
								{
									IniDelete, %FilePathArray3%, ClampRandomSearch, ClampRandomString
									IniWrite, %FilePathFilenameFixedArray2%, %FilePathArray3%, ClampRandomSearch, ClampRandomString
									IniDelete, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
									ClampRandPlaylistLoopLine = 101
									Loop ; loop read the playlist file to determine the lines to avoid while clamping
									{
										If (ClampRandPlaylistLoopLine > FilePlaylistLines)
										{
											Break
										}
										FileReadLine, ClampRandPlaylistLoop, %FilePathArray3%, %ClampRandPlaylistLoopLine%
										StringSplit, ClampRandFilePlaylistArray, ClampRandPlaylistLoop, 
										IfInString, ClampRandFilePlaylistArray3, %FilePathFilenameFixedArray2%
										{
											ClampRandPlaylistLoopLine++
										}
										Else
										{
											IniRead, ClampRandIgnored, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
											IniDelete, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
											IniWrite, ¦%ClampRandPlaylistLoopLine%¦%ClampRandIgnored%, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
											ClampRandPlaylistLoopLine++
										}
									}
									IniDelete, %FilePathArray3%, ClampRandomList, ClampRandomLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampRandomList, ClampRandomLines
									IniRead, ClampRandIgnoreThese, %FilePathArray3%, ClampRandomIgnoreList, ClampRandomIgnoreLines
									ClampRandDisabledLines = ¦%ClampRandIgnoreThese%¦
									Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
									ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
									ClampRandPlaylistWhileLine = 101
									while (RegExMatch(ClampRandDisabledLines, ClampRandPlaylistLine))
									{
										Random, ClampRandPlaylistLine, 101, %FilePlaylistLines%
										ClampRandPlaylistLine = ¦%ClampRandPlaylistLine%¦
										If (ClampRandPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampRandomList, ClampRandomLines
											ClampRandAlreadyPlayed = ¦0¦
											ClampRandDisabledLines = ¦0¦¦%ClampRandIgnoreThese%¦
											ClampRandPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampRandPlaylistWhileLine++
										}
									}
									FileAppend, %VidPath%`r`n, %A_WorkingDir%\mpvplaylist.txt
									FileRead, MPVQueueNum, %A_WorkingDir%\mpvqueuenum.txt
									EnvAdd, MPVQueueNum, 1
									FileDelete, %A_WorkingDir%\mpvqueuenum.txt
									FileAppend, %MPVQueueNum%, %A_WorkingDir%\mpvqueuenum.txt
									IniWrite, %ClampRandPlaylistLine%%ClampRandAlreadyPlayed%, %FilePathArray3%, ClampRandomList, ClampRandomLines
									StringReplace ClampRandPlaylistLine, ClampRandPlaylistLine, ¦, , All
									FileReadLine, ClampRandPlaylistPick, %FilePathArray3%, %ClampRandPlaylistLine%
									StringSplit, ClampRandPlaylistArray, ClampRandPlaylistPick, 
									ClampRandPlstFilename := ClampRandPlaylistArray1
									ClampRandWinTitleName := ClampRandPlaylistArray2
									ClampRandFriendlyName := ClampRandPlaylistArray3
									VidCompositePath = %ClampRandPlstFilename%%VidFlagTime%%A_Space%%ClampRandWinTitleName%
								}
							}
							Else ; else if it's a normal shuffle ie "famguy/shuffle"
							{
								IniRead, RandAlreadyPlayed, %FilePathArray3%, RandomList, RandomLines
								IniRead, RandIgnoreThese, %FilePathArray3%, RndIgnoreList, RndIgnoreLines
								RandDisabledLines = ¦%RandAlreadyPlayed%¦¦%RandIgnoreThese%¦
								Random, RandPlaylistLine, 101, %FilePlaylistLines%
								RandPlaylistLine = ¦%RandPlaylistLine%¦
								while (RegExMatch(RandDisabledLines, RandPlaylistLine))
								{
									Random, RandPlaylistLine, 101, %FilePlaylistLines%
									RandPlaylistLine = ¦%RandPlaylistLine%¦
									;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine%`r`n, %A_WorkingDir%\test.txt
									If (A_Index > FilePlaylistLines) ; if matched every time
									{
										IniDelete, %FilePathArray3%, RandomList, RandomLines
										RandAlreadyPlayed = ¦0¦
										;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine% AM`r`n, %A_WorkingDir%\test.txt
										Break
									}
									Else ; if havent matched
									{
										;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine% PM`r`n, %A_WorkingDir%\test.txt
										Vamoose = vamoose
									}
								}
								FileAppend, %VidPath%`r`n, %A_WorkingDir%\mpvplaylist.txt
								FileRead, MPVQueueNum, %A_WorkingDir%\mpvqueuenum.txt
								EnvAdd, MPVQueueNum, 1
								FileDelete, %A_WorkingDir%\mpvqueuenum.txt
								FileAppend, %MPVQueueNum%, %A_WorkingDir%\mpvqueuenum.txt
								IniWrite, %RandPlaylistLine%%RandAlreadyPlayed%, %FilePathArray3%, RandomList, RandomLines
								;FileAppend, now=%A_Now% iteration=%A_Index% rand=%RandPlaylistLine% NM`r`n, %A_WorkingDir%\test.txt
								StringReplace RandPlaylistLine, RandPlaylistLine, ¦, , All
								FileReadLine, RandPlaylistPick, %FilePathArray3%, %RandPlaylistLine%
								StringSplit, RandPlaylistArray, RandPlaylistPick, 
								RandPlstFilename := RandPlaylistArray1
								RandWinTitleName := RandPlaylistArray2 ; RandWinTitleName = --title="👻 it is a mystery"
								RandFriendlyName := RandPlaylistArray3
								VidCompositePath = %RandPlstFilename%%VidFlagTime%%A_Space%%RandWinTitleName%
							}
						}
						Else If InStr(FilePathFilenameFixed, "next") or InStr(FilePathFilenameFixed, "continue")
						{
							StringReplace, FilePathFilenameFixed, FilePathFilenameFixed, _, %A_Space%,
							StringSplit, FilePathFilenameFixedArray, FilePathFilenameFixed, %A_Space%
							If (FilePathFilenameFixedArray2) ; if it's a targetted next ie "famguy/next season3"
							{
								IniRead, ClampContPreviousString, %FilePathArray3%, ClampContinuousSearch, ClampContinuousString ; SECTION ClampContinuousSearch KEY ClampContinuousString
								IfInString, FilePathFilenameFixedArray2, %ClampContPreviousString% ; continue previous clamped playlist
								{
									EnvSub, FilePlaylistLines, 2
									IniRead, ClampContAlreadyPlayed, %FilePathArray3%, ClampContinuousList, ClampContinuousLines ; SCT ClampContinuousList KEY ClampContinuousLines
									IniRead, ClampContIgnoreThese, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines ; ClampContinuousIgnoreList ClampContinuousIgnoreLines
									ClampContDisabledLines = ¦%ClampContAlreadyPlayed%¦¦%ClampContIgnoreThese%¦
									SetEnv, ClampContPlaylistLNum, 101
									ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
									ClampContPlaylistWhileLine = 101
									while (RegExMatch(ClampContDisabledLines, ClampContPlaylistLine))
									{
										EnvAdd, ClampContPlaylistLNum, 1
										ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
										If (ClampContPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
											ClampContAlreadyPlayed = ¦0¦
											ClampContDisabledLines = ¦0¦¦%ClampContIgnoreThese%¦
											ClampContPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampContPlaylistWhileLine++
										}
									}
									IniWrite, %ClampContPlaylistLine%%ClampContAlreadyPlayed%, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									StringReplace ClampContPlaylistLine, ClampContPlaylistLine, ¦, , All
									FileReadLine, ClampContPlaylistPick, %FilePathArray3%, %ClampContPlaylistLine%
									StringSplit, ClampContPlaylistArray, ClampContPlaylistPick, 
									ClampContPlstFilename := ClampContPlaylistArray1
									ClampContWinTitleName := ClampContPlaylistArray2
									ClampContFriendlyName := ClampContPlaylistArray3
									VidCompositePath = %ClampContPlstFilename%%VidFlagTime%%A_Space%%ClampContWinTitleName%
								}
								Else ; erase previous clamp string and start new playlist with new string
								{
									IniDelete, %FilePathArray3%, ClampContinuousSearch, ClampContinuousString
									IniWrite, %FilePathFilenameFixedArray2%, %FilePathArray3%, ClampContinuousSearch, ClampContinuousString
									IniDelete, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
									ClampContPlaylistLoopLine = 101
									Loop ; loop read the playlist file to determine the lines to avoid while clamping
									{
										If (ClampContPlaylistLoopLine > FilePlaylistLines)
										{
											Break
										}
										FileReadLine, ClampContPlaylistLoop, %FilePathArray3%, %ClampContPlaylistLoopLine%
										StringSplit, ClampContFilePlaylistArray, ClampContPlaylistLoop, 
										IfInString, ClampContFilePlaylistArray3, %FilePathFilenameFixedArray2%
										{
											ClampContPlaylistLoopLine++
										}
										Else
										{
											IniRead, ClampContIgnored, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
											IniDelete, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
											IniWrite, ¦%ClampContPlaylistLoopLine%¦%ClampContIgnored%, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
											ClampContPlaylistLoopLine++
										}
									}
									IniDelete, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									IniRead, ClampContIgnoreThese, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
									ClampContDisabledLines = ¦%ClampContIgnoreThese%¦
									SetEnv, ClampContPlaylistLNum, 101
									ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
									ClampContPlaylistWhileLine = 101
									while (RegExMatch(ClampContDisabledLines, ClampContPlaylistLine))
									{
										EnvAdd, ClampContPlaylistLNum, 1
										ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
										If (ClampContPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
											ClampContAlreadyPlayed = ¦0¦
											ClampContDisabledLines = ¦0¦¦%ClampContIgnoreThese%¦
											ClampContPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampContPlaylistWhileLine++
										}
									}
									IniWrite, %ClampContPlaylistLine%%ClampContAlreadyPlayed%, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									StringReplace ClampContPlaylistLine, ClampContPlaylistLine, ¦, , All
									FileReadLine, ClampContPlaylistPick, %FilePathArray3%, %ClampContPlaylistLine%
									StringSplit, ClampContPlaylistArray, ClampContPlaylistPick, 
									ClampContPlstFilename := ClampContPlaylistArray1
									ClampContWinTitleName := ClampContPlaylistArray2
									ClampContFriendlyName := ClampContPlaylistArray3
									VidCompositePath = %ClampContPlstFilename%%VidFlagTime%%A_Space%%ClampContWinTitleName%
								}
							}
							Else ; else if it's a normal next ie "famguy/next"
							{
								EnvSub, FilePlaylistLines, 2
								IniRead, ContAlreadyPlayed, %FilePathArray3%, ContinuousList, ContinuousLines
								IniRead, ContIgnoreThese, %FilePathArray3%, CntIgnoreList, CntIgnoreLines
								ContDisabledLines = ¦%ContAlreadyPlayed%¦¦%ContIgnoreThese%¦
								SetEnv, ContPlaylistLNum, 101
								ContPlaylistLine = ¦%ContPlaylistLNum%¦
								SetEnv, ContWhileIndex, 101
								while (RegExMatch(ContDisabledLines, ContPlaylistLine))
								{
									EnvAdd, ContPlaylistLNum, 1
									ContPlaylistLine = ¦%ContPlaylistLNum%¦
									;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine%`r`n, %A_WorkingDir%\test.txt
									If (ContWhileIndex > FilePlaylistLines) ; if matched every time
									{
										IniDelete, %FilePathArray3%, ContinuousList, ContinuousLines
										ContAlreadyPlayed = ¦0¦
										;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine% AM`r`n, %A_WorkingDir%\test.txt
										Break
									}
									Else ; if havent matched
									{
										;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine% PM`r`n, %A_WorkingDir%\test.txt
										ContWhileIndex++
									}
								}
								IniWrite, %ContPlaylistLine%%ContAlreadyPlayed%, %FilePathArray3%, ContinuousList, ContinuousLines
								;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine% NM`r`n, %A_WorkingDir%\test.txt
								StringReplace ContPlaylistLine, ContPlaylistLine, ¦, , All
								FileReadLine, ContPlaylistPick, %FilePathArray3%, %ContPlaylistLine%
								StringSplit, ContPlaylistArray, ContPlaylistPick, 
								ContPlstFilename := ContPlaylistArray1
								ContWinTitleName := ContPlaylistArray2 ; ContWinTitleName = --title="👻 it is a mystery"
								ContFriendlyName := ContPlaylistArray3
								VidCompositePath = %ContPlstFilename%%VidFlagTime%%A_Space%%ContWinTitleName%
							}
						}
						Else If InStr(FilePathFilenameFixed, "playthru")
						{
							StringReplace, FilePathFilenameFixed, FilePathFilenameFixed, _, %A_Space%,
							StringSplit, FilePathFilenameFixedArray, FilePathFilenameFixed, %A_Space%
							If (FilePathFilenameFixedArray2) ; if it's a targetted next ie "famguy/next season3"
							{
								IniRead, ClampContPreviousString, %FilePathArray3%, ClampContinuousSearch, ClampContinuousString ; SECTION ClampContinuousSearch KEY ClampContinuousString
								IfInString, FilePathFilenameFixedArray2, %ClampContPreviousString% ; continue previous clamped playlist
								{
									EnvSub, FilePlaylistLines, 2
									IniRead, ClampContAlreadyPlayed, %FilePathArray3%, ClampContinuousList, ClampContinuousLines ; SCT ClampContinuousList KEY ClampContinuousLines
									IniRead, ClampContIgnoreThese, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines ; ClampContinuousIgnoreList ClampContinuousIgnoreLines
									ClampContDisabledLines = ¦%ClampContAlreadyPlayed%¦¦%ClampContIgnoreThese%¦
									SetEnv, ClampContPlaylistLNum, 101
									ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
									ClampContPlaylistWhileLine = 101
									while (RegExMatch(ClampContDisabledLines, ClampContPlaylistLine))
									{
										EnvAdd, ClampContPlaylistLNum, 1
										ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
										If (ClampContPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
											ClampContAlreadyPlayed = ¦0¦
											ClampContDisabledLines = ¦0¦¦%ClampContIgnoreThese%¦
											ClampContPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampContPlaylistWhileLine++
										}
									}
									FileAppend, %VidPath%`r`n, %A_WorkingDir%\mpvplaylist.txt
									FileRead, MPVQueueNum, %A_WorkingDir%\mpvqueuenum.txt
									EnvAdd, MPVQueueNum, 1
									FileDelete, %A_WorkingDir%\mpvqueuenum.txt
									FileAppend, %MPVQueueNum%, %A_WorkingDir%\mpvqueuenum.txt
									IniWrite, %ClampContPlaylistLine%%ClampContAlreadyPlayed%, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									StringReplace ClampContPlaylistLine, ClampContPlaylistLine, ¦, , All
									FileReadLine, ClampContPlaylistPick, %FilePathArray3%, %ClampContPlaylistLine%
									StringSplit, ClampContPlaylistArray, ClampContPlaylistPick, 
									ClampContPlstFilename := ClampContPlaylistArray1
									ClampContWinTitleName := ClampContPlaylistArray2
									ClampContFriendlyName := ClampContPlaylistArray3
									VidCompositePath = %ClampContPlstFilename%%VidFlagTime%%A_Space%%ClampContWinTitleName%
								}
								Else ; erase previous clamp string and start new playlist with new string
								{
									IniDelete, %FilePathArray3%, ClampContinuousSearch, ClampContinuousString
									IniWrite, %FilePathFilenameFixedArray2%, %FilePathArray3%, ClampContinuousSearch, ClampContinuousString
									IniDelete, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
									ClampContPlaylistLoopLine = 101
									Loop ; loop read the playlist file to determine the lines to avoid while clamping
									{
										If (ClampContPlaylistLoopLine > FilePlaylistLines)
										{
											Break
										}
										FileReadLine, ClampContPlaylistLoop, %FilePathArray3%, %ClampContPlaylistLoopLine%
										StringSplit, ClampContFilePlaylistArray, ClampContPlaylistLoop, 
										IfInString, ClampContFilePlaylistArray3, %FilePathFilenameFixedArray2%
										{
											ClampContPlaylistLoopLine++
										}
										Else
										{
											IniRead, ClampContIgnored, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
											IniDelete, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
											IniWrite, ¦%ClampContPlaylistLoopLine%¦%ClampContIgnored%, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
											ClampContPlaylistLoopLine++
										}
									}
									IniDelete, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									IniWrite, ¦0¦, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									IniRead, ClampContIgnoreThese, %FilePathArray3%, ClampContinuousIgnoreList, ClampContinuousIgnoreLines
									ClampContDisabledLines = ¦%ClampContIgnoreThese%¦
									SetEnv, ClampContPlaylistLNum, 101
									ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
									ClampContPlaylistWhileLine = 101
									while (RegExMatch(ClampContDisabledLines, ClampContPlaylistLine))
									{
										EnvAdd, ClampContPlaylistLNum, 1
										ClampContPlaylistLine = ¦%ClampContPlaylistLNum%¦
										If (ClampContPlaylistWhileLine > FilePlaylistLines) ; if matched every time
										{
											IniDelete, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
											ClampContAlreadyPlayed = ¦0¦
											ClampContDisabledLines = ¦0¦¦%ClampContIgnoreThese%¦
											ClampContPlaylistWhileLine = 101
										}
										Else ; if havent matched
										{
											ClampContPlaylistWhileLine++
										}
									}
									FileAppend, %VidPath%`r`n, %A_WorkingDir%\mpvplaylist.txt
									FileRead, MPVQueueNum, %A_WorkingDir%\mpvqueuenum.txt
									EnvAdd, MPVQueueNum, 1
									FileDelete, %A_WorkingDir%\mpvqueuenum.txt
									FileAppend, %MPVQueueNum%, %A_WorkingDir%\mpvqueuenum.txt
									IniWrite, %ClampContPlaylistLine%%ClampContAlreadyPlayed%, %FilePathArray3%, ClampContinuousList, ClampContinuousLines
									StringReplace ClampContPlaylistLine, ClampContPlaylistLine, ¦, , All
									FileReadLine, ClampContPlaylistPick, %FilePathArray3%, %ClampContPlaylistLine%
									StringSplit, ClampContPlaylistArray, ClampContPlaylistPick, 
									ClampContPlstFilename := ClampContPlaylistArray1
									ClampContWinTitleName := ClampContPlaylistArray2
									ClampContFriendlyName := ClampContPlaylistArray3
									VidCompositePath = %ClampContPlstFilename%%VidFlagTime%%A_Space%%ClampContWinTitleName%
								}
							}
							Else ; else if it's a normal next ie "famguy/next"
							{
								EnvSub, FilePlaylistLines, 2
								IniRead, ContAlreadyPlayed, %FilePathArray3%, ContinuousList, ContinuousLines
								IniRead, ContIgnoreThese, %FilePathArray3%, CntIgnoreList, CntIgnoreLines
								ContDisabledLines = ¦%ContAlreadyPlayed%¦¦%ContIgnoreThese%¦
								SetEnv, ContPlaylistLNum, 101
								ContPlaylistLine = ¦%ContPlaylistLNum%¦
								SetEnv, ContWhileIndex, 101
								while (RegExMatch(ContDisabledLines, ContPlaylistLine))
								{
									EnvAdd, ContPlaylistLNum, 1
									ContPlaylistLine = ¦%ContPlaylistLNum%¦
									;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine%`r`n, %A_WorkingDir%\test.txt
									If (ContWhileIndex > FilePlaylistLines) ; if matched every time
									{
										IniDelete, %FilePathArray3%, ContinuousList, ContinuousLines
										ContAlreadyPlayed = ¦0¦
										;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine% AM`r`n, %A_WorkingDir%\test.txt
										Break
									}
									Else ; if havent matched
									{
										;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine% PM`r`n, %A_WorkingDir%\test.txt
										ContWhileIndex++
									}
								}
								FileAppend, %VidPath%`r`n, %A_WorkingDir%\mpvplaylist.txt
								FileRead, MPVQueueNum, %A_WorkingDir%\mpvqueuenum.txt
								EnvAdd, MPVQueueNum, 1
								FileDelete, %A_WorkingDir%\mpvqueuenum.txt
								FileAppend, %MPVQueueNum%, %A_WorkingDir%\mpvqueuenum.txt
								IniWrite, %ContPlaylistLine%%ContAlreadyPlayed%, %FilePathArray3%, ContinuousList, ContinuousLines
								;FileAppend, now=%A_Now% iteration=%A_Index% cont=%ContPlaylistLine% NM`r`n, %A_WorkingDir%\test.txt
								StringReplace ContPlaylistLine, ContPlaylistLine, ¦, , All
								FileReadLine, ContPlaylistPick, %FilePathArray3%, %ContPlaylistLine%
								StringSplit, ContPlaylistArray, ContPlaylistPick, 
								ContPlstFilename := ContPlaylistArray1
								ContWinTitleName := ContPlaylistArray2 ; ContWinTitleName = --title="👻 it is a mystery"
								ContFriendlyName := ContPlaylistArray3
								VidCompositePath = %ContPlstFilename%%VidFlagTime%%A_Space%%ContWinTitleName%
							}
						}
						Else
						{
							IfInString, FilePathFilenameFixed, rng
							{
								StringSplit, FilePathFilenameRNGArray, FilePathFilenameFixed, _
								FilePathFilenameRNG1 := FilePathFilenameRNGArray2
								FilePathFilenameRNG2 := FilePathFilenameRNGArray3
								Random, FilePathFilenameRNGResult, %FilePathFilenameRNG1%, %FilePathFilenameRNG2%
								FilePathFilenameFixed := FilePathFilenameRNGResult
							}
							Loop, read, %FilePathArray3%
							{
								StringSplit, FilePlaylistArray, A_LoopReadLine, 
								FilePlstFilename := FilePlaylistArray1
								FileWinTitleName := FilePlaylistArray2
								FileFriendlyName := FilePlaylistArray3
								IfInString, FileFriendlyName, %FilePathFilenameFixed%
								{
									VidCompositePath = %FilePlstFilename%%VidFlagTime%%A_Space%%FileWinTitleName%
									Break
								}
								Else
								{
									If (A_Index <= FilePlaylistLines)
									{
										Continue
									}
									Else If (A_Index > FilePlaylistLines)
									{
										VidCompositePath = wat-wrongfilereq
										Break
									}
								}
							}
						}
					}
					Break
				}
				Else
				{
					If (A_Index <= FilePathsLines)
					{
						Continue
					}
					Else If (A_Index > FilePathsLines)
					{
						VidCompositePath = wat-wrongdirreq
						Break
					}
				}
			}
		}
		Run, "C:\util\mpv\mpv.exe" %VidCompositePath% --no-config --input-conf=c:\users\owner\appdata\roaming\mpv\input.conf --no-fs --no-border --ontop --autofit=1280x720 --geometry=1280x720+1600+0 --audio-display=no --vo=direct3d --terminal=yes --force-window=yes --af=drc=2:0.25 --softvol --user-agent="Mozilla/5.0" --cache=auto --cache-initial=1000 --cache-pause --network-timeout=1 --script=C:\Users\Owner\AppData\Roaming\mpv\maws-assist.lua,C:\Users\Owner\AppData\Roaming\mpv\autoloop.lua
		CustomTitleAppend := ""
	}
	Else If InStr(VidPath, "4chan") and InStr(VidPath, "http") and InStr(VidPath, "thread")
	{
		StringSplit, URLChamSlashArray, VidPath, /
		URLChamDomain := URLChamSlashArray3
		URLChamBoard := URLChamSlashArray4
		StringSplit, URLChamPoundArray, URLChamSlashArray6, #
		URLChamThreadNum := URLChamPoundArray1
;		https://boards.4channel.org/wsg/thread/2515557/30-year-old-boomer-thread
;		URLChamJson = https://%URLChamDomain%/%URLChamBoard%/thread/%URLChamThreadNum%/
		URLChamJson = https://a.4cdn.org/%URLChamBoard%/thread/%URLChamThreadNum%.json
;		FileAppend, 1 %URLChamSlashArray1%`n2 %URLChamSlashArray2%`n3 %URLChamSlashArray3%`n4 %URLChamSlashArray4%`n5 %URLChamSlashArray5%`n6 %URLChamSlashArray6%`n7 %URLChamSlashArray7%`nb %URLChamBoard%`nt %URLChamThreadNum%`nj %URLChamJson%`n, %A_WorkingDir%\cham.txt
		FileDelete, %A_WorkingDir%\cham.txt
		UrlDownloadToFile, %URLChamJson%, %A_WorkingDir%\cham.txt
		Sleep, 500
		FileRead, ChamJsonContents, %A_WorkingDir%\cham.txt
		StringReplace, ChamJsonContents, ChamJsonContents, % Chr(125), `n, All
		StringReplace, ChamJsonContents, ChamJsonContents, % Chr(34), , All ;quot
		StringReplace, ChamJsonContents, ChamJsonContents, % Chr(58), , All ;coln
		StringReplace, ChamJsonContents, ChamJsonContents, % Chr(44), , All ;coma
		FileDelete, %A_WorkingDir%\cham2.txt
		FileAppend, %ChamJsonContents%, %A_WorkingDir%\cham2.txt
		FileDelete, %A_WorkingDir%\cham3.txt
		Loop, read, %A_WorkingDir%\cham2.txt
		{
			If InStr(A_LoopReadLine, "ext") and InStr(A_LoopReadLine, "tim")
			{
				ChamLoopExtPos := InStr(A_LoopReadLine, "ext", false, 1)+7
				StringMid, ChamLoopExt, A_LoopReadLine, ChamLoopExtPos, 5
				StringReplace, ChamLoopExt, ChamLoopExt, ,, All
				ChamLoopTimPos := InStr(A_LoopReadLine, "tim", false, 1)+6
				StringMid, ChamLoopTim, A_LoopReadLine, ChamLoopTimPos, 13
				FileAppend, https://i.4cdn.org/%URLChamBoard%/%ChamLoopTim%%ChamLoopExt%%A_Space%, %A_WorkingDir%\cham3.txt
			}
		}
;		"ext":".webm",
;		"tim":1543649900639,
;		https://i.4cdn.org/wsg/1543649900639.webm
		;StringSplit, VidThreadArray, VidPath, href`=`"//i.4cdn.org/
		;StringSplit, VidThreadArray, VidThreadArray2, target
		FileRead, ChamFullPlaylist, %A_WorkingDir%\cham3.txt
		Run, "C:\util\mpv\mpv.exe" %ChamFullPlaylist% --no-config --input-conf=c:\users\owner\appdata\roaming\mpv\input.conf --no-fs --no-border --ontop --autofit=1280x720 --geometry=1280x720+1600+0 --audio-display=no --vo=direct3d --terminal=yes --force-window=yes --af=drc=2:0.25 --softvol --user-agent="Mozilla/5.0" --cache=auto --cache-initial=1000 --cache-pause --network-timeout=1 --script=C:\Users\Owner\AppData\Roaming\mpv\maws-assist.lua,C:\Users\Owner\AppData\Roaming\mpv\autoloop.lua
		CustomTitleAppend := ""
	}
	Else IfInString, VidPath, http
	{
		IfInString, VidPath, vaughnlive
		{
			StringSplit, VidVaughnArray, VidPath, %A_Space%
			Run, "C:\Program Files (x86)\Livestreamer\livestreamer.exe" %VidVaughnArray1% best
			CustomTitleAppend := ""
		}
		Else
		{
			StringSplit, VidHttpArray, VidPath, %A_Space%
			Run, "C:\util\mpv\mpv.exe" %VidHttpArray1% --no-config --input-conf=c:\users\owner\appdata\roaming\mpv\input.conf --no-fs --no-border --ontop --autofit=1280x720 --geometry=1280x720+1600+0 --audio-display=no --vo=direct3d --slang=enUS`,en`,eng --terminal=yes --force-window=yes --af=drc=2:0.25 --softvol --user-agent="Mozilla/5.0" --cache=auto --cache-initial=1000 --cache-pause --network-timeout=1 --script=C:\Users\Owner\AppData\Roaming\mpv\maws-assist.lua,C:\Users\Owner\AppData\Roaming\mpv\autoloop.lua
			CustomTitleAppend := ""
		}
	}
	Else IfInString, VidPath, fullstop
	{
		FileDelete, %A_WorkingDir%\mpvqueuenum.txt
		FileAppend, 00, %A_WorkingDir%\mpvqueuenum.txt
		FileDelete, %A_WorkingDir%\mpvplaylist.txt
		FileDelete, %A_WorkingDir%\swim.status
		FileAppend, 0, %A_WorkingDir%\swim.status
		GoSub, ComEndPlaylist
	}
	Else
	{
		Run, "C:\util\mpv\mpv.exe" wat --no-config --input-conf=c:\users\owner\appdata\roaming\mpv\input.conf --no-fs --no-border --ontop --autofit=1280x720 --geometry=1280x720+1600+0 --audio-display=no --vo=direct3d --slang=enUS`,en`,eng --terminal=yes --force-window=yes --af=drc=2:0.25 --softvol --user-agent="Mozilla/5.0" --cache=auto --cache-initial=1000 --cache-pause --network-timeout=1 --script=C:\Users\Owner\AppData\Roaming\mpv\maws-assist.lua,C:\Users\Owner\AppData\Roaming\mpv\autoloop.lua
		CustomTitleAppend := ""
	}
	WinWait, ahk_class mpv
	Run, C:\util\nircmd.exe muteappvolume ehshell.exe 1
	IfWinExist, VLC (software RGB DirectX output)
		Run, C:\util\nircmd.exe muteappvolume vlc.exe 1
	SetTimer, ComProcessFS, 1000
	WinWaitClose, ahk_class mpv
	Gosub, ComDeterminePlaylist


ComEndPlaylist:
	FileDelete, %A_WorkingDir%\playing.status
	FileAppend, 0, %A_WorkingDir%\playing.status
	IfExist, %A_WorkingDir%\chanlocale.bkp
	{
		FileRead, ChanLocaleBKP, %A_WorkingDir%\chanlocale.bkp
		FileDelete, %A_WorkingDir%\chanlocale.txt
		FileAppend, %ChanLocaleBKP%, %A_WorkingDir%\chanlocale.txt
	}
	IfExist, %A_WorkingDir%\nowwatching.bkp
	{
		FileRead, NowWatchingBAK, %A_WorkingDir%\nowwatching.bkp
		FileDelete, %A_WorkingDir%\nowwatching.txt
		FileAppend, %NowWatchingBAK%, %A_WorkingDir%\nowwatching.txt
	}
	IfExist, %A_WorkingDir%\mpvprogress.txt
	{
		FileDelete, %A_WorkingDir%\mpvprogress.txt
	}
	IfWinExist, VLC (software RGB DirectX output)
	{
		Run, C:\util\nircmd.exe muteappvolume vlc.exe 0
	}
	Else
	{
		Run, C:\util\nircmd.exe muteappvolume ehshell.exe 0
	}
	FileDelete, %A_WorkingDir%\vidprocpl.pid
	FileDelete, %A_WorkingDir%\iskalreadyplayedvods.txt
	FileDelete, %A_WorkingDir%\isklatestalreadyplayedvods.txt
	WinClose, ahk_class HoneyView3Class
	WinClose, Twitch - Pale Moon
	WinActivate, ahk_class eHome Render Window
	WinSet Top,, Windows Media Center
	ExitApp

ComProcessFS:
	WinGetPos, MuhXpos, MuhYpos, MuhWidth, MuhHeight, ahk_class mpv
	If (MuhYPos = 1)
	{
		ControlSend, , f, ahk_class mpv
		WinGetTitle, MuhTitle, ahk_class mpv
		StringReplace, MuhTitle, MuhTitle, %A_Space%-%A_Space%mpv, ,
		FileDelete, %A_WorkingDir%\nowwatching.txt
		FileAppend, [#%VdNm%] %MuhTitle%%CustomTitleAppend%, %A_WorkingDir%\nowwatching.txt
		Exit
	}
	Else
	{
		;FileAppend, %A_Sec% %MuhXpos% %MuhYpos% %MuhWidth% %MuhHeight%`r`n, %A_WorkingDir%\checkitout.txt
		Sleep, 10
		;Return
	}
