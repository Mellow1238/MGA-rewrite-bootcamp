# Commands list
> [!NOTE]
> Replace m/ with either Prefix1 or Prefix2 defined in the server config

##### m/help <arg> - sends help information in chat and lists a variety of parameters for help with specific things


##### m/credits - displays mga-rewrite script and mga_bootcamp map credits


##### m/mga - places the player in a random arena


##### m/arena <arena abbreviation> - places the player in the specified arena, find available arenas by entering m/arena
```
  Example: 'm/arena m'
	Use m/arena with no parameter to list arenas
```
 
##### m/r - resets the player back to the lobby area


##### m/painsnd - toggles on/off rocket jump pain sounds, off by default


##### m/killinfo - toggles on/off a chat log of the velocity and bhop number of you and opponent when you get a kill or die


##### m/speedo <type> - use axis or abs to select axis velocity or absolute velocity or none/no parameter to turn off
```
	Supports custom display settings using any of the provided measures
	provide another argument with the abbreviations of the measures you desire.
	Available measures are A(absolute), V(vertical), H(Horizontal), x, yn
	Example: 'm/speedo custom xyA'
```
 
##### m/fov <num> - allows the user to change their fov between 75-130


##### m/tick - prints the current server tick, makes fetching sourcetv demo clips easier


##### m/training - places the player in the training mode


## DUEL COMMANDS
*Duels allowed by default*



##### m/scoredisplay <type> - Switches between ui, text, or both for the method of duel score reporting. Use parameters ui, text, or both to choose


##### m/duel <duel arena> <duel type> - joins the player into a specified duel arena of specific duel type. Defaults to first to 10 if no duel type is supplied
```
	Use m/duel with no parameter to list duel arenas
```

##### m/duels - lists players waiting in duel arenas and the score of ongoing duels
```
This command can also be used again whilst waiting for someone to join your duel in order to change the duel type without rejoining the duel arena
```

##### m/spec <duel arena> - allows the user to receive score updates on the chosen duel arena, useful for the tournament.


##### m/spec auto - automatically determines which arena the spectator camera is in and shows that duels score. Also can clear the spectated duel and disable auto by using /spec with no parameter


##### m/style - toggles on/off the bhop style meter in bhop duels (default on)


## DEBUG COMMANDS
*Disabled by default, use config to enable*



##### m/cshow - toggles on/off a small display that lets the player know if they are capable of critting with the market gardener


##### m/bshow - toggles on/off a chat log for bhop number, it will print the number of successful bhops when the player fails/or loses crit


##### m/debug `<playerid> | <message>` - makes bot sent text in chat, usage is m/debug playernumber | message
```
	Example: m/debug 8 | m/arena m
	fetch user number from status console command
```
 
##### m/debug2 - instantly swap teams without respawn, even in team restricted gamemodes


##### m/debug3,4 - unused now


##### m/debug5 - prints the player lists for all custom gamemodes on server console


## PRACTICE MODE COMMANDS
*Disabled by default, use config to enable*



##### m/startpos - sets start position for player to reset to


##### m/clearpos - clears start position


##### m/dummy <name> - spawns a dummy bot at players current position


##### m/regen - toggles the ammo and health regen disabled by default in practice mode


## ADMIN COMMANDS
*Define admins in the config file by appending their steam account in steamID3 format as such

	"Admins" : ["[U:1:298372543]", "[U:1:413413472]"]*
 
 
 
##### m/config <setting> <value> <objtype> - changes server config temporarily
```
	Example: m/config BhopTickWindow 5 int
		Sets the bhoptickwindow to 5 ticks
	Use m/config with no parameter to print config options in console
```
 
##### m/admincrazy <userid>/<me> - enables a powerplay type admin mode for the user
```
	Example: m/admincrazy 4
	Example: m/admincrazy me
		Admincrazy has different effects for the non standard rocket launchers, stock remains default
```
