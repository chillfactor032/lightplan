#include <./includes/IRC.au3>
#include <./includes/Json.au3>
#include <GUIConstantsEx.au3>
#include <GuiConstants.au3>
#include <ListViewConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>

; Options
Opt("TCPTimeout", 500)
Opt("GUIOnEventMode", 1)

; Contants
$version = "0.9"
$guiHeight = 600
$guiWidth = 600

;GUI Contruction
$gui = GUICreate("Light Plan v" & $version & " by ChillFactor032", $guiWidth, $guiHeight)

;Menu Items
$menuFile = GUICtrlCreateMenu("File")
$menuFileNewButton = GUICtrlCreateMenuItem("New Light Plan", $menuFile)
$menuFileOpenButton = GUICtrlCreateMenuItem("Open Light Plan", $menuFile)
$menuFileSaveButton = GUICtrlCreateMenuItem("Save Light Plan", $menuFile)
$menuFileExitButton = GUICtrlCreateMenuItem("Exit", $menuFile)
$menuHelp = GUICtrlCreateMenu("Help")
$menuHelpButton = GUICtrlCreateMenuItem("Help Light Plan", $menuHelp)
$menuAboutButton = GUICtrlCreateMenuItem("About Light Plan", $menuHelp)
$menuOAuthButton = GUICtrlCreateMenuItem("Get Twitch OAuth Token", $menuHelp)

;Light Plan Area
$planListView = GUICtrlCreateListView("Offset|Chat Command|Description                         ", 10, 10, $guiWidth-230, 250, -1, $LVS_EX_FULLROWSELECT)
GUICtrlCreateLabel("Add or Edit Event", $guiWidth-210, 10)
GUICtrlCreateLabel("Offset (mm:ss.SSS):", $guiWidth-210, 30)
$eventOffsetField = GUICtrlCreateInput("", $guiWidth-210, 50, 200)
GUICtrlCreateLabel("Chat Command:", $guiWidth-210, 80)
$eventCmdField = GUICtrlCreateInput("", $guiWidth-210, 100, 200)
GUICtrlCreateLabel("Description", $guiWidth-210, 130)
$eventDescField = GUICtrlCreateInput("", $guiWidth-210, 150, 200)
$eventSaveButton = GUICtrlCreateButton("Update Event", $guiWidth-90, 180, 80)
$eventNewButton = GUICtrlCreateButton("Add Event", $guiWidth-210, 180, 80)
$clearEventButton = GUICtrlCreateButton("Clear", $guiWidth-90, 25, 80, 20)
$deleteEventButton = GUICtrlCreateButton("Delete Event", $guiWidth-210, 225, 80)
GUICtrlCreateLabel("",$guiWidth-210,260,200,2,$SS_SUNKEN)
GUICtrlCreateLabel("Song Artist - Title: ", 10, 275)
$songArtistTitleField = GUICtrlCreateInput("", 100, 273, 280)
GUICtrlCreateLabel("Light Plan Author:", 10, 300)
$lightPlanAuthorField = GUICtrlCreateInput("", 100, 297, 280)
$startPlanButton = GUICtrlCreateButton("Start Light Plan", $guiWidth-210, 270, 200, 50)
GUICtrlSetFont($startPlanButton, 16, $FW_HEAVY)
GUICtrlCreateLabel("",10,325,$guiWidth-20,2,$SS_SUNKEN)
GUICtrlSetState($startPlanButton, $GUI_DISABLE)

;Twitch Connection Area
GUICtrlCreateGroup("Twitch Chat Connection", 10, 330, 215, 130)
GUICtrlCreateLabel("Twitch User:", 38, 350)
$twitchUserField = GUICtrlCreateInput("", 100, 347, 120)
GUICtrlCreateLabel("OAuth Token:", 30, 380)
$twitchOAuthField = GUICtrlCreateInput("", 100, 377, 120, Default, $ES_PASSWORD)
GUICtrlCreateLabel("Twitch Channel:", 20, 410)
$twitchChannelField = GUICtrlCreateInput("", 100, 407, 120)
$twitchConnectButton = GUICtrlCreateButton("Connect to Twitch", 20, 430, 200)

