<h2><b>v1.2.1 mk1</b><br></h2>

- Improved the notification system to separate the tile from the context.<br>

<h2><b>v1.2.0 mk1</b><br></h2>

- Removed (commented out) a duplicate "bisync" command, residual from before "bisync", that I believe it to be the cause for some collisions.<br>
- Declared the "bisync" flags in a global variable as well.<br>
- Added new "bisync" flags: "--force" and "--resilient"<br>
- Mentioned that this versioning document follows the iVer format.<br>

<h2><b>v1.1.0 mk1</b><br></h2>

- Improved the error detection function.<br>
- Added a new remote and started experimenting the "bisync" command on it.<br>
- Declared the flags of the "sync" command in a global variable.<br>
- Added additional flags for the "sync" command that makes the transfer of many small files fast and efficient.<br>
- Adjusted the log level from DEBUG to INFO for a more lightweight and faster to read output.<br>
- Fixed spelling mistakes in the install instructions.<br>
- Unified the style of the code.<br>

<h2><b>v1.0.0 mk1</b><br></h2>

- The script will begin by triggering the rClone sync commands in a specific order (namely: <b>orderBoot</b>).<br>
- rClone sync commands will then run in a different order (namely: <b>orderSync</b>) after <b>orderBoot</b> completed.<br>
- <b>orderSync</b> will run in a loop.
- The internet is checked before any attempts of running the rClone sync commands. If the connection cannot be established, the script will not run the commands, but try again after 1 minute instead.

<br>

**This repository follows the [iVer](https://github.com/frontfacer/iVer) versioning format.*
