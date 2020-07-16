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
$VERSION = "0.93"
$GUI_HEIGHT = 650
$GUI_WIDTH = 650
$CONFIG_DIR = @LocalAppDataDir & "\LightPlan"

;GUI Contruction
$gui = GUICreate("LightPlan v" & $VERSION & " by ChillFactor032", $GUI_WIDTH, $GUI_HEIGHT)

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
GUICtrlCreateGroup("Light Plan", 5, 5, 400, 450)
GUICtrlCreateLabel("Song Artist - Title: ", 15, 30)
$songArtistTitleField = GUICtrlCreateInput("", 115, 27, 280)
GUICtrlCreateLabel("Light Plan Author:", 15, 60)
$lightPlanAuthorField = GUICtrlCreateInput("", 115, 57, 280)
$planListView = GUICtrlCreateListView("Offset|Chat Command|Description                            ", 15, 90, 380, 320, $LVS_SHOWSELALWAYS)
$eventNewButton = GUICtrlCreateButton("Add Event", 15, 420, 80)
$eventEditButton = GUICtrlCreateButton("Edit Event", 165, 420, 80)
$deleteEventButton = GUICtrlCreateButton("Delete Event", 315, 420, 80)
GUICtrlSetState($eventEditButton, $GUI_DISABLE)
GUICtrlSetState($deleteEventButton, $GUI_DISABLE)

;Twitch Connection Area
GUICtrlCreateGroup("Twitch Chat Connection", 410, 5, 230, 150)
GUICtrlCreateLabel("Twitch User:", 427, 30)
$twitchUserField = GUICtrlCreateInput("", 490, 27, 140)
GUICtrlCreateLabel("OAuth Token:", 420, 60)
$twitchOAuthField = GUICtrlCreateInput("", 490, 57, 140, Default, BitOR($ES_PASSWORD,$ES_AUTOHSCROLL))
GUICtrlCreateLabel("Channel:", 445, 90)
$twitchChannelField = GUICtrlCreateInput("", 490, 87, 140)
$twitchConnectButton = GUICtrlCreateButton("Connect to Twitch", 420, 120, 210)

;Stream Delay Area
GUICtrlCreateGroup("Stream Delay", 410, 160, 230, 120)
GUICtrlCreateLabel("Delay: ", 469, 182)
$delayLeftButton = GUICtrlCreateButton("<", 510, 180, 20, 20)
$streamDelayField = GUICtrlCreateInput("0 s", 535, 180, 70, Default, $ES_READONLY)
$delayRightButton = GUICtrlCreateButton(">", 610, 180, 20, 20)
GUICtrlCreateLabel("Shift Timeline:", 433, 212)
$shiftLeftButton = GUICtrlCreateButton("<", 510, 210, 20, 20)
$shiftField = GUICtrlCreateInput("0 s", 535, 210, 70, Default, $ES_READONLY)
$shiftRightButton = GUICtrlCreateButton(">", 610, 210, 20, 20)
$calcDelayButton = GUICtrlCreateButton("Calculate Stream Delay", 420, 240, 210)

;Control Area
GUICtrlCreateGroup("Control", 410, 285, 230, 170)
$includeDescCheckBox = GUICtrlCreateCheckbox("Include Description in Command",  420, 305)
$timeElapsedLabel = GUICtrlCreateLabel("Time Elapsed: 00:00.000", 420, 335)
$eventsFiredLabel = GUICtrlCreateLabel("Events Fired: 0/0", 425, 355, 150)
$nextEventLabel = GUICtrlCreateLabel("Next Event: ", 431, 375, 150)
$startPlanButton = GUICtrlCreateButton("Start Light Plan", 420, 395, 210, 50)
GUICtrlSetFont($startPlanButton, 16, $FW_HEAVY)
GUICtrlSetState($startPlanButton, $GUI_DISABLE)