;Stream Delay Area
GUICtrlCreateGroup("Stream Delay", 10, 460, 215, 110)
GUICtrlCreateLabel("Delay: ", 55, 517)
$delayLeftButton = GUICtrlCreateButton("<", 90, 515, 20, 20)
$streamDelayField = GUICtrlCreateInput("0", 115, 515, 70, Default, $ES_READONLY)
$delayRightButton = GUICtrlCreateButton(">", 190, 515, 20, 20)
$calcDelayButton = GUICtrlCreateButton("Calculate Stream Delay", 20, 480, 200, 25)
GUICtrlCreateLabel("Shift Timeline:", 20, 550)
$shiftLeftButton = GUICtrlCreateButton("<", 90, 545, 20, 20)
$shiftField = GUICtrlCreateInput("0", 115, 545, 70, Default, $ES_READONLY)
$shiftRightButton = GUICtrlCreateButton(">", 190, 545, 20, 20)

;Status Area
GUICtrlCreateGroup("Status", 230, 330, 360, 240)
$timeElapsedLabel = GUICtrlCreateLabel("Time Elapsed: 00:00.000", 250, 350)
$eventsFiredLabel = GUICtrlCreateLabel("Events Fired: 000/000", 250, 370, 100)
$statusEdit = GUICtrlCreateEdit("", 240, 390, 340, 170, $ES_MULTILINE+$ES_READONLY+$WS_VSCROLL)
GUICtrlSetBkColor($statusEdit, $COLOR_WHITE)
GUICtrlSetFont($statusEdit, 8.5, Default, Default, "Courier New")
statusMsg("Light Plan v" & $version)

;Register Event Listeners for GUI Components
GUISetOnEvent($GUI_EVENT_CLOSE, "menuExit")
GUICtrlSetOnEvent($menuFileExitButton, "menuExit")
GUICtrlSetOnEvent($menuFileNewButton, "menuNewLightPlan")
GUICtrlSetOnEvent($menuFileOpenButton, "menuOpenLightPlan")
GUICtrlSetOnEvent($menuFileSaveButton, "menuSaveLightPlan")
GUICtrlSetOnEvent($menuHelpButton, "menuHelp")
GUICtrlSetOnEvent($menuAboutButton, "menuAbout")
GUICtrlSetOnEvent($eventNewButton, "newEventButton")
GUICtrlSetOnEvent($eventSaveButton, "saveEventButton")
GUICtrlSetOnEvent($planListView, "planListView")
GUICtrlSetOnEvent($clearEventButton, "clearEventEditFields")
GUICtrlSetOnEvent($deleteEventButton, "deleteSelectedEvent")
GUICtrlSetOnEvent($menuOAuthButton, "showOAuthLink")
GUICtrlSetOnEvent($delayLeftButton, "delayLeftButton")
GUICtrlSetOnEvent($delayRightButton, "delayRightButton")
GUICtrlSetOnEvent($shiftLeftButton, "shiftLeftButton")
GUICtrlSetOnEvent($shiftRightButton, "shiftRightButton")
GUICtrlSetOnEvent($twitchConnectButton, "twitchConnectButton")
GUICtrlSetOnEvent($calcDelayButton, "calcStreamDelay")
GUICtrlSetOnEvent($startPlanButton, "startPlanButton")

;Global Variables
Dim $eventArray[1][3]
$eventArray[0][0] = 0
$eventArray[0][1] = 0
$eventArray[0][2] = 0
$oldValue = 0
$delayStep = 100
$streamDelay = 0
$shiftDelay = 0
$connected = False
$ircSocket = 0
$startLightPlan = False
$window = 5
$currentFile = ""
$elapsedTimer = 0
$currentFile = ""

;PreScript Actions
GUISetState(@SW_SHOW)
_GUICtrlListView_SortItems(GUICtrlGetHandle($planListView), 0)
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
TCPStartup()
readConfig()

