# <p align="center"><b>rClone bisync (workaround)</b>

<b>Why?</b> <br>
rClone bisync feature is currently in beta and not reliable.

<b>What?</b> <br>
A straightforward script that uses the Linux crontab and rClone for the heavy lifting, to provide a seamless syncing experience with no maintenance or extra commands from your end such as resyncing or any other forms of manual maintenance.

<b>How?</b><br>
This script uses the stable commands of the software to mimic a reliable bidirectional syncing experience.

<b>Contribute!</b><br>
If you have any suggestions or improvments, please open a pull request!

##

<b>Current Version:</b><br>
v1.0.0 mk1 [(view release notes)](RELEASE.md)

<b>Tested OS:</b><br>
- Debian 12: Bookworm (GNOME 43.9)

<br>

<h2 align="center">Install Instructions</h2>

<b>1. Place the [Syncing.sh](Syncing.sh) script into a folder of choosing from your computer.</b><br>
- For this example, we will use: "/home/{user}/Desktop/rCloneSync/rClone-bysinc-workaround/Syncing.sh"

<br>

<b>2. Create a "var.sh" file into a different location.</b><br>
- For this example, we will use: "/home/{user}/Desktop/rCloneSync/0. Private/rClone-bysinc-workaround/var.sh"
- We will store our syncing paths to both the local and the server here.
<br><br>
<b>Example of "var.sh":</b>
<br>
*All of these are paths to folders and not files.<br>
At this point you have also set up your rClone cloud providers and you are now just declaring them.*
```
#!/bin/bash

# Path to the logs
Setups='/home/{user}/Desktop/rCloneSync/Setups'

# Personal
Personal_remote='{nameForDrive1-asSetUpInRclone}'
Persoanl_local='/home/{user}/Desktop/rCloneSync/Cloud/Drive1'

# Dev
Dev_remote='{nameForDrive2-asSetUpInRclone}'
Dev_local='/home/{user}/Desktop/rCloneSync/Cloud/Drive2'

# WORKSTATION
WORKSTATION_remote='{nameForDrive3-asSetUpInRclone}'
WORKSTATION_local='/home/{user}/Desktop/rCloneSync/Cloud/Drive3'
```

<br>

<b>3. Create the local directories as set up at step 2 in the var.sh.</b><br>
- In this case, we will swith to the parent directory and create them as follows:
```
cd "/home/{user}/Desktop/rCloneSync"
```
```
mkdir "Cloud/Drive1"
```
```
mkdir "Cloud/Drive2"
```
```
mkdir "Cloud/Drive3"
```

<br>

<b>4. Create a folder where you will store your script logs.</b><br>
- For this example, we will use: "/home/{user}/Desktop/rCloneSync/Setups"

<br>

<b>5. Create two more subdirectories in the one created at step 3.</b><br>
- Go into the directory created at the previews step if not already there.
```
cd "/home/{user}/Desktop/rCloneSync/Setups/"
```

- Create the first subdirectory used for the locking mechanism.
```
mkdir "Locks"
```

- Create the second subdirectory used for logging everything.
```
mkdir "Logs"
```

<br>

<b>6. Create two more subdirectories in the "Logs" direcotry created at step 4 and two other sub directories of them that register the canceled syncs.</b><br>
- Go into the "Logs" directory created at the previews step.
```
cd "/home/{user}/Desktop/rCloneSync/Setups/Logs"
```

- Create the subdirectory that registerers the Boot logs and its canceled events.
```
mkdir "Boot"
```

```
mkdir "Boot/Canceled"
```

- Create the subdirectory that registerers the regular Sync cycles and its canceled events.
```
mkdir "Sync"
```
```
mkdir "Sync/Canceled"
```

<br>

<b>7. Make sure both "Syncing.sh" and "var.sh" are executable.</b><br>

```
chmod +x Syncing.sh
```
```
chmod +x var.sh
```

<br>

<b>8. Configure your crontab to trigger the script whenever the computer boots.</b><br>
- Open the crotab editor from terminal:<br>
*If this is the first time you open it, you might be asked to create a new crontab.*
```
crontab -e
```

- At the bottom of you crontab, below the commeted sections, paste the flowwing:<br>
```
XDG_RUNTIME_DIR="/run/user/1000"
@reboot sleep 30 && "home/{user}/Desktop/rCloneSync/rClone-bysinc-workaround/Syncing.sh"
```
<br>

<b>Ending note:</b> Make sure you double check each path to be linked corretly and that they make sense for your system. If you need any help seeting things up, please reach out to [open@sebastian.ghiveci.com](mailto:open@sebastian.ghiveci.com).

<br>

<h2 align="center">Known issues</h2>
<h4><b>1. If files are completely deleted from the local during the 10-minutes break time and the computer shuts down, on the next boot, the deleted files will be recreated.</b></h4>

<b>Solution(s):</b>
1. Wait until the next sync cycle, which will delete the files from the server as well.
2. Delete the files straight from the server after the computer is turned off.

<br>

<h4><b>2. If new files are created on the server after the computer boots up (after the boot command ran), on the next sync cycle, that file will be deleted.</b></h4>

<b>Solution(s):</b>
1. Don't delete or create files on the server while computer is on.

<br>

<h4><b>3. Renaming on the server after the computer booted will also not take effect.</b></h4>

<b>Solution(s):</b>
1. Do not rename any files or folders on the server while the computer is on.

<br>

<h4><b>4. Files created in the middle of the sync cycle (right after server upload and before server download) will be deleted when the sync completes.</b></h4>

<b>Solution(s):</b>
1. Do not create new files in the middle of the sync; just wait until the sync is complete (the notifications are there to help you track the status of the sync).

<br>

<h4><b>5. Newly created files will be deleted at the next boot if the sync has not happened after they were made (computer was closed right after a file was created).</b></h4>

<b>Solution(s):</b>
1. Make sure one sync cycle has happened after creating new files (use the notifications to check if the sync happened).

<br>

<h4><b>6. If two computers are on, all the issues above might take place on both of the computers.</b></h4>

<b>Solution(s):</b>
1. Pause the sync on the computer you do not work on.
2. Make sure you work with already-created files and not new/deleted ones.

##
**This repository follows the [iVer](https://github.com/frontfacer/iVer) versioning format.*

<br>
<p align="center">© 2024 | Sebastian Ghiveci<br/>sebastian.ghiveci.com<br>