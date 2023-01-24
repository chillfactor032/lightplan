# Notice

This tool has been deprecated and no longer maintained. Please use Light Plan Studio instead. It is at:

https://github.com/chillfactor032/LightPlanStudio

# LightPlan

This application is designed to time chat commands to sync up with music on a Twitch.tv stream.

  - Save and share "Light Plans" in JSON format.
  - Integrates with Twitch IRC Chat
  - Sync up your chat commands with events in your favorite Twitch.tv streams. 

## Using LightPlan
Using LightPlan involves adding events to the LightPlan event table. Each event consists of an offset in mm:ss.SSS format, a chat command to issue when the event fires, and a description. These events, the song artist and title information, and the author of the LightPlan may be saved in JSON format. When the desired LightPlan has been created, connect to the Twitch channel chat that will be the target of the commands. Once connected, you may start the Light Plan and the events will fire according to the time offsets provided.

##### Adding Events to the LightPlan
1. Click the "Add Event" button to show the event dialog.
2. Add and offset to the Offset field in the following format: mm:ss.SSS (e.g. 01:23.456)
3. Add the chat command to be issued when this event fires (e.g. !strobe).
4. Add a description for the event so others can follow (e.g. Chorus 1)
5. Click "Save Event" button.

##### Editing Events on the LightPlan
1. Click the event in the table that you wish to edit.
2. Click "Edit Event"
3. In the edit dialog, make the desired changes to the event.
4. Commit the changes by clicking "Save Event".

##### Deleting Events from the LightPlan
1. Click the event in the table that you wish to delete.
2. Click "Delete Event" button.

##### Connecting to Twitch Chat
1. You will be required to fetch an OAuth Token that authorizes LightPlan to post chat messages on your behalf.
2. This token may created at the following link: https://twitchapps.com/tmi/
3. This link may be found in LightPlan at Help > Get Twitch OAuth Token
4. Enter your Twitch Username and target Twitch channel in the Twitch Chat Connection fields. These values should be one word, all lowercase. 
5. When you are ready to start your LightPlan, click Connect to Twitch.

##### Stream Delay
Stream delay can negatively affect chat command timings depending on the latency you have to the streamer. To compensate, use the "Calculate Stream Delay" functionality to adjust the command timings. You must first be connected to Twitch chat in order to complete this step (see above). Steps:
1. Click the Calculate Steam Delay button
2. Enter a test command in the dialog box
3. When you see the test command on the streamer's video, dismiss the dialog to stop the timer.

The calculated delay will be displayed in the cooresponding text box. This delay may be manuall adjusted as well with the < and > arrows.

##### Shift Timeline
In order for the timing to work, you must start the LightPlan at the planned starting point in the song (on the first note for instance). If you miss the mark and start the LightPlan too early or too late, you can shift the timing forward or back. To do this, simply use the < and > arrows by "Shift Timeline". This will correct the improper starting time. For example, if you planned on starting the LightPlan on the first note, but missed and started it 1 second too late, simply shift the timeline back -1000ms by clicking the < arrow a few times.

##### Save/Open the LightPlan Files
LightPlans may be saved and opened in JSON format. To Open a previously saved file, issue File > Open Light Plan. To save the file you are currently working on issue File > Save Light Plan.

##### LightPlan Creation Wizard
A wizard to help in the initial creation of a LightPlan is available in File > LightPlan Creation Wizard. This wizard uses the space bar as a hotkey. To start the timer, click the space bar once. Any other space bar presses will add events at that time stamp. Click Done to add the events to the current LightPlan. After the events have been added, edit the commands and descriptions to the desired values. 

An example use case:
 - Load your song in Youtube.
 - Pause the video at the beginning of the song.
 - Click the play button and space bar simultaneously to start the song and the LightPlan timer.
 - Press the space bar in time to the song where you want the lights to changes.
 - When finished, click Done.
 - Click Yes on the confirmation dialog.
 - Edit the new events to have meaningful commands and descriptions.

## Releases
The current release may be found here:
[LightPlan v0.95 beta](https://github.com/chillfactor032/lightplan/releases/tag/v0.95)

## Dependencies
This application makes use of the following libraries
 - AutoIt JSON UDF
 - - Author: Ward (with some work from others)
 - - Forum Link: [Forum Link](https://www.autoitscript.com/forum/topic/148114-a-non-strict-json-udf-jsmn/)
 - AutoIt IRC UDF
 - - Author: Robert Maehl (rcmaehl) based on work by chip/mcgod
 - - Forum Link: [Forum Link](https://www.autoitscript.com/forum/topic/159285-irc-udf-updated-version-of-chips-irc-udf-release-v122-09062016-technical-writer-needed/)
 
### Contact
    GitHub: chillfactor032
    Email: chill@chillaspect.com
    Discord: ChillFacToR#2906
    Twitch.tv: chillfactor032