;Main Loop
While True
   Sleep(25)
   If $startLightPlan == True Then
	  $channel = GUICtrlRead($twitchChannelField)
	  $elapsed = 0
	  $events = getAllEvents()

	  ;Convert OffSets Back to Ms
	  For $i = 0 To UBound($events)-1
		 $events[$i][0] = timeToMs($events[$i][0])
	  Next

	  ;Start timers to track stuff
	  $elapsedTimer = TimerInit()
	  $startTime = TimerInit()

	  $eventsFired = 0
	  $eventInitialCount = UBound($events)

	  ;Light Plan is Running
	  While $startLightPlan == True
		 ;Keep up with the time elapsed since light plan start
		 $elapsed = TimerDiff($startTime)

		 ;Check to see if an event is supposed to fire
		 If ($elapsed-$shiftDelay+$window) >= ($events[0][0]-$streamDelay) Then
			sendSingleMsg($events[0][1], $channel)
			$delta = $elapsed - $events[0][0]
			If $delta >= 0 Then
			   $delta = "+" & Round($delta,0)
			Else
			   $delta = Round($delta, 0)
			EndIf
			statusMsg("Firing Event: " & $events[0][1] & " @ " & Round($elapsed, 0) & " " & $delta)
			_ArrayDelete($events, 0)
			$eventsFired+=1
			GUICtrlSetData($eventsFiredLabel, "Events Fired: "& $eventsFired & "/" & $eventInitialCount)
			If UBound($events) == 0 Then
			   statusMsg("All Light Events Fired")
			   startPlanButton()
			   ExitLoop
			EndIf
		 EndIf

		 ;Update the GUI for time elapsed 4 times per sec
		 If TimerDiff($elapsedTimer) >= 250 Then
			GUICtrlSetData($timeElapsedLabel, "Time Elapsed: " & msToTimeFormat($elapsed, False))
			$elapsedTimer = TimerInit()
		 EndIf

		 ;Give the CPU a rest
		 Sleep(2)
	  WEnd
   EndIf
WEnd

Func readConfig()
   If Not FileExists("lightplan.config") Then
	  Return
   EndIf

   statusMsg("Reading Config: lightplan.config")

   $currentFile = IniRead(@ScriptDir&"\lightplan.config", "LightPlan", "LastFile", "")
   Local $user = IniRead(@ScriptDir&"\lightplan.config", "Twitch", "User", "")
   Local $channel = IniRead(@ScriptDir&"\lightplan.config", "Twitch", "Channel", "")
   Local $oauth = IniRead(@ScriptDir&"\lightplan.config", "Twitch", "OAuthToken", "")

   GUICtrlSetData($twitchUserField, $user)
   GUICtrlSetData($twitchOAuthField, $oauth)
   GUICtrlSetData($twitchChannelField, $channel)

   loadEventsFromJsonFile($currentFile)
EndFunc

Func saveConfig()
   Local $user = GUICtrlRead($twitchUserField)
   Local $channel = GUICtrlRead($twitchChannelField)
   Local $oauth = GUICtrlRead($twitchOAuthField)
   IniWrite(@ScriptDir&"\lightplan.config", "LightPlan", "LastFile", $currentFile)
   IniWrite(@ScriptDir&"\lightplan.config", "Twitch", "User", $user)
   IniWrite(@ScriptDir&"\lightplan.config", "Twitch", "Channel", $channel)
   IniWrite(@ScriptDir&"\lightplan.config", "Twitch", "OAuthToken", $oauth)
   statusMsg("Saved Config: lightplan.config")
EndFunc

Func handleIRCMsgs()
   ;Future Handle Twitch IRC Ping
EndFunc

Func msToTimeFormat($ms, $includeMS = True)
   Local $min = Floor(($ms / 1000) / 60)
   Local $sec = Floor($ms/1000) - ($min*60)
   $ms = $ms - ($min*60*1000) - ($sec*1000)
   If $includeMs Then
	  Return StringFormat("%02d:%02d.%03d", $min, $sec, $ms)
   EndIf
   Return StringFormat("%02d:%02d", $min, $sec)
