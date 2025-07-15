# MGA Vscript Rewrite Documentation
For plugin creators\
\
Courtesy of Mellow\
Please notify of issues or suggestions to this on the github page

## Triggers to interact with the script
### Portal doors
Use a trigger_multiple and add the output
OnStartTouch, targetting the logic_script entity (script_runner in prefabs), with the RunScriptCode input, and a parameter of
```portaldoor(`arenaname`)``` for example ```portaldoor(`m`)``` for modern arena.

### Rocket Explode Volumes
These are quite complicated, use the included prefabs map to better your understanding. Images and better documentation for these will be written in future.

### Rocket slow + drop down & Vertical Rebound
Your map must include a filter for rockets and cow mangler projectiles, this can be found in the prefabs map and is named Is_Rocket.
Use a trigger_multiple with the flag 'Everything (not including physics debris)' and add an output as such
OnStartTouch, targetting the !activator entity (run script on the rocket), with the RunScriptCode input, and a parameter of
RocketRebound(0) for slow + drop OR RocketRebound(1) for vertical rebound.

### Fixed Spawn push triggers
This version of mga uses vscript controlled emulated 'push' triggers to prevent the super catapults that occur randomly depending on your ping. To set these up you can start with a normal trigger_push, make sure to note down the desired angle and push force.
Then convert this into a trigger_multiple (needed because push cannot fire the same outputs, and always exerts some force even if set to 0).
Then set the 'Clients' flag, and set the 'Delay Before Reset' ('wait' in simple edit mode) to 0.015, this ensures a force is applied to the player every tick, mimicking how trigger_push functions. Now add an output as such
OnTrigger, targetting the logic_script entity (script_runner in prefabs), with the RunScriptCode input, and a parameter of
vpush2(speed, x,y,z) replacing speed with the velocity setting from your original push trigger, and setting x, y, and z to the angle components from your original trigger.

### Auto EdgeBug triggers
These exist to help ensure consistent auto edgebugs.
To create one place a trigger over the bottom of the ramp, tweak this as you desire.
Set this to trigger_multiple, with a 'Delay Before Reset' ('wait' in simple edit mode) to 0.1.
Enable only the 'Clients' flag, and add an output as such
OnStartTouch, targetting the logic_script entity (script_runner in prefabs), with the RunScriptCode input, and a parameter of
autoeb(1).

### Enabling crit with triggers
Simple use any output (OnCatapulted, OnTrigger, OnStartTouch, anything) matching your desired use case. Target the logic_script entity (script_runner in prefabs), with the RunScriptCode input, and a parameter of
jumppad(1).

