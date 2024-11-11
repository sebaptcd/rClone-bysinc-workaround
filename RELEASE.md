<h2><b>v2.0.0.0 mk1</b><br></h2>

- rClone "bisync" has been tested and it appears to be working good. The script is transitioning towards simply handling logs, showing error notifications and processing the actual commands. Most of the drives have now been updated with "bisync".<br>
- Fixed: Self clean script if boot sync is interrupted mid process.<br>
- Introduced a recycle bin so that files can be double checked after deletion.<br>
- Thanks to a functional "bisync" command and the implementation of the "recycle bin", the script can now be interrupted at any point, with confidence that data loss is not likely anymore. As a result, notifications about the script status have been removed/commented out.<br>
- With "bisync" now applied to most of the drives, a conflict error detection has been introduced to be notified of any occurrences.<br>
- Better handling of the timestamp function and rClone flags.<br>
- Corrected RELEASE.md to follow the latest [iVer](https://github.com/frontfacer/iVer) format.<br>

<h2><b>v1.2.1.1 mk1</b><br></h2>

- Fixed typo in RELEASE.md file.<br>
- Updated RELEASE.md to follow the latest [iVer](https://github.com/frontfacer/iVer) format.<br>

<h2><b>v1.2.1.0 mk1</b><br></h2>

- Improved the notification system to separate the title from the context.<br>

<h2><b>v1.2.0.0 mk1</b><br></h2>

- Removed (commented out) a duplicate "bisync" command, residual from before "bisync", that I believe it to be the cause for some collisions.<br>
- Declared the "bisync" flags in a global variable as well.<br>
- Added new "bisync" flags: "--force" and "--resilient"<br>
- Mentioned that this versioning document follows the iVer format.<br>

<h2><b>v1.1.0.0 mk1</b><br></h2>

- Improved the error detection function.<br>
- Added a new remote and started experimenting the "bisync" command on it.<br>
- Declared the flags of the "sync" command in a global variable.<br>
- Added additional flags for the "sync" command that makes the transfer of many small files fast and efficient.<br>
- Adjusted the log level from DEBUG to INFO for a more lightweight and faster to read output.<br>
- Fixed spelling mistakes in the install instructions.<br>
- Unified the style of the code.<br>

<h2><b>v1.0.0.0 mk1</b><br></h2>

- The script will begin by triggering the rClone sync commands in a specific order (namely: <b>orderBoot</b>).<br>
- rClone sync commands will then run in a different order (namely: <b>orderSync</b>) after <b>orderBoot</b> completed.<br>
- <b>orderSync</b> will run in a loop.
- The internet is checked before any attempts of running the rClone sync commands. If the connection cannot be established, the script will not run the commands, but try again after 1 minute instead.

<br>

**This repository follows the [iVer](https://github.com/frontfacer/iVer) versioning format.*