EndFunc

Func timeToMs($time)
   ;Time in 00:00.000 Format
   Local $split = StringSplit($time, ":")
   If $split[0] < 2 Then
	  Return SetError(1, 0, 0)
   EndIf

   Local $mins = Number($split[1])

   $split = StringSplit($split[2], ".")
   If $split[0] < 2 Then
	  Return SetError(1, 0, 0)
   EndIf

   Local $secs = Number($split[1])
   While StringLen($split[2]) < 3
	  $split[2] &=  "0"
   WEnd

   Local $mili = Number($split[2]) + ($secs*1000) + ($mins * 60 *1000)
   Return $mili
EndFunc

Func startPlanButton()
   If $startLightPlan Then
	  $startLightPlan = False
	  GUICtrlSetState($eventNewButton, $GUI_ENABLE)
	  GUICtrlSetState($eventSaveButton, $GUI_ENABLE)
	  GUICtrlSetState($clearEventButton, $GUI_ENABLE)
	  GUICtrlSetState($deleteEventButton, $GUI_ENABLE)
	  GUICtrlSetState($twitchConnectButton, $GUI_ENABLE)
	  GUICtrlSetState($eventOffsetField, $GUI_ENABLE)
	  GUICtrlSetState($eventCmdField, $GUI_ENABLE)
	  GUICtrlSetState($eventDescField, $GUI_ENABLE)
	  GUICtrlSetState($calcDelayButton, $GUI_ENABLE)
	  GUICtrlSetState($twitchOAuthField, $GUI_ENABLE)
	  GUICtrlSetState($twitchUserField, $GUI_ENABLE)
	  GUICtrlSetState($twitchChannelField, $GUI_ENABLE)
	  GUICtrlSetData($startPlanButton, "Start Light Plan")
	  GUICtrlSetColor($startPlanButton, $COLOR_BLACK)
	  GUICtrlSetData($timeElapsedLabel, "Time Elapsed: 00:00.000")
	  statusMsg("Light Plan Stopped")
   Else
	  GUICtrlSetState($eventNewButton, $GUI_DISABLE)
	  GUICtrlSetState($eventSaveButton, $GUI_DISABLE)
	  GUICtrlSetState($clearEventButton, $GUI_DISABLE)
	  GUICtrlSetState($deleteEventButton, $GUI_DISABLE)
	  GUICtrlSetState($twitchConnectButton, $GUI_DISABLE)
	  GUICtrlSetState($calcDelayButton, $GUI_DISABLE)
	  GUICtrlSetState($eventOffsetField, $GUI_DISABLE)
	  GUICtrlSetState($eventCmdField, $GUI_DISABLE)
	  GUICtrlSetState($eventDescField, $GUI_DISABLE)
	  GUICtrlSetState($twitchOAuthField, $GUI_DISABLE)
	  GUICtrlSetState($twitchUserField, $GUI_DISABLE)
	  GUICtrlSetState($twitchChannelField, $GUI_DISABLE)
	  $startLightPlan = True
	  GUICtrlSetData($startPlanButton, "Stop Light Plan")
	  GUICtrlSetColor($startPlanButton, $COLOR_RED)
	  statusMsg("Light Plan Started")
   EndIf
EndFunc

Func calcStreamDelay()
   Local $in = InputBox("Calc Stream Delay", "Enter a message to send to the Twitch chat." & @CRLF & @CRLF & "Dismiss the next message when you see it hit the chat.")
   If StringLen($in) == 0 Then Return
   Local $hTimer = TimerInit()
   Local $channel = GUICtrlRead($twitchChannelField)
   sendSingleMsg($in, $channel)
   MsgBox(0, "Stream Delay", "Dismiss this dialog when your message hits the stream")
   Local $fDiff = TimerDiff($hTimer)
   $streamDelay = Round($fDiff, 0)
   statusMsg("Stream Delay: " & $streamDelay & " ms")
   GUICtrlSetData($streamDelayField, Round($streamDelay/1000, 1) & " s")
