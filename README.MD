# <p align="center"><b>rClone bisync ~~(workaround)~~ automation</b>

<b>Why?</b> <br>
~~rClone bisync feature is currently in beta and not reliable.~~<br>
rClone bisync is no longer in beta. This script however remains for convenience and for error logging.

<b>What?</b> <br>
A straightforward script that uses the Linux crontab and rClone for the heavy lifting, to provide a seamless syncing experience with no maintenance or extra commands from your end such as resyncing or any other forms of manual maintenance.

<b>How?</b><br>
~~This script uses the stable commands of the software to mimic a reliable bidirectional syncing experience.~~<br>
It is no longer mimicking anything. The bisync command actually does this now.

<b>Contribute!</b><br>
If you have any suggestions or improvements, please open a pull request!

##

<b>Tested OS:</b><br>
- Debian 13 Trixie (GNOME 48)
- Debian 12 Bookworm (GNOME 43.9)

<br>

<h2 align="center">Install Instructions</h2>

<b>1. Place the [Syncing.sh](Syncing.sh) script into a folder of your choosing from your computer.</b><br>
- For this example, we will use: "/home/{user}/Desktop/rCloneSync/rClone-bisync-workaround/Syncing.sh"

<br>

<b>2. Create a "var.sh" file into a different location.</b><br>
- For this example, we will use: "/home/{user}/Desktop/rCloneSync/0. Private/rClone-bisync-workaround/var.sh"
- We will store our syncing paths to both the local and the server here.
<br>
<h4><b>Example of "var.sh":</b></h4>

*All of these are paths to folders and not files.*
<br>
*At this point you have also set up your rClone cloud providers and you are now just declaring them.*

```
#!/bin/bash

# Path to the logs
Setups='/home/{user}/Desktop/rCloneSync/Setups'
Err='/home/{user}/Desktop/rCloneSync/Configs/Setups/rClone-bisync-workaround/Logs/$Err'

# Home path to the rClone bin
recycle_bin_root='/home/{user}/Desktop/rCloneSync/$Backup'

# Drive 1
Personal_remote='{Provider 1}:'
Personal_local='/home/{user}/Desktop/rCloneSync/Cloud/{Provider 1}'
Personal_local_backup='/home/{user}/Desktop/rCloneSync/$Backup/rClone Backup/{Provider 1}'

# Drive 2
PersonalPb_root_remote='{Provider 2}:'
PersonalPb_remote='{Provider 2}:Drive'
PersonalPb_local='/home/{user}/Desktop/rCloneSync/Cloud/{Provider 2}'

# Drive 3
Dev_remote='{Provider 3}:Drive'
Dev_local='/home/{user}/Desktop/rCloneSync/{Provider 3}/Cloud'

# Drive 4
WORKSTATION_remote='{Provider 4}:@WORKSTATION'
WORKSTATION_local='/home/{user}/Desktop/rCloneSync/{Provider 4}/Cloud'

# Define the Sync Control location
SyncControl_root='{Provider of your choice}:'
```

<br>

<b>3. Create the local directories as shown at step 2 in the "var.sh" file.</b><br>
- In this case, we will switch to the parent directory and create them as follows:
```
cd "/home/{user}/Desktop/rCloneSync/Cloud"
```
```
mkdir "{Provider 1}"
```
```
mkdir "{Provider 2}"
```
```
mkdir "{Provider 3}"
```
```
mkdir "{Provider 4}"
```

<br>

<b>4. Create a folder where you will store your script logs.</b><br>
- For this example, we will use: "/home/{user}/Desktop/rCloneSync/Setups"

<br>

<b>5. Create two more subdirectories in the one created at step 4.</b><br>
- Go into the directory created at the previous step if not already there.
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

<b>6. Create two more subdirectories in the "Logs" directory created at step 5 and two other subdirectories of them that register the canceled syncs.</b><br>
- Go into the "Logs" directory created at the previous step.
```
cd "/home/{user}/Desktop/rCloneSync/Setups/Logs"
```

- Create the subdirectory that registers the Boot logs and its canceled events.
```
mkdir "Boot"
```

```
mkdir "Boot/Canceled"
```

- Create the subdirectory that registers the regular Sync cycles and its canceled events.
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
- Open the crontab editor from terminal:<br>
*If this is the first time you open it, you might be asked to create a new crontab.*
```
crontab -e
```

- At the bottom of your crontab (below the commented sections), paste the following:<br>
```
XDG_RUNTIME_DIR="/run/user/1000"
@reboot sleep 30 && "/home/{user}/Desktop/rCloneSync/rClone-bisync-workaround/Syncing.sh"
```
<br>

<b>Ending note:</b> Make sure you double check each path to be linked correctly and that they make sense for your system. If you need any help setting things up, please reach out to [open@sebastian.ghiveci.com](mailto:open@sebastian.ghiveci.com).

<br>

<h2 align="center">Known issues<br></h2>
<p align="center">Only applicable for the remotes that do not (fully) use bisync, which is only one since <b>v2.1.0.0 mk1</b></p>
<h4><b>1. If files are completely deleted from the local during the 5-minute break time and the computer shuts down, on the next boot, the deleted files will be recreated.</b></h4>

<b>Solution(s):</b>
1. Wait until the next sync cycle, which will delete the files from the server as well.
2. Delete the files straight from the server after the computer is turned off.

<br>

~~<h4><b>2. If new files are created on the server after the computer boots up (after the boot command ran), on the next sync cycle, that file will be deleted.</b></h4>~~

<br>

~~<h4><b>3. Renaming on the server after the computer booted will also not take effect.</b></h4>~~

<br>

~~<h4><b>4. Files created in the middle of the sync cycle (right after server upload and before server download) will be deleted when the sync completes.</b></h4>~~

<br>

<h4><b>5. Newly created files will be deleted at the next boot if the sync has not happened after they were made (computer was closed right after a file was created).</b></h4>

<b>Solution(s):</b>
1. Make sure one sync cycle has happened after creating new files ~~(use the notifications to check if the sync happened)~~ (notifications no longer in place since <b>v2.0.0.0 mk1</b>).

<br>

~~<h4><b>6. If two computers are on, all the issues above might take place on both of the computers.</b></h4>~~

Not anymore since <b>v3.0.0.0 mk1</b>

~~<b>Solution(s):</b>~~<br>
~~1. Pause the sync on the computer you do not work on.~~<br>
~~2. Make sure you work with already-created files and not new/deleted ones.~~<br>

##
**This repository follows the [iVer](https://github.com/frontfacer/iVer) versioning format.*

<br>
<p align="center">© 2024-2025 | Sebastian Ghiveci<br/>sebastian.ghiveci.com<br>