## Plugin config options
Modification guide\
simply edit these values as such
```js
::PluginsConf["ClassRestrict"] <- Constants.ETFClass.TF_CLASS_DEMOMAN
```
### ClassRestrict
Accepts constant values for classes, as well as the value false to allow any class
### MgaAmmoResupply
Modifying this should be advised against, this value is applied to all players with no discretion. If multiple plugins are running and change this value, then the last ran function will override this and potentially cause issues for other plugins. To solve this please see [UpdateWeapons funcs](#updateweapons), guide for using pre+post funcs to control resupply==
However, if you should still decide to use this simply modify it with
```js
PluginsConf["MgaAmmoResupply"] <- false
```
### CommandsHelp
This value allows plugins to add their own help information for custom commands, as well as letting the main script know your commands are valid.
To add your commands to this use something along these lines
```js
PluginsConf["CommandsHelp"].rawset("arenaconc", "<arena name> - Changes conc arena")
PluginsConf["CommandsHelp"].rawset("adminconc", "- Toggles conc anywhere")
```
Note the value of the key is not needed. It merely gives the information to print in command help dialog, the `<parameters>` is just courtesy to help players understand how to format their command uses. 
## Plugin supported funcs

> [!IMPORTANT]  
> Use the below table to check the available local variables in both pre and post functions
**DO NOT INCLUDE PARAMETERS IN YOUR FUNCTION DEFINITION**  

*ignore the lazy formatting on the lists*
```js
"PreFuncs" : {
	"UpdateWeapons" : "player"
	"PostRocketHit" : "self"
	"PlayerThink" : "self"
	"PerSecond" : "timedmsg"
	"CustomGameDeath" : "killp, deadp"
	"DummyDeathCheck" : "deadp"
	"KillInfoSend" : "killp, deadp"
	"DuelDeath" : "killp, deadp"
	"CustomGameSuicide" : "deadp"
	"DuelInstSpawn" : "killp"
	"MgaInstSpawn" : "deadp"
	"CustomGameTeamSwitch" : "player, parteam"
	"TeamLockManage" : "player, params, parteam"
	"CustomGameDisconnect" : "player"
	"MgaDamageManage" : "ent, inflictor, params, attacker, weapon"
    //Sorry these last few haven't been fully tested yet VV
    "CustomGameLogic" : ""
    "SwingTrace" : ""
    "Bhopped" : ""
    "DuelWon" : ""
    "OnPlayerVoiceline" : ""
} 
"PostFuncs" : {
	"UpdateWeapons" : "health, player, weapon"
	"PostRocketHit" : "vel"
	"PlayerThink" : "buttons_pressed, buttons, vel, lastjtime, lastVel, player, bhopped, buttons_changed, buttons_released, weapon"
	"PerSecond" : "timedmsg"
	"CustomGameDeath" : "deadp, killp"
	"DummyDeathCheck" : "deadp"
	"KillInfoSend" : "deadp, killp"
	"DuelDeath" : "deadp, killp"
	"CustomGameSuicide" : "deadp"
	"DuelInstSpawn" : "killp"
	"MgaInstSpawn" : "deadp"
	"CustomGameTeamSwitch" : "player, parteam"
	"TeamLockManage" : "parteam, player, params"
	"CustomGameDisconnect" : "player, list"
	"MgaDamageManage" : "attacker, params, inflictor, ent, weapon"
    //Sorry these last few haven't been fully tested yet VV
    "CustomGameLogic" : ""
    "SwingTrace" : "trace"
    "Bhopped" : "buttons_pressed, buttons, vel, lastjtime, lastVel, player, bhopped, buttons_changed, buttons_released, weapon" //?? This should include most of these values from the playerthink function, but has not been tested. Use with caution, at least the vel value has been supplied
    "DuelWon" : "p1, p2, s1, s2, a, t, dom = false, r = 0" //p1 is winner, p2 is loser, s1 is winner score, s2 is loser score, a is duelarena, t is dueltype, dom is whether or not it was a dom duel, r is restarts value if it was a dom duel
    "OnPlayerVoiceline" : "player, scene" //Should include at least these, probably others from the player think scope
}
```

Attach before and after these functions like such
```js
PluginsConf["PostFuncs"]["UpdateWeapons"] += ";POST_Concwep()"
...


::POST_Concwep <- function() //Note the lack of parameters, as the needed local and global variables are passed into the scope already
{
...
}
```


### UpdateWeapons
This function is run on every player each second. It refreshes their weapon attributes to ensure they function correctly for the gamemode. It also handles the admincrazy mode and the juggernaut weapon modifications.  
\
This is applied to every player and both heals them **and** refills their ammo and magazine of all weapons!
\
This can cause issues for plugins which need certain players or certain weapons to either never be resupplied or be resupplied if a certain condition is met.
\
\
There are two methods of doing this, you can use
> [!WARNING]
> this method is dangerous if multiple plugins modify this value
```js
PluginsConf["MgaAmmoResupply"] <- false
```


to disable resupply for all players at all times, then use a post updateweapons function to resupply all players who **DO** need resupply, avoiding those who the plugin deems shouldn't be resupplied.
\
\
The better method for doings this involves using both a pre and post UpdateWeapons function in order to detect if the player shouldn't be resupplied and set their 
```js
player.GetScriptScope().resupply <- false
```
Here is a basic setup example
```js
PluginsConf["PreFuncs"]["UpdateWeapons"] += ";PRE_Concwep()"

PluginsConf["PostFuncs"]["UpdateWeapons"] += ";POST_Concwep()"
...


::PRE_Concwep <- function()
{
    // Note that concuser is set true or false elsewhere
	if (player.GetScriptScope().concuser)
	    {player.GetScriptScope().resupply <- false}
	else
	    {player.GetScriptScope().resupply <- true}
}

::POST_Concwep <- function()
{
    //This restores the magazine clip of the players primary weapon to 50, and sets their clip to its maximum size
	if (player.GetScriptScope().concuser)
	{
		weapon.SetClip1(weapon.GetMaxClip1())
		NetProps.SetPropIntArray(player,"m_iAmmo",50,1)
        player.GetScriptScope().resupply <- true
	}
}
```
### PostRocketHit
Called a tick after a player is hit by a rocket.  
As such
```js
EntFireByHandle(ent, "CallScriptFunction", "PostRocketHit", 0.015, null, null);
```
The purpose of this function is to check if the player has actually left the ground the tick after the rocket jump. If they have indeed left the ground then grant then crit.\
\
This prevents players gaining crit for a single tick whilst still on the ground.\
Plugins should queue this function in this way whenever they want to give the player crit for being hit by something.
For example
```js
// If damage inflicted by a sticky or pipe then call postrockethit
if (inflictor.GetClassname() == "tf_projectile_pipe" || inflictor.GetClassname() == "tf_projectile_pipe_remote" ||params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_STICKBOMB_EXPLOSION)
	{
		EntFireByHandle(ent, "CallScriptFunction", "PostRocketHit", 0.015, null, null);
	}
```
Note that the function is not ran **alongside** `player.GetScriptScope().CanCrit <- true` and instead replaces the crit = true.
### PlayerThink
This runs many functions every tick for each player. Its used for bhop detection, custom game player modifications, showing text on screen if needed, and a few more miscellaneous things.
\
\
This function is very useful for plugin makers and includes many local variable that are used for a variety of things
> [!NOTE]
> If your plugin is ran after the main script, values that you apply during player_spawn may not be present for players who haven't respawned since before your script was executed. You should thoroughly test for this possibility and implement a solution as such

```js
if (!("caber" in player.GetScriptScope()) || !("cabertime" in player.GetScriptScope()))
	{
		player.GetScriptScope().cabertime <- null
		player.GetScriptScope().caber <- null
	}
```

Here is an example use of the playerthink function (in the sample demo mga plugin), which checks if the players caber has detonated and if so set a variable for the time which it should be restored. If enough time has passed since the player last detonated their caber melee and restores it if so
```js
//RUN CABER CHECK
if (player.GetScriptScope().caber != null) {
	local weapon = player.GetScriptScope().caber //Note that the local weapon variable passed into this functions scope from the playerthink function is actually referencing the players primary weapon. Because of this elsewhere in the demo mga plugin the players caber is saved into the players scope and fetched again here

    if (GetPropBool(weapon, "m_iDetonated") == true) {
        if (player.GetScriptScope().cabertime == null)
        {
                player.GetScriptScope().cabertime <- (Time() + 3)
        }
        if (Time() >= player.GetScriptScope().cabertime && player.GetScriptScope().cabertime != null)
        {
                NetProps.SetPropBool(weapon, "m_iDetonated", false)
                weapon.SetBodygroup(0, 0)
                player.GetScriptScope().cabertime <- null
        }
    }
}
```
### PerSecond
This is ran once per second for the server. It does not directly target any player and thus will not be as useful as PlayerThink and CustomGameLogic.\
If your custom gamemode needs logic ran per second like the main script does, you shouldn't use this and should instead make your function post CustomGameLogic.
\
\
The most common use case of this would be deleting banned items or modifying allowed items in the same way the main script deletes the banners and base jumper in this function.
Here is a sample from the demo mga plugin
```js
for (local item; item = Entities.FindByClassname(item, "tf_wearable");)
{
    local itemIndex = NetProps.GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
    if (itemIndex == 608	|| // bootlegger
        itemIndex == 405	 // booties
        )
    {
        item.AddAttribute("move speed bonus shield required", 1,-1)
        continue
    }
}

for (local item; item = Entities.FindByClassname(item, "tf_wearable_demoshield");)
{
    local itemIndex = NetProps.GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

    // Tide, spendid, targe
    if (itemIndex == 1099 || itemIndex == 406 || itemIndex == 131){


        item.AddAttribute("mult dmgtaken from fire" 1, -1)
        item.AddAttribute("mult dmgtaken from explosions" 1, -1)
        item.AddAttribute("lose demo charge on damage when charging" 1, -1)
        item.AddAttribute("full charge turn control" 50, -1)
        item.AddAttribute("kill refills meter" 1, -1)
        if (itemIndex != 406) {
        item.AddAttribute("charge recharge rate increased" 1.5, -1)}

    continue}
}
```
### CustomGameDeath
Ran when death is due to player and is not suicide\
This is ran whenever a player dies **NOT WHEN THEY DIE WHILST IN A GAMEMODE**. This is fine because even if it ran only whilst in a gamemode you would still need to waste time checking which gamemode it was.
So first things first check if they were in the gamemode you're modifying the death logic for.
```js
	if ("arena" in deadp.GetScriptScope()) { //Just a basic check for if they player has an arena in their scope. Most of the time this is unnecessary but can prevent some strange issues when the script is executed while the player is alive AND already in the gamemode arena

        //Check if arena is one of the conc gamemode arenas and that it wasn't a suicide
		if (CustomsList["conc"].find(deadp.GetScriptScope().arena[1]) != null && killp.GetTeam() != deadp.GetTeam()) {
            ...
        }
    }
```
### DummyDeathCheck
Ran when death is due to player and is not suicide\
Tiny function for testing if the player who died was a training dummy, and if so moving their spawn to the next stage.\
This is modifiable by plugins if they seek to change the behaviour of the training dummy or create their own training system which for instance moves the dummy along a different set, or random path.
\
\
Just make sure to first check if the dead player **IS** actually the desired bot\dummy like so
```js
if ((NetProps.GetPropString(deadp, "m_szNetname") == "BDummy") || (NetProps.GetPropString(deadp, "m_szNetname") == "RDummy"))
{
    ...
}
```
### KillInfoSend
Ran when death is due to player and is not suicide\
Simple function which checks if either the dead or killed player has killinfo set to true, then sends them the hop# and velocity of themselves and their kill/killer\
\
This is very unlikely for a plugin to need, but could be useful to someone making for example a leaderboard for highest velocity or bhop# kills. This is because it runs on all deaths, **then checks if killinfo is enabled** meaning your plugin can do anything here, although it could also do the same thing in the other death functions.
The main script uses it as such:
```js
if (deadp.GetScriptScope().killinfo == true)
{
    TextWrapSend(deadp, 3, (smpref+"You died with: V:\x07FFFF00"+deadp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+deadp.GetScriptScope().hopnum+"\x01\n"+smpref+"Opponent had: V:\x07FFFF00"+killp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+killp.GetScriptScope().hopnum))
}
if (killp.GetScriptScope().killinfo == true)
{
    TextWrapSend(killp, 3, (smpref+"Got a kill with: V:\x07FFFF00"+killp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+killp.GetScriptScope().hopnum+"\x01\n"+smpref+"Opponent had: V:\x07FFFF00"+deadp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+deadp.GetScriptScope().hopnum))
}
```
### DuelDeath
Ran when death is due to player and is not suicide\
Another on death function, this one first checks if the killed player was in a duel, then checks the duel type, then performs score checks and if the score is >= the max for that duel type does the duel win logic

Just going to put this code block here to show examples of a few things that are handled here and could be handled or modified by a plugin. There are no local values passed other than both the killed player and the killer, the values you may want will be accessible in their scope.
```js
//Check if in duel
if (killp.GetScriptScope().arena[0] == "D"|| killp.GetScriptScope().arena[0] == "DI") {
        //If killer and killed are not in same duel arena then return
		if (killp.GetScriptScope().arena[1] != deadp.GetScriptScope().arena[1]) {return;}
        //If any duel type other than dom
		if (killp.GetScriptScope().dtype == "ft10" || killp.GetScriptScope().dtype == "bhop" || killp.GetScriptScope().dtype == "vel") {

			//Point math 
			if (killp.GetScriptScope().dtype == "ft10") {
			killp.GetScriptScope().score <- (killp.GetScriptScope().score + 1)}
			if (killp.GetScriptScope().dtype == "bhop") {
			killp.GetScriptScope().score <- (killp.GetScriptScope().score + 1 + killp.GetScriptScope().hopnum)}
			if (killp.GetScriptScope().dtype == "vel") {
			local kvel = killp.GetAbsVelocity()
			local extra = ((kvel.Length()+deadp.GetScriptScope().lvel)/250)
			extra = extra.tointeger() + ceil((1 - (ceil(extra) - extra)) * 10)/10;
			killp.GetScriptScope().score <- (killp.GetScriptScope().score + 1 + extra)}


            //Example of how winning a duel is detected and handled
			if (killp.GetScriptScope().score >= 10 && killp.GetScriptScope().dtype == "ft10") {
				TextWrapSend(null, 3, (smpref+(killp.GetScriptScope().arena[1])+" t:\x07FFFF00"+killp.GetScriptScope().dtype+"\x01 "+::GetColouredName(killp)+" won against "+::GetColouredName(deadp)+" ("+killp.GetScriptScope().score+("/")+deadp.GetScriptScope().score+")"))

				killp.GetScriptScope().inMga <- true;
				killp.GetScriptScope().arena <- ["L","lobby"];
				killp.ForceRegenerateAndRespawn();
				killp.GetScriptScope().score <- 0
				deadp.GetScriptScope().inMga <- true;
				deadp.GetScriptScope().arena <- ["L","lobby"];
				deadp.ForceRegenerateAndRespawn();
				deadp.GetScriptScope().score <- 0
			}
		}


    ...

    //Score check and show score to spectators functions
	dScoreCheck(killp.GetScriptScope().arena[1], killp, true)
	SpecDuelMsg(deadp.GetScriptScope().arena[1], deadp, killp, deadp.GetScriptScope().dtype)
	}
```
### CustomGameSuicide
This functions is **ONLY** ran if the death was a suicide. It only checks if it was a suicide in a custom game after running the pre function, and still runs the post func too. So perhaps treat this as a suicide detecting function, not for custom games alone.
\
\
Not too much to talk about here but this code block is just an easy sample of what you may want to do upon a suicide within a custom game
```js
//If in infection gamemode
if (CustomsList["inf"].find(deadp.GetScriptScope().arena[1]) != null && deadp.GetTeam() == 2) {
    deadp.GetScriptScope().teamlock <- 5 //teamlock <- 5 means to lock the team to that which they next switch to
    ForceSwapTeam(deadp) //Immediately switches the player to the zombies team, and as per the last line locks them to that team
}

//If in juggernaut gamemode and on juggernaut team
if (CustomsList["jugg"].find(deadp.GetScriptScope().arena[1]) != null && deadp.GetTeam() == 3 && deadp.GetScriptScope().teamlock == 3) {
    
    //force to the other team, and lock there
    deadp.GetScriptScope().teamlock <- 5
    EntFireByHandle(deadp, "CallScriptFunction", "TChangePreventR", 0, null, null);


    //Randomly select a player from the hunters team
    local picked = []
    local searched = JuggList["2"]
    for (local j = 0; j < 1 ; j++)
    {
    local slot = rand();
    slot = slot % searched.len();
    picked.append(searched[slot])
    searched.remove(slot)
    }

    //For the picked player switch their team, make them juggernaut, and respawn them
    foreach (i in picked) {
    i.GetScriptScope().teamlock <- 5
    i.ForceChangeTeam(3,true)
    i.ForceRespawn()
    TextWrapSend(i, 3, (smpref+"\x07FC0324YOU ARE JUGGERNAUT!"))
    i.GetScriptScope().juggkills <- 0
    }

}
```
### DuelInstSpawn
This is ran on all deaths that are due to a player **INCLUDING** suicide\
It just simply respawns players after 0.2 seconds 
> [!NOTE]
> Respawning the player the same tick they die, or the tick after causes issues with ragdolls and other players being headbounced by velocity they may gain on death

This function runs as such
```js
//Check if in arena designated for instant spawns (This means both players respawn when a kill occurs)
if (killp.GetScriptScope().arena[0] == "DI") {
    EntFireByHandle(killp, "CallScriptFunction", "InstaSpawn", 0.02, null, null);
}
```
Feel free to use this function for anything your plugin may need that should occur on death to a player, including a suicide. Although such a criteria will be rare.

### MgaInstSpawn
This is just like the previous function but runs for all players upon death, even if it wasn't due to a player (such as team switches).\
It simply runs 
```js
EntFireByHandle(deadp, "CallScriptFunction", "InstaSpawn", 0.02, null, null);
```
But perhaps your plugin may desire some on all deaths functions
### CustomGameTeamSwitch
You likely won't have to modify this, it serves the allocate players to the correct team lists for the gamemode they are in when they switch teams (likely when forced to switch by the gamemode mechanics)
It is passed the player and parteam variables, parteam just being the team they desire to switch to and the function allows switching into spectator\
Mostly useful for the team list managing and finding a new juggernaut when one switches to spectator
```js
if (parteam == 0 || parteam == 1) {
    player.GetScriptScope().teamlock <- 0

	if (CustomsList["all"].find(player.GetScriptScope().arena[1]) == null) {return}

	if (CustomsList["jugg"].find(player.GetScriptScope().arena[1]) != null && player.GetTeam() == 3) {
        ...
    }
}
	
```
### TeamLockManage
This one will be slightly more useful than CustomGameTeamSwitch as it is passed the team change events params. Do what you please here using params.oldteam and parteam variables.\
\
Just make sure you test well and ensure no infinite team switching loops can occur, that is why the player.GetScriptScope().teamlock value is useful and should be utilised when locking players teams at the same time as team switching them.\
\
Here is a simple check for if the player is locked to the team they are attempting to switch away from.
```js
if (player.GetScriptScope().teamlock == 3 && params.oldteam == 3)
{
    ...
}
```
also use\
`EntFireByHandle(player, "CallScriptFunction", "TChangePreventR", 0, null, null);`\
and\
`EntFireByHandle(player, "CallScriptFunction", "TChangePreventB", 0, null, null);`\
to easily prevent team changes, just note the names are what team they are **keeping you on**, such that TChangePreventB will put you back on blue team
### CustomGameDisconnect
This runs whenever a valid player disconnects, not only when in a custom gamemode.\
Just note that the post function here will only be ran if they **are** in a custom gamemode
```js
	if (!("arena" in player.GetScriptScope())) {return} //VERY USEFUL, THIS CHECKS IF THE PLAYER HAS ACTUALLY BEEN INITIALISED, AND IF NOT RETURNS, THIS PREVENTS MANY ERRORS
	if (CustomsList["all"].find(player.GetScriptScope().arena[1]) == null) {return}
    //RETURNS IF NOT IN A CUSTOM GAME

    //searches for player in lists
	local list = null
	foreach(key, value in CustomsList) {
		if (key == "all") {continue}
		if (value.find(player.GetScriptScope().arena[1]) != null) {
			list = CustomListMatchip[key]
		}
	}

    //removes player from lists if found
	if (list[player.GetTeam().tostring()].find(player) != null) {
		list[player.GetTeam().tostring()].remove(list[player.GetTeam().tostring()].find(player))}

```
### MgaDamageManage
Runs whenever a valid player takes damage. It has access to many variables already as well as the OnTakeDamage event's params.\
Use this when you like, you can also in most cases use your own OnTakeDamage event. This really exists only for saving time with plugin creation and for if strange conflict issues occur when multiple scripts modify the values in their own OnTakeDamages in an unclear hierarchy.
### CustomGameLogic
This is ran once per second **at least** and more depending on when the logic is needed, it is ran like so
```js
RunWithDelay(0, function(){CustomGameLogic()})
```

This function is useful for plugins that manage custom gamemodes, here is an example from the sample mga conc plugin
```js
// if not running, check for needed players
if (ConcRunning == false) {
    if (ConcList["2"].len() > 0 && ConcList["3"].len() > 0) {

    //Fetch all players from Conc gamemode list (this is managed elsewhere)
    local playlist = []
    foreach (i in ConcList["2"]) {
        playlist.append(i)
    }
    foreach (i in ConcList["3"]) {
        playlist.append(i)
    }

        //Announce gamemode start, and change running variable
        foreach (i in playlist) {
        i.ForceRespawn()
        TextWrapSend(i, 3, (smpref+"\x0796ff96CONC THEM!"))
        TextWrapSend(i, 3, (smpref+"help available with "+Config["Prefix1"]+"help conc"))
        }
        ConcRunning <- true;
    }
}

//While gamemode running
if(ConcRunning) {

    //If no player on either team check who should lose and announce, then queue new gamelogic
    if (ConcList["3"].len() == 0 || ConcList["2"].len() == 0)
    {
    ConcRunning <- false;
    ConcTeamScores["3"] <- 0
    ConcTeamScores["2"] <- 0

    local playlist = []
    foreach (i in ConcList["2"]) {
        playlist.append(i)
    }
    foreach (i in ConcList["3"]) {
        playlist.append(i)
    }

    if (ConcList["3"].len() == 0) {
        foreach(i in playlist) {
            TextWrapSend(i, 3, (smpref+"\x07FF3F3FRed WINS!"))
            i.GetScriptScope().teamlock <- 5
        }}
    else {
        foreach(i in playlist) {
            TextWrapSend(i, 3, (smpref+"\x0799CCFFBlue WINS!"))
            i.GetScriptScope().teamlock <- 5
        }
    }

RunWithDelay(0, function(){CustomGameLogic()})
}
//if running and has enough players
else {
    local playlist = []
    foreach (i in ConcList["2"]) {
        playlist.append(i)
    }
    foreach (i in ConcList["3"]) {
        playlist.append(i)
    }

    //Show scoreboard on screen
    foreach (i in playlist) {
        ::ShowTextScore(i, ("B:"+ConcTeamScores["3"]+"\nR:"+ConcTeamScores["2"]+"\nof:"+ConcMaxScore))
    }
}

//If one team has enough score to win, do text stuff, then queue new gamelogic
if (ConcTeamScores["2"] >= ConcMaxScore || ConcTeamScores["3"] >= ConcMaxScore)
{
    ConcRunning <- false;

    local playlist = []
    foreach (i in ConcList["2"]) {
        playlist.append(i)
    }
    foreach (i in ConcList["3"]) {
        playlist.append(i)
    }
    //Do win messages
    if (ConcTeamScores["2"] >= ConcMaxScore) {
        foreach(i in playlist) {
            TextWrapSend(i, 3, (smpref+"\x07FF3F3FRed WINS!"))
            i.GetScriptScope().teamlock <- 5
        }}
    else {
        foreach(i in playlist) {
            TextWrapSend(i, 3, (smpref+"\x0799CCFFBlue WINS!"))
            i.GetScriptScope().teamlock <- 5
        }
    }
    ConcTeamScores["3"] <- 0
    ConcTeamScores["2"] <- 0
RunWithDelay(0, function(){CustomGameLogic()})
}
}
```
### SwingTrace
This runs whenever a player swings their melee. It detects if the player hits a teammate, and if so retraces to see if an opponent should instead be hit.\
\
Its prefunc will only be useful for detecting **any** melee swing.
However, its postfunc allows you to easily detect when a player has hit their teammate as such
```js
//If concuser (set elsewhere) hit a player, who is also a teammate
if (player.GetScriptScope().concuser && ("enthit" in trace) && trace.enthit.IsPlayer() != 0 && trace.enthit.GetTeam() == player.GetTeam()) {
    //Send text to both the players' screens and set the hit teammate to be the concuser
    TextWrapSend(trace.enthit, 4, ("GIVEN THE CONC!"))
    trace.enthit.GetScriptScope().concuser <- true
    giveweaponcustom(trace.enthit, "conc")


    TextWrapSend(player, 4, ("GAVE AWAY THE CONC!"))
    player.GetScriptScope().concuser <- false
    SetEntityColor(player,255,255,255,255)
    player.Regenerate(true)
    return
	}
```
### Bhopped
This is ran whenever a player successfully bhops. It normally does nothing but has been included to help plugins do things on bhop, without having to manually detect it themselves.
This was used in the mga conc gamemode to give concusers back their velocity upon successfully bhopping to simulate how it would work in tfc.\
\
This was very simply done as such
```js
if (player.GetScriptScope().concuser)
{
vel.z = 289 - ( (800 * 0.015)/2 )
player.SetAbsVelocity(vel)
}
```
### DuelWon
This is ran whenever a duel ends. It does nothing normally, but is included to help plugins detect duel wins, and parse the info about the duel.
This was used with an optional vscript addon to pass the duel information to a custom sourcemod on our official mga rewrite servers to log duel results into a discord channel.
```js
function getuserid(c)
{
	return NetProps.GetPropIntArray(playermanager, "m_iUserID", c.entindex());
}

function post_DuelWon()
{
		// Uses fish notice event because it includes many int values, 2 string values, and 1 bool value, perfect for all the needed duel info
		// It also isn't called in normal mga since the holy mackerel is for scout
		// even so a check has been put in place to ensure false detections
		// by making stun_flags = -22 we set it to a value it can never normally be,
		// then the sourcemod plugin will only continue with the event if that unnatural value is present
		SendGlobalGameEvent(
			"fish_notice",
			{
				stun_flags = -22
				attacker = getuserid(p1),
				userid = getuserid(p2),
				weaponid = s1
				customkill = s2
				weapon = a
				weapon_logclassname = t
				silent_kill = dom
				assister = r
			});
}
::PluginsConf["PostFuncs"]["DuelWon"] += ";post_DuelWon()";
```
Then sourcemod fetches this info as such
```pawn
public void OnPluginStart()
{
    //... other stuff here
    //Mellow duel link up
    HookEvent("fish_notice", event_player_fishnotice, EventHookMode_Pre);
}

public Action
event_player_fishnotice(Event event, const char []name, bool dontbroadcast)
{
	int userid = GetEventInt(event, "stun_flags");
	if(userid != -22)
		return Plugin_Continue;

	int wuid = GetEventInt(event, "attacker");
	int luid = GetEventInt(event, "userid");
    int wscore = GetEventInt(event, "weaponid");
    int lscore = GetEventInt(event, "customkill");


    
    char arena[64];
    GetEventString(event, "weapon", arena, 64, "");
    char type[64];
    GetEventString(event, "weapon_logclassname", type, 64, "");

    bool dom = GetEventBool(event, "silent_kill");
    
    int restarts = GetEventInt(event, "assister");

	int winner = GetClientOfUserId(wuid);
	int loser = GetClientOfUserId(luid);

    PrintToDiscordDuelWin(winner, loser, wscore, lscore, arena, type, dom, restarts, PURPLE); //This is a custom function that handles the logging to the discord server.

	return Plugin_Handled;
}
```

### OnPlayerVoiceline
Ran whenever a player emits a voiceline, this is useful for detecting taunts beginning or taunt actions. As well as the use of specific voicelines to trigger things, or for manipulating pain sounds.\
\
This is used in the mga tanktaunt plugin in order to detect taunt beginnings, ends, and actions as such
```js
local playerScope = player.GetScriptScope();
if (playerScope == null)
    return;
local name = NetProps.GetPropString(scene, "m_szInstanceFilename")

if (endswith(escape(name), "taunt_vehicle_tank_fire.vcd"))
{...}
if (endswith(escape(name), "taunt_vehicle_tank.vcd"))
{...}
if (endswith(escape(name), "taunt_vehicle_tank_end.vcd"))
{...}
```