EndFunc

Func streamDelayChange($change)
   $streamDelay += $change
   If $streamDelay < 0 Then $streamDelay = 0
   GUICtrlSetData($streamDelayField, Round($streamDelay/1000, 1) & " s")
EndFunc

Func shiftTimelineChange($change)
   $shiftDelay += $change
   GUICtrlSetData($shiftField, Round($shiftDelay/1000, 1) & " s")
EndFunc

Func delayLeftButton()
   streamDelayChange(-1*$delayStep)
EndFunc

Func delayRightButton()
   streamDelayChange($delayStep)
EndFunc

Func shiftRightButton()
   shiftTimelineChange($delayStep)
EndFunc

Func shiftLeftButton()
   shiftTimelineChange(-1*$delayStep)
EndFunc

Func showOAuthLink()
   $ret = MsgBox($MB_YESNOCANCEL, "Twitch OAuth Token", "Go to the following link to get a new OAuth Token for Twitch:" _
	  & @CRLF & @CRLF & "https://twitchapps.com/tmi/" & @CRLF & @CRLF _
	  & "This token allows this tool to post messages to the Twitch Chat. " _
	  & @CRLF & @CRLF & "Go there now?")

   If $ret == $IDYES Then
	  ShellExecute("http://twitchapps.com/tmi/")
   EndIf
EndFunc

Func planListView()
   ;statusMsg("Plan List View")
EndFunc

Func clearEventEditFields()
   GUICtrlSetData($eventOffsetField, "")
   GUICtrlSetData($eventCmdField, "")
   GUICtrlSetData($eventDescField, "")
   _GUICtrlListView_SetItemSelected($planListView, -1, False)
EndFunc

Func deleteSelectedEvent()
   $selection = _GUICtrlListView_GetSelectedIndices($planListView, True)
   If $selection[0] == 0 Then Return

   _GUICtrlListView_DeleteItemsSelected($planListView)
   clearEventEditFields()
EndFunc

Func updatePlanListView()
   GUICtrlSetData($eventsFiredLabel, "Events Fired: 0/" & _GUICtrlListView_GetItemCount($planListView))
   _GUICtrlListView_SimpleSort($planListView, False, 0, False)
EndFunc

Func addEventToListView($offset, $cmd, $desc)

   If StringRegExp($offset, "[^:\.0-9]") == 1 Then
	  MsgBox($MB_ICONERROR, "Error", "Badly formmated offset. Try the following format:" & @CRLF & @CRLF & "01:23.456")
	  Return
   EndIf

   Local $msTest = timeToMs($offset)
   If @error > 0 Then
	  MsgBox($MB_ICONERROR, "Error", "Badly formmated offset. Try the following format:" & @CRLF & @CRLF & "01:23.456")
	  Return
   EndIf

   $offset = msToTimeFormat($msTest)

   $index = _GUICtrlListView_AddItem($planListView, $offset)
   _GUICtrlListView_AddSubItem($planListView, $index, $cmd, 1)
   _GUICtrlListView_AddSubItem($planListView, $index, $desc, 2)
   updatePlanListView()
EndFunc

Func updateEventInListView($index, $offset, $cmd, $desc)
   _GUICtrlListView_SetItem($planListView, $offset, $index, 0)
   _GUICtrlListView_SetItem($planListView, $cmd, $index, 1)
   _GUICtrlListView_SetItem($planListView, $desc, $index, 2)

   updatePlanListView()
EndFunc

Func newEventButton()
   ;statusMsg("New Event Button")
   Dim $newEventArr[3]
   $newEventArr[0] = GUICtrlRead($eventOffsetField)
   $newEventArr[1] = GUICtrlRead($eventCmdField)
   $newEventArr[2] = GUICtrlRead($eventDescField)

   If StringLen($newEventArr[0]) == 0 Or StringLen($newEventArr[1]) == 0  Then
	  MsgBox($MB_ICONERROR, "Error", "Offset or Command cannot be empty")
	  Return
   EndIf
   addEventToListView($newEventArr[0], $newEventArr[1], $newEventArr[2])