;Status Area
GUICtrlCreateGroup("Status", 5, 460, 635, 168)
$statusEdit = GUICtrlCreateEdit("Light Plan v" & $VERSION, 10, 475, 625, 150, BitOR($ES_AUTOVSCROLL,$ES_AUTOHSCROLL,$ES_READONLY,$WS_VSCROLL,$ES_MULTILINE))
GUICtrlSetBkColor($statusEdit, $COLOR_WHITE)
GUICtrlSetFont($statusEdit, 8.5, Default, Default, "Courier New")

;Event Editor Dialog
$eventEditDialog = GUICreate("Add or Edit Event", 190, 220, Default, Default, $WS_DLGFRAME, $WS_EX_TOPMOST)
GUICtrlCreateLabel("Offset (mm:ss.SSS):", 10, 10)
$eventOffsetField = GUICtrlCreateInput("", 10, 30, 165)
GUICtrlCreateLabel("Command:", 10, 60)
$eventCmdField = GUICtrlCreateInput("", 10, 80, 165)
GUICtrlCreateLabel("Description:", 10, 110)
$eventDescField = GUICtrlCreateInput("", 10, 130, 165)
$eventDialogSaveButton = GUICtrlCreateButton("Save Event", 10, 160, 80)
$eventDialogCancelButton = GUICtrlCreateButton("Cancel", 115, 160, 60)

;Register Event Listeners for GUI Components
GUISetOnEvent($GUI_EVENT_CLOSE, "menuExit", $gui)
GUISetOnEvent($GUI_EVENT_CLOSE, "toggleEventDialog", $eventEditDialog)
GUICtrlSetOnEvent($menuFileExitButton, "menuExit")
GUICtrlSetOnEvent($menuFileNewButton, "menuNewLightPlan")
GUICtrlSetOnEvent($menuFileOpenButton, "menuOpenLightPlan")
GUICtrlSetOnEvent($menuFileSaveButton, "menuSaveLightPlan")
GUICtrlSetOnEvent($menuHelpButton, "menuHelp")
GUICtrlSetOnEvent($menuAboutButton, "menuAbout")
GUICtrlSetOnEvent($eventNewButton, "newEventButton")
GUICtrlSetOnEvent($eventEditButton, "saveEventButton")
GUICtrlSetOnEvent($planListView, "planListView")
GUICtrlSetOnEvent($deleteEventButton, "deleteSelectedEvent")
GUICtrlSetOnEvent($menuOAuthButton, "showOAuthLink")
GUICtrlSetOnEvent($delayLeftButton, "delayLeftButton")
GUICtrlSetOnEvent($delayRightButton, "delayRightButton")
GUICtrlSetOnEvent($shiftLeftButton, "shiftLeftButton")
GUICtrlSetOnEvent($shiftRightButton, "shiftRightButton")
GUICtrlSetOnEvent($twitchConnectButton, "twitchConnectButton")
GUICtrlSetOnEvent($calcDelayButton, "calcStreamDelay")
GUICtrlSetOnEvent($startPlanButton, "startPlanButton")
GUICtrlSetOnEvent($eventDialogCancelButton, "toggleEventDialog")
GUICtrlSetOnEvent($eventDialogSaveButton, "eventDialogSave")

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
$lastSavedDir = @ScriptDir
$debug = False
$eventDialogVisible = False
$eventDialogNew = True
$includeDescChecked = False
$nextMsg = ""
$twitchConnectionTimer = 0
$pingTimer = 0

;PreScript Actions
_GUICtrlListView_SortItems(GUICtrlGetHandle($planListView), 0)
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
TCPStartup()

;Check if default config location exists
;Try to create it if it doesnt
;Failover to the script dir
If FileExists($CONFIG_DIR) == 0 Then
   If DirCreate($CONFIG_DIR) == 0 Then
	  statusMsg("Failed to create config file dir:")
	  statusMsg($CONFIG_DIR)
	  statusMsg("Saving config file in script dir")
	  $CONFIG_DIR = @ScriptDir
   Else
	  statusMsg("Created config file dir:")
	  statusMsg($CONFIG_DIR)
   EndIf
EndIf

readConfig()

;Show the GUI
GUISetState(@SW_SHOW, $gui)
GUISetState(@SW_HIDE, $eventEditDialog)

