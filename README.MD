# <p align="center"><b>rClone bisync (workaround)</b>

<b>Why?</b> <br>
rClone bisync feature is currently in beta and not reliable.

<b>How?</b><br>
This script uses the stable commands of the software to mimic a reliable bidirectional syncing experience.

##

<b>Current Version:</b><br>
v1.0.0 mk1

<b>Tested OS:</b><br>
- Debian 12: Bookworm

<br>

<h2 align="center">Install Instructions</h2>
TBA

<br>

<h2 align="center">Known issues</h2>
<h4>1. If files are completely deleted from the local during the 10-minutes break time and the computer shuts down, on the next boot, the deleted files will be recreated. </h4>

<b>Solution(s):</b>
1. Wait until the next sync cycle, which will delete the files from the server as well.
2. Delete the files straight from the server after the computer is turned off.

<h4>2. If new files are created on the server after the computer boots up (after the boot command ran), on the next sync cycle, that file will be deleted.</h4>

<b>Solution(s):</b>
1. Don't delete or create files on the server while computer is on.

<h4>3. Renaming on the server after the computer booted will also not take effect. </h4>

<b>Solution(s):</b>
1. Do not rename any files or folders on the server while the computer is on.

<h4>4. Files created in the middle of the sync cycle (right after server upload and before server download) will be deleted when the sync completes.</h4>

<b>Solution(s):</b>
1. Do not create new files in the middle of the sync; just wait until the sync is complete (the notifications are there to help you track the status of the sync).

<h4>5. Newly created files will be deleted at the next boot if the sync has not happened after they were made (computer was closed right after a file was created).</h4>

<b>Solution(s):</b>
1. Make sure one sync cycle has happened after creating new files (use the notifications to check if the sync happened).


<h4>6. If two computers are on, all the issues above might take place on both of the computers.</h4>

<b>Solution(s):</b>
1. Pause the sync on the computer you do not work on.
2. Make sure you work with already-created files and not new/deleted ones.

##
**This repository follows the [iVer](https://github.com/frontfacer/iVer) versioning format.*

<br>
<p align="center">© 2024 | Sebastian Ghiveci<br/>sebastian.ghiveci.com<br>