EndFunc

Func saveEventButton()
   ;statusMsg("Save Event Button")
   Dim $newEventArr[3]
   $newEventArr[0] = GUICtrlRead($eventOffsetField)
   $newEventArr[1] = GUICtrlRead($eventCmdField)
   $newEventArr[2] = GUICtrlRead($eventDescField)

   If StringLen($newEventArr[0]) == 0 Or StringLen($newEventArr[1]) == 0  Then
	  MsgBox($MB_ICONERROR, "Error", "Offset or Command cannot be empty")
	  Return
   EndIf

   $selection = _GUICtrlListView_GetSelectedIndices($planListView, True)
   If $selection[0] == 0 Then Return
   updateEventInListView($selection[1], $newEventArr[0], $newEventArr[1], $newEventArr[2])
EndFunc

Func menuOpenLightPlan()
   ;statusMsg("Menu: Open Light Plan")
   $path = FileOpenDialog("Open Light Plan", @workingdir, "JSON Files (*.json)", "", $gui)
   If @error <> 0 Then Return
   loadEventsFromJsonFile($path)
EndFunc

Func menuNewLightPlan()
   ;statusMsg("Menu: New Light Plan")
   Local $ret = MsgBox($MB_YESNO, "New Light Plan", "Did you want to save what you were doing first?")
   If $ret == $IDYES Then
	  saveEventButton()
   EndIf
   clearGUI()
EndFunc

Func menuSaveLightPlan()
   ;statusMsg("Menu: Save Light Plan")
   $dir = @WorkingDir
   If @WorkingDir == @ScriptDir Then
	  $dir = @MyDocumentsDir
   EndIf
   $suggestedFileName = GUICtrlRead($songArtistTitleField)
   $suggestedFileName = StringReplace($suggestedFileName, " ", "_")
   $suggestedFileName = StringRegExpReplace($suggestedFileName, "[^0-9a-Z_-]", "")
   $path = FileSaveDialog("Save Light Plan", $dir, "JSON Files (*.json)", $FD_PROMPTOVERWRITE, $suggestedFileName, $gui)
   saveEventsJsonFile($path)
EndFunc

Func clearGUI()
   _GUICtrlListView_DeleteAllItems($planListView)
   GUICtrlSetData($songArtistTitleField, "")
   GUICtrlSetData($lightPlanAuthorField, "")
   GUICtrlSetData($eventDescField, "")
   GUICtrlSetData($eventCmdField, "")
   GUICtrlSetData($eventOffsetField, "")
   $currentFile = ""
EndFunc

Func loadEventsFromJsonFile($path)
   $str = FileRead($path)
   If @error <> 0 Then
	  Return
   EndIf

   If validateJsonFile($str) Then
	  clearGUI()
	  $jsonObj = Json_Decode($str)
	  GUICtrlSetData($songArtistTitleField, Json_ObjGet($jsonObj, ".light_plan.song_artist_title"))
	  GUICtrlSetData($lightPlanAuthorField, Json_ObjGet($jsonObj, ".light_plan.author"))
	  $events = Json_ObjGet($jsonObj, ".light_plan.events")
	  For $evt In $events
		 addEventToListView(Json_ObjGet($evt, ".offset"),Json_ObjGet($evt, ".command"),Json_ObjGet($evt, ".description"))
	  Next
	  statusMsg("Loaded Light Plan File:")
	  statusMsg($path)
	  $currentFile = $path
   Else
	  $currentFile = ""
   EndIf
EndFunc

Func menuExit()
   statusMsg("Exiting")
   If $connected == True Then twitchDisconnect()
   TCPShutdown()
   saveConfig()
   Exit
EndFunc

Func menuHelp()
   ;statusMsg("Menu: Help")
   Local $ret = MsgBox($MB_YESNO, "LightPlan Help", "Help documentation is best found on GitHub." & @CRLF & @CRLF _
	  & "https://github.com/chillfactor032/lightplan/blob/master/README.md" & @CRLF & @CRLF _
	  & "Go there now?")
   If $ret = $IDYES Then
	  ShellExecute("https://github.com/chillfactor032/lightplan/blob/master/README.md")
   EndIf