;startTwitchTimer
$twitchConnectionTimer = TimerInit()

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

	  $eventsFired = 0
	  $eventInitialCount = UBound($events)

	  If $eventInitialCount == 0 Then
		 MsgBox($MB_ICONWARNING, "Light Plan", "No events to fire")
		 statusMsg("No events in the current LightPlan")
		 startPlanButton()
		 ContinueLoop
	  EndIf

	  GUICtrlSetData($nextEventLabel, "Next Event: " & $events[0][1])

	  If GUICtrlRead($includeDescCheckBox) == $GUI_CHECKED Then
		 $includeDescChecked = True
		 $nextMsg = $events[0][1] & " - " & $events[0][2]
	  Else
		 $includeDescChecked = False
		 $nextMsg = $events[0][1]
	  EndIf

	  ;Start timers to track stuff
	  $elapsedTimer = TimerInit()
	  $startTime = TimerInit()

	  ;Light Plan is Running
	  While $startLightPlan == True
		 ;Keep up with the time elapsed since light plan start
		 $elapsed = TimerDiff($startTime)

		 ;Check to see if an event is supposed to fire
		 If ($elapsed-$shiftDelay+$window) >= ($events[0][0]-$streamDelay) Then
			sendSingleMsg($nextMsg, $channel)
			$delta = Round(($elapsed-$shiftDelay) - ($events[0][0]-$streamDelay), 0)
			If $delta >= 0 Then
			   $delta = "+" & $delta
			Else
			   $delta = $delta
			EndIf
			statusMsg("Firing Event (" & msToTimeFormat(Round($elapsed, 0)) & "): " & $events[0][1] & " " & $delta & " ms")
			_ArrayDelete($events, 0)
			$eventsFired+=1
			setEventsFiredLabel($eventsFired, $eventInitialCount)
			If UBound($events) == 0 Then
			   statusMsg("All Light Events Fired")
			   startPlanButton()
			   ExitLoop
			EndIf

			If $includeDescChecked == True Then
			   $nextMsg = $events[0][1] & " - " & $events[0][2]
			Else
			   $nextMsg = $events[0][1]
			EndIf
		 EndIf

		 ;Update the GUI for time elapsed 4 times per sec
		 If TimerDiff($elapsedTimer) >= 250 Then
			GUICtrlSetData($timeElapsedLabel, "Time Elapsed: " & msToTimeFormat($elapsed, False))
			GUICtrlSetData($nextEventLabel, "Next Event: " & $events[0][1] & " in " &  msToTimeFormat(($events[0][0]-$streamDelay)-($elapsed-$shiftDelay+$window), False))
			$elapsedTimer = TimerInit()
		 EndIf

		 ;Keep the Twitch Connection Alive
		 If (($events[0][0]-$streamDelay)-($elapsed-$shiftDelay+$window)) > 3000 And TimerDiff($twitchConnectionTimer) > 2000 Then
			maintainTwitchConnection()
			$twitchConnectionTimer = TimerInit()
		 EndIf

		 ;Give the CPU a rest
		 Sleep(2)
	  WEnd
   EndIf

   ;Keep Twitch Connection Alive
   If $connected == True Then
	  If TimerDiff($twitchConnectionTimer) > 2000 Then
		 maintainTwitchConnection()
		 $twitchConnectionTimer = TimerInit()
	  EndIf
   EndIf
WEnd

Func eventDialogSave()
   Dim $newEventArr[3]
   $newEventArr[0] = GUICtrlRead($eventOffsetField)
   $newEventArr[1] = GUICtrlRead($eventCmdField)
   $newEventArr[2] = GUICtrlRead($eventDescField)

   Local $result = False

   If StringLen($newEventArr[0]) == 0 Or StringLen($newEventArr[1]) == 0  Then
	  MsgBox($MB_ICONERROR, "Error", "Offset or Command cannot be empty")
	  Return
   EndIf

   $selection = _GUICtrlListView_GetSelectedIndices($planListView, True)
   If $eventDialogNew == True Then
	  $result = addEventToListView($newEventArr[0], $newEventArr[1], $newEventArr[2])
	  If $result == True Then
		 GUICtrlSetData($eventOffsetField, "")
		 GUICtrlSetData($eventCmdField, "")
		 GUICtrlSetData($eventDescField, "")
	  EndIf
   Else
	  If $selection[0] == 0 Then Return
	  $result = updateEventInListView($selection[1], $newEventArr[0], $newEventArr[1], $newEventArr[2])
   EndIf

   If $result == True Then
	  toggleEventDialog()
   EndIf

