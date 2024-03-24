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

<b>Known issues:</b>

<br>

- If files are completely deleted from local in the break time and computer shuts down, on boot, the files will be recreated.
<br>
<b>Solution(s):<b>
1. Wait until the next sync for the files to be deleted on the server as well.
2. Delete the files from the server only after the computer turned off.

<br><br>

- If I create a file on the server after the computer booted (after the boot command ran), on the next sync, that file will be deleted.
<br>
<b>Solution(s):<b>
1. Don't delete create files on the server while computer is on.

<br><br>

Renaming on the server after the computer booted will also not take effect.
<br>
<b>Solution(s):<b>
1. Do not rename any files or folders on the server while the computer is on.

<br><br>

If I create a file in the middle of the sync cycle (right after server upload and before server download) the new file will be deleted when the sync completes.
<br>
<b>Solution(s):<b>
1. Do not create new files in the middle of the sync, just wait until the sync is complete.

<br><br>

Newly created files will be deleted at next boot if the sync has not happened since their creation.
<br>
<b>Solution(s):<b>
1. Make sure one sync cycle has happened after creating new files.

<br><br>

If two computers are on, all issues above will take place on both of the computers.
<br>
<b>Solution(s):<b>
1. Pause the sync on the computer you do not work on.

<h2 align="center">Install Instructions</h2>
TBA

<br><br>
**This repository follows the [iVer](https://github.com/frontfacer/iVer) versioning format.*