EndFunc

Func menuAbout()
   MsgBox(0, "About LightPlan", "Version: LightPlan v" & $version & @CRLF & @CRLF _
	  & "Author: chillfactor032" & @CRLF _
	  & "Email: chill@chillaspect.com" & @CRLF _
	  & "GitHub: https://github.com/chillfactor032/lightplan" & @CRLF _
	  & "Discord: ChillFacToR#2906" & @CRLF)
EndFunc

Func planListViewItemClick()
   $selection = _GUICtrlListView_GetSelectedIndices($planListView, True)
   If $selection[0] == 0 Then Return
   $selectedItem = _GUICtrlListView_GetItemTextArray($planListView, $selection[1])
   If $selectedItem[0] == 0 Then Return
   GUICtrlSetData($eventOffsetField, $selectedItem[1])
   GUICtrlSetData($eventCmdField, $selectedItem[2])
   GUICtrlSetData($eventDescField, $selectedItem[3])
EndFunc

Func getAllEvents()
   Dim $events[1][3]
   $itemCount = _GUICtrlListView_GetItemCount($planListView)
   Dim $t[1][3]
   For $i = 0 To $itemCount-1
	  $arr = _GUICtrlListView_GetItemTextArray($planListView, $i)
	  $t[0][0] = $arr[1]
	  $t[0][1] = $arr[2]
	  $t[0][2] = $arr[3]
	  _ArrayAdd($events, $t)
   Next
   _ArrayDelete($events, 0)
   Return $events
EndFunc

Func validateJsonFile($jsonStr)
   Local $data = Json_Decode($jsonStr)
   If @Error < 0 Then
	  Return False
   EndIf
   Return True
EndFunc

Func saveEventsJsonFile($filePath)
   Local $jsonObj = Json_ObjCreate()
   Local $songArtistTitle = GUICtrlRead($songArtistTitleField)
   Local $lightPlanAuthor = GUICtrlRead($lightPlanAuthorField)

   Json_Put($jsonObj, ".light_plan.song_artist_title", $songArtistTitle)
   Json_Put($jsonObj, ".light_plan.author", $lightPlanAuthor)
   $events = getAllEvents()

   For $i = 0 To Ubound($events)-1
	  Json_Put($jsonObj, ".light_plan.events[" & $i & "].offset", $events[$i][0])
	  Json_Put($jsonObj, ".light_plan.events[" & $i & "].command", $events[$i][1])
	  Json_Put($jsonObj, ".light_plan.events[" & $i & "].description", $events[$i][2])
   Next

   $file = FileOpen($filePath, $FO_OVERWRITE)
   FileWrite($file, Json_Encode_Pretty($jsonObj, 0, @TAB, ","&@CRLF, ","&@CRLF, ": "))
   FileClose($file)
EndFunc

Func statusMsg($msg)
   ConsoleWrite($msg&@CRLF)
   ;Local $status = @CRLF & @HOUR & ":" & @MIN & ":" & @SEC & " - " & $msg
   $msg = StringStripCR($msg)
   _GUICtrlEdit_AppendText($statusEdit, $msg&@CRLF)
   _GUICtrlEdit_Scroll($statusEdit, $SB_SCROLLCARET)
EndFunc

Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
   #forceref $hWnd, $iMsg, $wParam
   Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView, $tInfo
   ; Local $tBuffer
   $hWndListView = $planListView
   If Not IsHWnd($planListView) Then $hWndListView = GUICtrlGetHandle($planListView)

   $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
   $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
   $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
   $iCode = DllStructGetData($tNMHDR, "Code")
   Switch $hWndFrom
	  Case $hWndListView
	  Switch $iCode
		 Case $NM_CLICK
			;statusMsg("List View Clicked")
			planListViewItemClick()
	  EndSwitch
   EndSwitch
   Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