EndFunc

Func toggleEventDialog()
   ;Set the dialog's position to the center of the main GUI
   Local $pos = WinGetPos($gui, "")
   If @error == 0 Then
	  WinMove($eventEditDialog, "", ($pos[0]+($GUI_WIDTH/2))-(190/2), ($pos[1]+($GUI_HEIGHT/2))-(220/2))
   EndIf

   If $eventDialogVisible == False Then
	  $eventDialogVisible = True
	  GUICtrlSetState($planListView, $GUI_DISABLE)
	  GUISetState(@SW_SHOW, $eventEditDialog)
   Else
	  $eventDialogVisible = False
	  GUICtrlSetState($planListView, $GUI_ENABLE)
	  GUISetState(@SW_HIDE, $eventEditDialog)
   EndIf
EndFunc

Func setEventsFiredLabel($numFired = 0, $numTotal = 0)
   If $numTotal == 0 Then
	  $numTotal =  _GUICtrlListView_GetItemCount($planListView)
   EndIf
   GUICtrlSetData($eventsFiredLabel, "Events Fired: "& $numFired & "/" & $numTotal)
EndFunc

Func readConfig()
   If FileExists($CONFIG_DIR&"\lightplan.config") == 0 Then
	  Return
   EndIf

   statusMsg("Reading Config: "&$CONFIG_DIR&"\lightplan.config")

   $currentFile = IniRead($CONFIG_DIR&"\lightplan.config", "LightPlan", "LastFile", "")
   $debug = IniRead($CONFIG_DIR&"\lightplan.config", "LightPlan", "Debug", False)
   Local $includeDescChecked = IniRead($CONFIG_DIR&"\lightplan.config", "LightPlan", "Include_Description_In_Cmd", False)
   Local $user = IniRead($CONFIG_DIR&"\lightplan.config", "Twitch", "User", "")
   Local $channel = IniRead($CONFIG_DIR&"\lightplan.config", "Twitch", "Channel", "")
   Local $oauth = IniRead($CONFIG_DIR&"\lightplan.config", "Twitch", "OAuthToken", "")

   If $includeDescChecked == True Then
	  GUICtrlSetState($includeDescCheckBox, $GUI_CHECKED)
   Else
	  GUICtrlSetState($includeDescCheckBox, $GUI_UNCHECKED)
   EndIf

   GUICtrlSetData($twitchUserField, $user)
   GUICtrlSetData($twitchOAuthField, $oauth)
   GUICtrlSetData($twitchChannelField, $channel)

   loadEventsFromJsonFile($currentFile)
EndFunc

