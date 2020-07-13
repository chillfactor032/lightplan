# LightPlan

This application is designed to time chat commands to sync up with music on a Twitch.tv stream.

  - Save and share "Light Plans" in JSON format.
  - Integrates with Twitch IRC Chat
  - Sync up your chat commands with events in your favorite Twitch.tv streams. 
  
## Using LightPlan
Using LightPlan involves adding events to the LightPlan event table. Each event consists of an offset in mm:ss.SSS format, a chat command to issue when the event fires, and a description. These events, the song artist and title information, and the author of the LightPlan may be saved in JSON format. When the desired LightPlan has been created, connect to the Twitch channel chat that will be the target of the commands. Once connected, you may start the Light Plan. 

##### Adding Events to the LightPlan
1. Add and offset to the Offset field in the following format: mm:ss.SSS (e.g. 01:23.456)
2. Add the chat command to be issued when this event fires (e.g. !strobe).
3. Add a description for the event so others can follow (e.g. Chorus 1)
4. Click "Add Event" button.

##### Updating Events on the LightPlan
1. Click the event in the table that you wish to update.
2. Edit the desired field for the event (e.g. Chat Command or Offset)
3. Click "Update Event" button to commit your changes.

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

## Releases
The current release will be compiled to EXE format and stored in the releases directory. You may also clone this repository and run it from the AutoIt console. 

## Dependencies
This application makes use of the following libraries
 - AutoIt JSON UDF
 - - Author: Ward (with some work from others)
 - - Forum Link: https://www.autoitscript.com/forum/topic/148114-a-non-strict-json-udf-jsmn/
 - AutoIt IRC UDF
 - - Author: Robert Maehl (rcmaehl) based on work by chip/mcgod
 - - Forum Link: https://www.autoitscript.com/forum/topic/159285-irc-udf-updated-version-of-chips-irc-udf-release-v122-09062016-technical-writer-needed/
 
### Contact
    GitHub: chillfactor032
    Email: chill@chillaspect.com
    Discord: ChillFacToR#2906
    Twitch.tv: chillfactor032