Func twitchConnect($user, $oauth, $channel)
   Local $result = False

   $ircSocket = _IRCConnect("irc.chat.twitch.tv", 6667, $user, 0, $user, $oauth)

   If $ircSocket == 0 Then
	  statusMsg("Error connecting to Twitch Chat IRC")
	  Return $result
   EndIf

   Local $sRecv = ""
   Local $msgs = collectTwitchMsgs($ircSocket)

   If $msgs[0] == 0 Then
	  statusMsg("No messages recieved from Twitch IRC")
	  $ircSocket = 0
	  Return False
   EndIf

   Local $sTemp = StringSplit($msgs[1], " ")
   Switch $sTemp[2]
	  Case $RPL_WELCOME
		 $sRecv = _IRCChannelJoin($ircSocket, "#" & $channel)
		 $msgs = collectTwitchMsgs($ircSocket)
		 If $msgs[0] > 0 And StringInStr($msgs[1], "JOIN") > 0 Then
			$result = True
		 Else
			statusMsg("Cannot join channel: " & $channel)
			MsgBox($MB_ICONERROR, "Error", "Cannot join channel, check spelling?")
		 EndIf
   EndSwitch
   Return $result
EndFunc

Func twitchDisconnect()
   _IRCDisconnect($ircSocket)
   $ircSocket = 0
   $connected = False
   statusMsg("Disconnected from Twitch Chat")
EndFunc

Func collectTwitchMsgs($socket)
   Dim $resp[1]
   $resp[0] = 0
   Do
	  $sRecv = _IRCGetMsg($socket)
	  ;statusMsg($sRecv)
	  _ArrayAdd($resp, $sRecv)
	  $resp[0] += 1
   Until StringLen($sRecv)==0
   Return $resp
EndFunc

Func twitchConnectButton()
   Local $user = GUICtrlRead($twitchUserField)
   Local $oauth = GUICtrlRead($twitchOAuthField)
   Local $channel = GUICtrlRead($twitchUserField)

   ;User wants to disconnect from Twitch
   If $connected == True Then
	  twitchDisconnect()
	  GUICtrlSetData($twitchConnectButton, "Connect to Twitch")
	  GUICtrlSetColor($twitchConnectButton, $COLOR_BLACK)
	  GUICtrlSetState($twitchUserField, $GUI_ENABLE)
	  GUICtrlSetState($twitchOAuthField, $GUI_ENABLE)
	  GUICtrlSetState($twitchChannelField, $GUI_ENABLE)
	  GUICtrlSetState($startPlanButton, $GUI_DISABLE)
   Else
	  ;User Connecting to Twitch
	  $connected = twitchConnect($user, $oauth, $channel)
	  If $connected Then
		 GUICtrlSetData($twitchConnectButton, "Disconnect from Twitch")
		 GUICtrlSetColor($twitchConnectButton, $COLOR_RED)
		 GUICtrlSetState($twitchUserField, $GUI_DISABLE)
		 GUICtrlSetState($twitchOAuthField, $GUI_DISABLE)
		 GUICtrlSetState($twitchChannelField, $GUI_DISABLE)
		 GUICtrlSetState($startPlanButton, $GUI_ENABLE)
		 statusMsg("Connected to Twitch Chat")
		 $pingTimer = TimerInit()
	  Else
		 statusMsg("Error Connecting to Twitch Chat")
		 GUICtrlSetData($twitchConnectButton, "Connect to Twitch")
		 GUICtrlSetColor($twitchConnectButton, $COLOR_BLACK)
		 GUICtrlSetState($twitchUserField, $GUI_ENABLE)
		 GUICtrlSetState($twitchOAuthField, $GUI_ENABLE)
		 GUICtrlSetState($twitchChannelField, $GUI_ENABLE)
		 GUICtrlSetState($startPlanButton, $GUI_DISABLE)
	  EndIf
   EndIf
EndFunc

Func sendSingleMsg($singleMsg, $channel)
   If $connected == False Then Return False
   _IRCRaw($ircSocket, "PRIVMSG #" & $channel & " :" & $singleMsg)
EndFunc