Func saveConfig()
   Local $user = GUICtrlRead($twitchUserField)
   Local $channel = GUICtrlRead($twitchChannelField)
   Local $oauth = GUICtrlRead($twitchOAuthField)
   Local $includeDescChecked = GUICtrlRead($includeDescCheckBox)

   If $includeDescChecked == $GUI_CHECKED Then
	  $includeDescChecked = True
   Else
	  $includeDescChecked = False
   EndIf

   IniWrite($CONFIG_DIR&"\lightplan.config", "LightPlan", "LastFile", $currentFile)
   IniWrite($CONFIG_DIR&"\lightplan.config", "LightPlan", "Include_Description_In_Cmd", $includeDescChecked)
   IniWrite($CONFIG_DIR&"\lightplan.config", "LightPlan", "Debug", $debug)
   IniWrite($CONFIG_DIR&"\lightplan.config", "Twitch", "User", $user)
   IniWrite($CONFIG_DIR&"\lightplan.config", "Twitch", "Channel", $channel)
   IniWrite($CONFIG_DIR&"\lightplan.config", "Twitch", "OAuthToken", $oauth)
   statusMsg("Saved Config: "&$CONFIG_DIR&"\lightplan.config")
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
	  GUICtrlSetState($eventEditButton, $GUI_ENABLE)
	  GUICtrlSetState($deleteEventButton, $GUI_ENABLE)
	  GUICtrlSetState($twitchConnectButton, $GUI_ENABLE)
	  GUICtrlSetState($eventOffsetField, $GUI_ENABLE)
	  GUICtrlSetState($eventCmdField, $GUI_ENABLE)
	  GUICtrlSetState($eventDescField, $GUI_ENABLE)
	  GUICtrlSetState($calcDelayButton, $GUI_ENABLE)
	  GUICtrlSetState($twitchOAuthField, $GUI_ENABLE)
	  GUICtrlSetState($twitchUserField, $GUI_ENABLE)
	  GUICtrlSetState($twitchChannelField, $GUI_ENABLE)
	  GUICtrlSetState($includeDescCheckBox, $GUI_ENABLE)
	  GUICtrlSetState($menuFileNewButton, $GUI_ENABLE)
	  GUICtrlSetState($menuFileOpenButton, $GUI_ENABLE)
	  GUICtrlSetState($menuFileSaveButton, $GUI_ENABLE)
	  GUICtrlSetData($startPlanButton, "Start Light Plan")
	  GUICtrlSetColor($startPlanButton, $COLOR_BLACK)
	  GUICtrlSetData($timeElapsedLabel, "Time Elapsed: 00:00.000")
	  GUICtrlSetData($nextEventLabel, "Next Event: ")
	  setEventsFiredLabel(0)
	  statusMsg("Light Plan Stopped")
   Else
	  GUICtrlSetState($eventNewButton, $GUI_DISABLE)
	  GUICtrlSetState($eventEditButton, $GUI_DISABLE)
	  GUICtrlSetState($deleteEventButton, $GUI_DISABLE)
	  GUICtrlSetState($twitchConnectButton, $GUI_DISABLE)
	  GUICtrlSetState($calcDelayButton, $GUI_DISABLE)
	  GUICtrlSetState($eventOffsetField, $GUI_DISABLE)
	  GUICtrlSetState($eventCmdField, $GUI_DISABLE)
	  GUICtrlSetState($eventDescField, $GUI_DISABLE)
	  GUICtrlSetState($twitchOAuthField, $GUI_DISABLE)
	  GUICtrlSetState($twitchUserField, $GUI_DISABLE)
	  GUICtrlSetState($twitchChannelField, $GUI_DISABLE)
	  GUICtrlSetState($includeDescCheckBox, $GUI_DISABLE)
	  GUICtrlSetState($menuFileNewButton, $GUI_DISABLE)
	  GUICtrlSetState($menuFileOpenButton, $GUI_DISABLE)
	  GUICtrlSetState($menuFileSaveButton, $GUI_DISABLE)
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
   MsgBox($MB_ICONINFORMATION, "Stream Delay", "Dismiss this dialog when your message hits the stream")
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

Func deleteSelectedEvent()
   $selection = _GUICtrlListView_GetSelectedIndices($planListView, True)
   If $selection[0] == 0 Then Return

   _GUICtrlListView_DeleteItemsSelected($planListView)
   GUICtrlSetData($eventOffsetField, "")
   GUICtrlSetData($eventCmdField, "")
   GUICtrlSetData($eventDescField, "")
   GUICtrlSetState($eventEditButton, $GUI_DISABLE)
   GUICtrlSetState($deleteEventButton, $GUI_DISABLE)
EndFunc

Func updatePlanListView()
   setEventsFiredLabel(0)
   _GUICtrlListView_SimpleSort($planListView, False, 0, False)
EndFunc

