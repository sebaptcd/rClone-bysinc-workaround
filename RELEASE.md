<h2><b>v1.0.0 mk1</b><br></h2>

- The script will begin by triggering the rClone sync commands in a specific order (namely: <b>orderBoot</b>).<br>
- rClone sync commands will then run in a different order (namely: <b>orderSync</b>) after <b>orderBoot</b> completed.<br>
- <b>orderSync</b> will run in a loop.
- The internet is checked before any attempts of running the rClone sync commands. If the connection cannot be established, the script will not run the commands, but try again after 1 minute instead.