Func addEventToListView($offset, $cmd, $desc)

   If StringRegExp($offset, "[^:\.0-9]") == 1 Then
	  MsgBox($MB_ICONERROR, "Error", "Badly formmated offset. Try the following format:" & @CRLF & @CRLF & "01:23.456")
	  Return False
   EndIf

   Local $msTest = timeToMs($offset)
   If @error > 0 Then
	  MsgBox($MB_ICONERROR, "Error", "Badly formmated offset. Try the following format:" & @CRLF & @CRLF & "01:23.456")
	  Return False
   EndIf

   $offset = msToTimeFormat($msTest)

   $index = _GUICtrlListView_AddItem($planListView, $offset)
   _GUICtrlListView_AddSubItem($planListView, $index, $cmd, 1)
   _GUICtrlListView_AddSubItem($planListView, $index, $desc, 2)
   updatePlanListView()
   Return True
EndFunc

Func updateEventInListView($index, $offset, $cmd, $desc)
   _GUICtrlListView_SetItem($planListView, $offset, $index, 0)
   _GUICtrlListView_SetItem($planListView, $cmd, $index, 1)
   _GUICtrlListView_SetItem($planListView, $desc, $index, 2)

   updatePlanListView()
   Return True
EndFunc

Func newEventButton()
   WinSetTitle($eventEditDialog, "", "New Event")
   $eventDialogNew = True
   GUICtrlSetData($eventOffsetField, "")
   GUICtrlSetData($eventCmdField, "")
   GUICtrlSetData($eventDescField, "")
   toggleEventDialog()
EndFunc

Func saveEventButton()
   WinSetTitle($eventEditDialog, "", "Edit Event")
   $eventDialogNew = False
   planListViewItemClick()
   toggleEventDialog()
EndFunc

Func menuOpenLightPlan()
   Local $initDir = dirFromPath($currentFile)
   If @error > 0 Then
	  $initDir = @ScriptDir
   EndIf
   $path = FileOpenDialog("Open Light Plan", $initDir, "JSON Files (*.json)", $FD_FILEMUSTEXIST, "", $gui)
   If @error <> 0 Then Return
   loadEventsFromJsonFile($path)
EndFunc

Func menuNewLightPlan()
   Local $ret = MsgBox($MB_YESNO, "New Light Plan", "Did you want to save what you were doing first?")
   If $ret == $IDYES Then
	  saveEventButton()
   EndIf
   clearGUI()
EndFunc

Func menuSaveLightPlan()
   Local $dir = ""

   ;Set the suggested dir to the dir of
   ; the last file worked with
   If StringLen($currentFile) > 0 Then
	  $dir = dirFromPath($currentFile)
	  If @error > 0 Then
		 ;If problems getting dir from the last
		 ; file worked with, use Script dir
		 $dir = @ScriptDir
	  EndIf
   Else
	  ;If no other option, set to the Script Dir
	  $dir = @ScriptDir
   EndIf

   ;Exit if there are no events created yet
   If _GUICtrlListView_GetItemCount($planListView) == 0 Then
	  MsgBox($MB_ICONERROR, "Error", "No events to save")
	  Return
   EndIf

   Local $suggestedFileName = GUICtrlRead($songArtistTitleField)
   $suggestedFileName = StringReplace($suggestedFileName, " ", "_")
   $suggestedFileName = StringRegExpReplace($suggestedFileName, "[^0-9a-Z_-]", "")

   ;Song Artist Title is Empty or Contains
   ; Only special chars
   If StringLen($suggestedFileName) = 0 Then
	  MsgBox($MB_ICONERROR, "Error", "Please add a valid the song artist - title before saving.")
	  Return
   EndIf

   Local $path = FileSaveDialog("Save Light Plan", $dir, "JSON Files (*.json)", $FD_PROMPTOVERWRITE, $suggestedFileName, $gui)
   saveEventsJsonFile($path)
EndFunc

Func dirFromPath($path)
   ;Get File Attributes
   Local $attr = FileGetAttrib($path)

   ;If $attr is empty, not a valid file/dir
   If StringLen($attr) == 0 Then
	  Return SetError(1, 0, "")
   EndIf

   ;If $attr contains "D" then is already a dir
   If StringInStr($attr, "D") > 0 Then
	  ;Already a dir, return $path
	  Return $path
   EndIf

   ;Split the path into dirs
   Local $split = StringSplit($path, "\")
   Local $dir = ""

   ;Omit the last token (file name)
   For $i = 1 To $split[0]-1
	  $dir &= $split[$i] & "\"
   Next

   Return $dir
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
	  _WinAPI_SetFocus(ControlGetHandle($gui, "", $planListView))
   Else
	  $currentFile = ""
   EndIf
EndFunc

Func menuExit()
   statusMsg("Exiting")
   If $connected == True Then twitchDisconnect()
   TCPShutdown()
   If _GUICtrlListView_GetItemCount($planListView) > 0 Then
   Local $ret = MsgBox($MB_YESNO, "Exit Light Plan", "Did you want to save the current LightPlan before quitting?")
	  If $ret == $IDYES Then
		 saveEventButton()
	  EndIf
   EndIf
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
   MsgBox($MB_ICONINFORMATION, "About LightPlan", "Version: LightPlan v" & $VERSION & @CRLF & @CRLF _
	  & "Author: chillfactor032" & @CRLF _
	  & "Email: chill@chillaspect.com" & @CRLF _
	  & "GitHub: https://github.com/chillfactor032/lightplan" & @CRLF _
	  & "Discord: ChillFacToR#2906" & @CRLF)
EndFunc

Func planListViewItemClick()
   $selection = _GUICtrlListView_GetSelectedIndices($planListView, True)
   If $selection[0] == 0 Then
	  GUICtrlSetState($eventEditButton, $GUI_DISABLE)
	  GUICtrlSetState($deleteEventButton, $GUI_DISABLE)
	  Return
   EndIf
   $selectedItem = _GUICtrlListView_GetItemTextArray($planListView, $selection[1])
   If $selectedItem[0] == 0 Then
	  Return
   EndIf
   GUICtrlSetData($eventOffsetField, $selectedItem[1])
   GUICtrlSetData($eventCmdField, $selectedItem[2])
   GUICtrlSetData($eventDescField, $selectedItem[3])
   GUICtrlSetState($eventEditButton, $GUI_ENABLE)
   GUICtrlSetState($deleteEventButton, $GUI_ENABLE)
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

   If Ubound($events) = 0 Then
	  MsgBox($MB_ICONWARNING, "Error", "No events to save.")
	  Return
   EndIf

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
   While StringRegExp(StringRight($msg, 1), "[\r\n]") == 1
	  $msg = StringLeft($msg, StringLen($msg)-1)
   WEnd

   If StringLen($msg) == 0 Then Return

   If $debug == True Then
	  ConsoleWrite($msg&@CRLF)
   EndIf


   ;Local $status = @CRLF & @HOUR & ":" & @MIN & ":" & @SEC & " - " & $msg
   _GUICtrlEdit_AppendText($statusEdit, @CRLF&$msg)
   Local $caretPos = StringLen(GUICtrlRead($statusEdit))-(StringLen($msg)+1)
   _GUICtrlEdit_SetSel($statusEdit, $caretPos, $caretPos+1)
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
	  statusMsg("Could not create socket to Twitch Chat IRC")
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
	  _ArrayAdd($resp, $sRecv)
	  $resp[0] += 1
	  If $debug == True And StringLen($sRecv) > 0 Then
		 statusMsg("< " & $sRecv)
	  EndIf
	  Sleep(2)
   Until Not $sRecv
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

Func maintainTwitchConnection()
   If $connected == False Or $ircSocket == 0 Then Return

   Local $msgs = collectTwitchMsgs($ircSocket)

   If $msgs[0] == 0 Then Return

   Local $split = ""
   For $msg In $msgs
	  $split = StringSplit($msg, " ")
	  If $split[0] > 1 And $split[1] == "PING" Then
		 $iLastPing = TimerInit()
		 $sPing = StringReplace($split[2], ":", "")
		 _IRCServerPong($ircSocket, $sPing)
		 statusMsg("> PONG " & $sPing)
	  EndIf
   Next
EndFunc