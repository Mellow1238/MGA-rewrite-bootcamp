//MGA VSCRIPT REWRITE BY MELLOW

/*
 * Globals and constants
 */

// uncommented line search ^((?!//|/\*).)*TEXT


::BhopUi <- false //BhopUi used to check if mapper has packed the optional bhopui script and hopefully the associated models
::InitialiseNeeded <- false //Used to check if main script was executed from console or script_runner entity

::PlayerManager <- Entities.FindByClassname(null, "tf_player_manager")

::GetPlayerUserID <- function(player) //Define easy userid fetch
{
    return NetProps.GetPropIntArray(PlayerManager, "m_iUserID", player.entindex())
}

if (Entities.FindByName(null, "script_runner") == null) {
	self <- SpawnEntityFromTable("logic_script", {
		targetname = "script_runner"
		ThinkFunction = "PerSecond"
		vscripts = "mga_script.nut"
}) //Checks if script_runner present if not then respawn all players and initialise them below

for (local i = 1; i <= MaxPlayers ; i++)
{
	local player = PlayerInstanceFromIndex(i);
	if (player == null || player.IsFakeClient() == true) {continue}
    player.ForceRegenerateAndRespawn();
}

::InitialiseNeeded <- true
Convars.SetValue("mp_waitingforplayers_cancel", 1)
Convars.SetValue("mp_teams_unbalance_limit", 0)
Convars.SetValue("tf_weapon_criticals", 0)
}

function Include(file) //Easy script runner function
{
	IncludeScript(file + ".nut", this);
}


//VV Just shows the defaults for ease of use VV

//CONFIG TEMPLATE
// ::Config <- {
// 	"Admins" : []
// 	"AutoRunPlugins" : []
// 	"Prefix1" : "m/"
// 	"Prefix2" : "mg_"
// 	"BhopTickWindow" : 0
// 	"Jpractice" : false
// 	"DuelsAllowed" : true
// 	"TrainingAllowed" : true
// 	"AllowedDtypes" : ["dom", "vel", "bhop"]
// 	"BannedDarenas" : []
// 	"BannedArenas" : []
// 	"Debug" : false
// 	"LobbyBot" : true
// 	"SpecVolumes" : true
// 	"infadd" : null
// 	"juggadd" : null
// 	"freezeadd" : null
// 	"InfRatio" : 5
// 	"JuggRatio" : 10
// }


//Table containing all config options, admins can change these in game with m/config (other than Admins, and AutoRunPlugins)
::Config <- {
	"Admins" : ["[U:1:298372543]", "[U:1:413413472]"]	// FORMATTED AS SUCH ["[U:1:298372543]", "[U:1:413413472]"]
	"WelcomeMSG" : "Welcome to mga_bootcamp, a new remade version of mga written entirely in vscript that YOU can host yourself plugin-free."
	"TimedMSG": ("This map contains many new features such as new arenas, a brand new training mode, various quality of life changes, new duel specific arenas, and new duel types. For more informations please use the m/help command. Have fun!")
	"AutoRunPlugins" : []	// array of plugin names as strings DO NOT INCLUDE .NUT	Correct format should be ["mga_utrl","mga_tanktaunt"]
	"Prefix1" : "m/"	//Available chat prefix 1
	"Prefix2" : "mg_"	//Available chat prefix 2
	"BhopTickWindow" : 0	//Amount of leniancy ticks for bhops, defaults to tick perfect, negative numbers disable bhop
	"Jpractice" : false		//Enables/Disables practice mode
	"DuelsAllowed" : true	//Enables/Disables duels and their chat commands
	"TrainingAllowed" : true	//Enables/Disables the training area in bootcamp map
	"AllowedDtypes" : ["dom", "vel", "bhop"]	//Duel types allowed as well as ft10
	"BannedDarenas" : []	//Duel arenas that cannot be accessed as array of strings e.g ["pool", "free"]
	"BannedArenas" : []		//Main arenas that cannot be accessed as array of strings e.g ["m","f"]
	"Debug" : true		//Enables/Disables debug commands
	"LobbyBot" : true	//Enables/Disables lobby dummy
	"SpecVolumes" : true	//Enables/disables spectate volumes for auto score updates by spectator cam position
	"infadd" : null		//string name of an arena which will be designated for infection mode
	"juggadd" : null	//Above but for jugg
	"freezeadd" : null	//Above but for freeze
	"InfRatio" : 5		//Ratio of total players : initial zombie amount. e.g 5 = 4 humans, 1 zombie
	"JuggRatio" : 10	//Above but for juggernaut. e.g 10 = 9 hunters, 1 jugg
}


//Table containing many values that should only be manipulated by plugins
::PluginsConf <- {
	"ClassRestrict" : Constants.ETFClass.TF_CLASS_SOLDIER
	/*default:Constants.ETFClass.TF_CLASS_SOLDIES
		Plugins can change the above value to false for any class
		or the const for a class they desire*/

	"MgaAmmoResupply" : true
	/*Toggles the mga-rewrite script handling player ammo regen every second
		This is useful if your plugin has custom criteria for when to regen ammo*/

	"CommandsHelp" :
	{
		// "test" : "- tests stuffs"
	}
	/*Plugins can add keys to this table to allocate available commands
		The values of those key entries will be the help info for that command

		Example for plugins looking to add custom command support
		PluginsConf["CommandsHelp"].rawset("cheese", "<type> - all types are tasty")*/


//PLUGIN FUNCTION SUPPORTS============================================================
	/*
	Append ;Function() to append to these tables like so
		Like so: PluginsConf["PreFuncs"]["PlayerThink"] += ";PluginThinkFunc()"
	*/
	//TABLE OF PLUGIN FUNCS TO RUN BEFORE MAIN FUNCS
	"PreFuncs" : {
		"UpdateWeapons" : ""
		"PostRocketHit" : ""
		"PlayerThink" : ""
		"PerSecond" : ""
		"CustomGameDeath" : ""
		"DummyDeathCheck" : ""
		"KillInfoSend" : ""
		"DuelDeath" : ""
		"CustomGameSuicide" : ""
		"DuelInstSpawn" : ""
		"MgaInstSpawn" : ""
		"CustomGameTeamSwitch" : ""
		"TeamLockManage" : ""
		"CustomGameDisconnect" : ""
		"MgaDamageManage" : ""
		"CustomGameLogic" : ""
		"SwingTrace" : ""
		"Bhopped" : ""
		"DuelWon" : ""
		"ConfigRefresh" : ""
		"OnPlayerVoiceline" : ""
	}
	//TABLE OF PLUGIN FUNCS TO RUN AFTER MAIN FUNCS
	"PostFuncs" : {
		"UpdateWeapons" : ""
		"PostRocketHit" : ""
		"PlayerThink" : ""
		"PerSecond" : ""
		"CustomGameDeath" : ""
		"DummyDeathCheck" : ""
		"KillInfoSend" : ""
		"DuelDeath" : ""
		"CustomGameSuicide" : ""
		"DuelInstSpawn" : ""
		"MgaInstSpawn" : ""
		"CustomGameTeamSwitch" : ""
		"TeamLockManage" : ""
		"CustomGameDisconnect" : ""
		"MgaDamageManage" : ""
		"CustomGameLogic" : ""
		"SwingTrace" : ""
		"Bhopped" : ""
		"DuelWon" : ""
		"ConfigRefresh" : ""
		"OnPlayerVoiceline" : ""
	}
}



//Function refreshes gamemode arenas
//===================================WARNING===================================
// Causes issues with custom plugins, avoid use for now
::ConfigRefresh <- function()
{
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["ConfigRefresh"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	::CustomsList <- {
		"inf" : ["infect", Config["infadd"]]
		"jugg" : ["jugg", Config["juggadd"]]
		"freeze" : ["freeze", Config["freezeadd"]]
		"all" : ["infect", "jugg", "freeze", Config["infadd"], Config["juggadd"], Config["freezeadd"]]
	}

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["ConfigRefresh"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();
}

//Config override process
try {
	Include(GetMapName()+"_config");
	printl("map config found")
	foreach (key, value in FileConfig) {
	if (key == "BhopTickWindow" || key == "Admins" || key == "Debug" || key == "Prefix1" || key == "Prefix2") {continue}
	Config.rawset(key, value)
	}


} catch (exception) {
	printl("no map config")
	printl("please create "+GetMapName()+"_config.nut in tf/scripts/vscripts/ to configure")
}
try {
	Include("mga_config");
	printl("server config found")
	foreach (key, value in FileConfig) {
	Config.rawset(key, value)
	}


} catch (exception) {
	printl("no server config")
	printl("please create mga_config.nut in tf/scripts/vscripts/ to configure")
}






//Define masks for trace funcs
::PlayerTraceMask <- Constants.FContents.CONTENTS_LADDER |
	Constants.FContents.CONTENTS_PLAYERCLIP |
	Constants.FContents.CONTENTS_MOVEABLE |
	Constants.FContents.CONTENTS_MONSTER |
	Constants.FContents.CONTENTS_GRATE |
	Constants.FContents.CONTENTS_WINDOW |
	Constants.FContents.CONTENTS_SOLID;

::PlayerTraceMaskNoPlayers <- Constants.FContents.CONTENTS_LADDER |
	Constants.FContents.CONTENTS_PLAYERCLIP |
	Constants.FContents.CONTENTS_MOVEABLE |
	Constants.FContents.CONTENTS_GRATE |
	Constants.FContents.CONTENTS_WINDOW |
	Constants.FContents.CONTENTS_SOLID;



//Func converts arrays and tables into neat strings for chat and console
::ListConv <- function(obj, table, newline) {
	local output = ("")
	if (table) {
		if (newline) {
			foreach (key, value in obj) {
			if (output != ("")) {
				output = (output+"\n"+key)}
			else {output = key}
			}
		}
		else {
			foreach (key, value in obj) {
			if (output != ("")) {
				output = (output+", "+key)}
			else {output = key}
			}
		}
	}
	else {
		if (newline) {
			foreach (key in obj) {
			if (output != ("")) {
				output = (output+"\n"+key)}
			else {output = key}
			}
		}
		else {
			foreach (key in obj) {
			if (output != ("")) {
				output = (output+", "+key)}
			else {output = key}
			}
		}
	}
return(output)
}


::CustomSpeedo <- function(player, prefs)
{

	local vel = player.GetAbsVelocity()
	local speedo_custom = prefs
	speedo_custom = speedo_custom.tolower()

	local output = ""
	foreach (char in speedo_custom)
	{

		switch (char)
		{
			case 97:
				{
					output = output + (player.GetScriptScope().lvel.tointeger()) + "\n"
				break
				}
			case 120:
				{
					output = output + vel.x.tointeger() + "\n"
				break
				}
			case 121:
				{
					output = output + vel.y.tointeger() + "\n"
				break
				}
			case 118:
				{
					output = output + vel.z.tointeger() + "\n"
				break
				}
			case 104:
				{
					output = output + sqrt(pow(vel.x, 2) + pow(vel.y, 2)).tointeger() + "\n"
				break
				}
		}
	}
	return(output)

}


//Attempt to run bhopui script if packed
//===================================WARNING===================================
// DO NOT INCLUDE IN SCRIPTS FOLDER, THIS SHOULD ONLY BE PACKED ALONGSIDE ITS ASSET REQUIREMENTS BY MAPPERS
try {
	Include("mga_bhopui");
	// printl("bhopui script")
	::BhopUi <- true


} catch (exception) {
	printl("no mga_bhopui script\nThis is not needed, it should be added at the mapper's discretion as it requires packed assets")
	::BhopUi <- false

}


//Run plugins from the autorun list
foreach (i in Config["AutoRunPlugins"])
{Include(i)
printl("running plugin "+i)}


//Set countdown until next chat announcement
::NextChatMsg <- 0

::MaxPlayers <- MaxClients().tointeger();


//Define player lists for gamemodes, custom gamemode plugins will have to do this themselves
//Table keys are team ids and values are arrays on players
::InfList <- {
	"3" : []
	"2" : []
};
::JuggList <- {
	"3" : []
	"2" : []
};
::FreezeList <- {
	"3" : []
	"2" : []
};

//Lists all available arenas for gamemodes
::CustomsList <- {
	"inf" : ["infect", Config["infadd"]]
	"jugg" : ["jugg", Config["juggadd"]]
	"freeze" : ["freeze", Config["freezeadd"]]
	"all" : ["infect", "jugg", "freeze", Config["infadd"], Config["juggadd"], Config["freezeadd"]]
}

//Simple table for converting gamemode abbreviations into their associated lists
::CustomListMatchip <- {
	"inf" : ::InfList
	"jugg" : ::JuggList
	"freeze" : ::FreezeList
}


//Define basic global vals needed for gamemodes, custom gamemode plugins will need to do this themselves
::InfRunning <- false;
::InfLives <- 1;

::JuggRunning <- false;
::FreezeRunning <- false;


//Empty func for practice mode dummy spawning
::PracticeBotPos <- {}


//Define other globals for spawn collecting on script start
// ::PopCheck <- [];

::ASpawntab <- {};
::DSpawntab <- {};
::DISpawntab <- {};
::TSpawntab <- {};
::LSpawntab <- {};

::AvailableA <- [];
::AvailableD <- [];


::SpawnTypes <- {
    "A" : ASpawntab
    "D" : DSpawntab
	"DI" : DISpawntab
    "T" : TSpawntab
    "L" : LSpawntab
}

//Server message prefix
::smpref <- ("\x01"+"[\x07FFFF00s\x01] ");

//Combo names for bhop duels
local combonames = {
"1" : "\x07000000Boring\x01"
"2" : "\x079FFF00Basic\x01"
"3" : "\x0720FF00Bouncerific\x01"
"4" : "\x0700FF02Bountyful\x01"
"5" : "\x07ffe600BINGO!\x01"
"6" : "\x0700FF51Ballsy\x01"
"7" : "\x0700FF96Bashful\x01"
"8" : "\x07FFFFFFBlessed\x01"
"9" : "\x0700FFC7Baffling\x01"
"10" : "\x0700FFE9Bewildering\x01"
"11" : "\x0700EEFFBlissfully Barbaric\x01"
"12" : "\x0700CCFFBlatantly Barbaric!\x01"
"13" : "\x0700A5FFBlisteringly Barbaric!!\x01"
"14" : "\x070087FFBoldly Breathtaking\x01"
"15" : "\x070099FFBeautifully Breathtaking!\x01"
"16" : "\x070034FFBreathtakingly Breathtaking!!\x01"
"17" : "\x072600FFBadass\x01"
"18" : "\x076E00FFSuper Badass\x01"
"19" : "\x077400FFUltimate Badass\x01"
"20" : "\x079700FFBombastic\x01"
"21" : "\x07CD00FFBasically Bombastic!\x01"
"22" : "\x07FD00FFBelievably Bombastic!!\x01"
"23" : "\x07FFFFFFBiblically Bombastic!!!\x01"
"24" : "\x07FF0066BIZARRELY BOMBASTIC!!!!\x01"
"25" : "\x07FF0000BLASPHEMOUS?\x01"
}


//help COMMAND & TIMED
local connectmsg = (smpref+Config["WelcomeMSG"])
local timedmsg = (smpref+Config["TimedMSG"])

::help1 <- {
"null" : [(smpref+"Welcome to mga_bootcamp,"),"A remade version of jump academy's mga gamemode. We feature several new arenas, a brand new training mode, various quality of life changes, new duel specific arenas, and new duel types, as well as slightly different functionality for duels.","\x01To see more please use one of the various help commands\n\x07FFFF00"+Config["Prefix1"]+"help changes\n"+Config["Prefix1"]+"help arenas\n"+Config["Prefix1"]+"help duelsystem\n"+Config["Prefix1"]+"help duelarenas\n"+Config["Prefix1"]+"help dueltypes\n"+Config["Prefix1"]+"help training\n"+Config["Prefix1"]+"help commands\x01"]
"changes" : [(smpref+"Quality of life changes:"),"Improved bhop detection system with a 1 tick bhop window no matter the players ping","Speedshot/Bounce fixes allowing the player to keep their crit viability after a speedshot or bounce","Water floating changes allow players to keep their crit viability while holding jump to float on water"]
"arenas" : [(smpref+"Available arenas can be found with \x07FFFF00"+Config["Prefix1"]+"arena")]
"duelsystem" : [(smpref+"Instead of a challenge based duel system, the system present in this map is far more similar to that in the mge gamemode, in which players pick a duel arena and a dueltype to play in and wait in that arena until another player joins them."),"\x01To join a duel arena first check if another duel or player is waiting in that arena with the \x07FFFF00"+Config["Prefix1"]+"duels\x01 command","\x01If a duel arena is not listed then it is empty and available. To join one use the \x07FFFF00"+Config["Prefix1"]+"duel\x01 command followed by a duel arena abbreviation and a dueltype (if no dueltype is provided the default is ft10)","\x01use\x07FFFF00 "+Config["Prefix1"]+"help duelarenas\x01 for help with duel arenas"]
"duelarenas" : [(smpref+"Available dual arenas can be found with \x07FFFF00"+Config["Prefix1"]+"duel")]
"dueltypes" : [(smpref+"This map features some new duel types alongside the tradition first to 10 and domination duels.\nDuel types include:"),"\x07FFFF00ft10\x01 for a first to 10 duel\n\x07FFFF00dom\x01 for a first to dominate duel (with 4 available resets)\n\x07FFFF00bhop\x01 for a duel in which players earn bonus points for bhops chained before a kill (first to 25 points)","\x07FFFF00vel\x01 for a duel in which players earn bonus points for the velocity of both themselves and the player the killed (first to 25 points)","\x01Use Example:\n \x07FFFF00"+Config["Prefix1"]+"duel m1 vel\x01 for a velocity duel on duel arena modern 1"]
"training" : [(smpref+"The mga_bootcamp map features a training mode for newer players, or experienced players seeking to beat their best time."),"\x01Only one player per team can be training at any given time, if the training mode is available you can use \x07FFFF00"+Config["Prefix1"]+"training\x01 to join the training mode.","This mode is designed for you to test your own skill and practice as you see fit, if a stage is too difficult you may be able to bypass part of its challenge but learning is up to you."]
//"misc" : [(smpref+"There are a variety of miscellaneous commands including:\n\x07FFFF00/cshow\x01 will toggle an on-screen indicator of when you are crit viable\n\x07FFFF00/bshow\x01 will toggle printing in chat after a failed bhop the number of bhops you accomplished"),"\x01\x07FFFF00/style\x01 will toggle the bhop style meter in bhop duels\n\x07FFFF00/fov\x01 will allow you to change your field of view between 75-130, use with no parameter if you want to reset your fov to your tf2 settings","\x01and \x07FFFF00/spec\x01 gives you live score updates for a duel arena as such \x07FFFF00/spec m1\x01 use no parameter to clear the spectated duel"]
"commands" : [(smpref+"Commands list has been printed to console")]
}

//===================================WARNING===================================
//Plugins do not need to append to any of this, they have their own methods back up in the pluginsconf table
::CmdList <- [@"_____________________________Commands list:_____________________________
Replace m/ with "+Config["Prefix1"]+" or "+Config["Prefix2"],@"",@"m/help <arg> - sends help information in chat and lists a variety of parameters for help with specific things
",@"m/credits - displays mga-rewrite script and mga_bootcamp map credits
",@"m/mga - places the player in a random arena
",@"m/arena <arena abbreviation> - places the player in the specified arena, find available arenas by entering m/arena
	Example: 'm/arena m'
	Use m/arena with no parameter to list arenas
",@"m/r - resets the player back to the lobby area
",@"m/painsnd - toggles on/off rocket jump pain sounds, off by default
",@"m/killinfo - toggles on/off a chat log of the velocity and bhop number of you and opponent when you get a kill or die
",@"m/speedo <type> - use axis or abs to select axis velocity or absolute velocity or none/no parameter to turn off
	Supports custom display settings using any of the provided measures
	provide another argument with the abbreviations of the measures you desire.
	Available measures are A(absolute), V(vertical), H(Horizontal), x, y\n
	Example: 'm/speedo custom xyA'
",@"m/fov <num> - allows the user to change their fov between 75-130
",@"m/tick - prints the current server tick, makes fetching sourcetv demo clips easier
",@"m/training - places the player in the training mode
",@"_____________________________DUEL COMMANDS_____________________________
Currently duels allowed = "+Config["DuelsAllowed"],@"
",@"m/scoredisplay <type> - Switches between ui, text, or both for the method of duel score reporting. Use parameters ui, text, or both to choose
",@"m/duel <duel arena> <duel type> - joins the player into a specified duel arena of specific duel type. Defaults to first to 10 if no duel type is supplied
	Use m/duel with no parameter to list duel arenas
",@"m/duels - lists players waiting in duel arenas and the score of ongoing duels
",@"This command can also be used again whilst waiting for someone to join your duel in order to change the duel type without rejoining the duel arena
",@"m/spec <duel arena> - allows the user to receive score updates on the chosen duel arena, useful for the tournament.
",@"m/spec auto - automatically determines which arena the spectator camera is in and shows that duels score. Also can clear the spectated duel and disable auto by using /spec with no parameter
",@"m/style - toggles on/off the bhop style meter in bhop duels (default on)
",@"_____________________________DEBUG COMMANDS_____________________________
Currently debug = "+Config["Debug"],@"
",@"m/cshow - toggles on/off a small display that lets the player know if they are capable of critting with the market gardener
",@"m/bshow - toggles on/off a chat log for bhop number, it will print the number of successful bhops when the player fails/or loses crit
",@"m/debug <playerid> | <message> - makes bot sent text in chat, usage is m/debug playernumber | message
	Example: m/debug 8 | m/arena m
	fetch user number from status console command
",@"m/debug2 - instantly swap teams without respawn, even in team restricted gamemodes
",@"m/debug3,4 - unused now
",@"m/debug5 - prints the player lists for all custom gamemodes on server console
",@"_____________________________PRACTICE MODE COMMANDS_____________________________
Currently practice = "+Config["Jpractice"],@"
",@"m/startpos - sets start position for player to reset to
",@"m/clearpost - clears start position
",@"m/dummy <name> - spawns a dummy bot at players current position
",@"m/regen - toggles the ammo and health regen disabled by default in practice mode
",@"_____________________________ADMIN COMMANDS_____________________________
",@"m/config <setting> <value> <objtype> - changes server config temporarily
	Example: m/config BhopTickWindow 5 int
		Sets the bhoptickwindow to 5 ticks
	Use m/config with no parameter to print config options in console
",@"m/admincrazy <userid>/<me> - enables a powerplay type admin mode for the user
	Example: m/admincrazy 4
	Example: m/admincrazy me
		Admincrazy has different effects for the non standard rocket launchers, stock remains default
",@"________________________________________________________________________
"]

::help_base <- [@"_____________________________Commands list:_____________________________
Replace m/ with "+Config["Prefix1"]+" or "+Config["Prefix2"]+"\nAlso m/help commands all shows unavailable commands",@"",@"m/help <arg> - sends help information in chat and lists a variety of parameters for help with specific things
",@"m/credits - displays mga-rewrite script and mga_bootcamp map credits
",@"m/mga - places the player in a random arena
",@"m/arena <arena abbreviation> - places the player in the specified arena, find available arenas by entering m/arena
    Example: 'm/arena m'
    Use m/arena with no parameter to list arenas
",@"m/r - resets the player back to the lobby area
",@"m/painsnd - toggles on/off rocket jump pain sounds, off by default
",@"m/killinfo - toggles on/off a chat log of the velocity and bhop number of you and opponent when you get a kill or die
",@"m/speedo <type> - use axis or abs to select axis velocity or absolute velocity or none/no parameter to turn off
",@"m/fov <num> - allows the user to change their fov between 75-130
",@"m/tick - prints the current server tick, makes fetching sourcetv demo clips easier
",@"m/training - places the player in the training mode
"]

::help_duels <- [@"_____________________________DUEL COMMANDS_____________________________
Currently duels allowed = "+Config["DuelsAllowed"],@"
m/scoredisplay <type> - Switches between ui, text, or both for the method of duel score reporting. Use parameters ui, text, or both to choose
",@"m/duel <duel arena> <duel type> - joins the player into a specified duel arena of specific duel type. Defaults to first to 10 if no duel type is supplied
    Use m/duel with no parameter to list duel arenas
",@"m/duels - lists players waiting in duel arenas and the score of ongoing duels
",@"This command can also be used again whilst waiting for someone to join your duel in order to change the duel type without rejoining the duel arena
",@"m/invite <name/id> <duel arena> <duel type> - invite others to duel arenas in a variety of ways
    using m/invite with no parameters list available players and their corresponding player id
    ",@"	- while already in a duel arena you can use m/invite <name/id> to invite that player to your current arena and type
    ",@"	- while outside of a duel arena you can use m/invite <name/id> <duel arena> <duel type> to invite a player to a specific arena and type assuming that arena is empty
    ",@"	NOTE: Outbound duel invites have a 30 second expiry time, during which you won't be able to invite, change arena, change type, or return to the lobby
	",@" Example: m/duel player1 c1 dom
	",@"m/accept - accepts your currently pending duel invite request
",@"m/decline - immediately declines your currently pending duel invite request


",@"m/spec <duel arena> - allows the user to receive score updates on the chosen duel arena, useful for the tournament.
",@"m/spec auto - automatically determines which arena the spectator camera is in and shows that duels score. Also can clear the spectated duel and disable auto by using /spec with no parameter
",@"m/style - toggles on/off the bhop style meter in bhop duels (default on)
"]

::help_debug <- [@"_____________________________DEBUG COMMANDS_____________________________
Currently debug = "+Config["Debug"],@"
",@"m/cshow - toggles on/off a small display that lets the player know if they are capable of critting with the market gardener
",@"m/bshow - toggles on/off a chat log for bhop number, it will print the number of successful bhops when the player fails/or loses crit
",@"m/debug <playerid> | <message> - makes bot sent text in chat, usage is m/debug playernumber | message
    Example: m/debug 8 | m/arena m
    fetch user number from status console command
",@"m/debug2 - instantly swap teams without respawn, even in team restricted gamemodes
",@"m/debug3,4 - unused now
",@"m/debug5 - prints the player lists for all custom gamemodes on server console
"]

::help_practice <- [@"_____________________________PRACTICE MODE COMMANDS_____________________________
Currently practice = "+Config["Jpractice"],@"
",@"m/startpos - sets start position for player to reset to
",@"m/clearpos - clears start position
",@"m/dummy <name> - spawns a dummy bot at players current position
",@"m/regen - toggles the ammo and health regen disabled by default in practice mode
"]
::help_admin <- [@"_____________________________ADMIN COMMANDS_____________________________
",@"m/config <setting> <value> <objtype> - changes server config temporarily
    Example: m/config BhopTickWindow 5 int
        Sets the bhoptickwindow to 5 ticks
    Use m/config with no parameter to print config options in console",@"
	objtypes: null, int, str, arr, bool
        Use any value with null, others must convert properly
        For arr, split elements with a ,
",@"m/admincrazy <userid>/<me> - enables a powerplay type admin mode for the user
    Example: m/admincrazy 4
    Example: m/admincrazy me
        Admincrazy has different effects for the non standard rocket launchers, stock remains default
",@"________________________________________________________________________
"]
//===================================END HELP DEFINITIONS===================================




//Func for command list handling
::CmdListFunc <- function(player)
{
    for (local i = 0; i < help1["commands"].len() ; i++) {
        TextWrapSend(player, 2, ("\n"))
        for (local i = 0; i < ::help_base.len() ; i++) {
        TextWrapSend(player, 2, ::help_base[i])}
    }

    if (Config["DuelsAllowed"])
    {
        for (local i = 0; i < help1["commands"].len() ; i++) {
            TextWrapSend(player, 2, ("\n"))
            for (local i = 0; i < ::help_duels.len() ; i++) {
            TextWrapSend(player, 2, ::help_duels[i])}
        }

    }


    if (Config["Debug"])
    {
        for (local i = 0; i < help1["commands"].len() ; i++) {
            TextWrapSend(player, 2, ("\n"))
            for (local i = 0; i < ::help_debug.len() ; i++) {
            TextWrapSend(player, 2, ::help_debug[i])}
        }

    }
    if (Config["Jpractice"])
    {
        for (local i = 0; i < help1["commands"].len() ; i++) {
            TextWrapSend(player, 2, ("\n"))
            for (local i = 0; i < ::help_practice.len() ; i++) {
            TextWrapSend(player, 2, ::help_practice[i])}
        }

    }

	TextWrapSend(player, 2, ("\n\n_____________________________PLUGIN COMMANDS_____________________________\n"))
	foreach (key, value in PluginsConf["CommandsHelp"])
	{
		if (!startswith(key, "."))
		{TextWrapSend(player, 2, ("m/"+key+" "+value+"\n"))}
	}

    if (Config["Admins"].find(GetPlayerNetID(player)) != null)
    {
        for (local i = 0; i < help1["commands"].len() ; i++) {
            TextWrapSend(player, 2, ("\n"))
            for (local i = 0; i < ::help_admin.len() ; i++) {
            TextWrapSend(player, 2, ::help_admin[i])}
        }

    }
}

//Spawn some basic ents for cshow and for practice dummy handling
SpawnEntityFromTable("game_text", {
    targetname = "wipe test2"
    channel = 4
	color = "42 255 0"
	color2 = "255 255 255"
	holdtime = 0.1
	x = -1
	y = 0.8
	fxtime = 0.25
	message = ""

})

SpawnEntityFromTable("game_text", {
    targetname = "cshow test2"
    channel = 4
	color = "42 255 0"
	color2 = "255 255 255"
	holdtime = 10
	x = -1
	y = 0.8
	fxtime = 0.25
	message = "C"

})



SpawnEntityFromTable("bot_controller", {
    targetname = "DumSpawn12"
	bot_class = 3
	bot_name = "BDummy"
	TeamNum = 3
})
SpawnEntityFromTable("bot_controller", {
    targetname = "DumSpawn22"
	bot_class = 3
	bot_name = "RDummy"
	TeamNum = 2
})
SpawnEntityFromTable("bot_controller", {
    targetname = "DumSpawn32"
	bot_class = 3
	bot_name = "LobbyDummy"
	TeamNum = 3
})

::PracSpawnerB <- SpawnEntityFromTable("bot_controller", {
	targetname = "PracSpawnerB"
	bot_class = 3
	bot_name = "NullBot"
	TeamNum = 3
})

::PracSpawnerR <- SpawnEntityFromTable("bot_controller", {
	targetname = "PracSpawnerR"
	bot_class = 3
	bot_name = "NullBot"
	TeamNum = 2
})




//Func for getting player steamids for admin checking
::GetPlayerNetID <- function(player)
{
    return NetProps.GetPropString(player, "m_szNetworkIDString")

}

//TEXT display queue info

//Define class to be cloned
class InputDisplays {
	function InputDisplay()
	{
		// if > 1 value in queue delete first (should only ever be 2 max before deleting 1)
		if (queue.len() > 1) {queue.remove(0)}

		//Set as text, display after

			local test_relay = SpawnEntityFromTable("logic_relay",
			{
				targetname = queue[0]
			});
			NetProps.SetPropBool(test_relay, "m_bForcePurgeFixedupStrings", true)
		self.KeyValueFromString("message", test_relay.GetName());
		test_relay.Destroy()
		return true;
	}
}

//Show any text generic function
::ShowAnyText <- function(player, text, ent, color = null)
{
	if (!"queue" in ent.GetScriptScope())
	{ent.GetScriptScope().queue <- [];}
	local queue = ent.GetScriptScope().queue
	if (queue.len() > 0)
	{
		if (text != queue[0] && text != null)
		{
			queue.append(text);
		}

	}
	else {
		if (text == null) {text = ""}
			queue.append(text);
	}

	if (color != null)
	{
	local color_relay = SpawnEntityFromTable("logic_relay",
	{
			targetname = color
	});
	NetProps.SetPropBool(color_relay, "m_bForcePurgeFixedupStrings", true)
	ent.KeyValueFromString("color", color_relay.GetName());
	color_relay.Destroy()
	}


	ent.AcceptInput("Display", null, player, null)
}
//Define many text entities and their needed queues
if ("text_ent" in getroottable() && text_ent.IsValid())
    text_ent.Destroy();

::text_ent <- SpawnEntityFromTable("game_text",
{
    x = 0.1,
    y = 0.1,
    color = "255 255 255",
    holdtime = 11,
    channel = 2
});
::text_ent.ValidateScriptScope();
::text_ent_scope <- ::text_ent.GetScriptScope();
::text_ent_scope.queue <- [];
local text_ent_display = InputDisplays;
::text_ent_scope.InputDisplay <- text_ent_display.InputDisplay;
::text_ent_scope.inputdisplay <- text_ent_display.InputDisplay;



if ("speedo_ent" in getroottable() && speedo_ent.IsValid())
    speedo_ent.Destroy();

::speedo_ent <- SpawnEntityFromTable("game_text",
{
    x = 0.4,
    y = 0.7,
    color = "255 255 255",
    holdtime = 10,
    channel = 3
});
::speedo_ent.ValidateScriptScope();
::speedo_ent_scope <- ::speedo_ent.GetScriptScope();
::speedo_ent_scope.queue <- [];
local speedo_ent_display = InputDisplays();
::speedo_ent_scope.InputDisplay <- speedo_ent_display.InputDisplay;
::speedo_ent_scope.inputdisplay <- speedo_ent_display.InputDisplay;


::score_ent <- SpawnEntityFromTable("game_text",
{
    channel = 1
	color = "255 255 255"
	holdtime = 10
	x = 0.1
	y = 0.6
});
::score_ent.ValidateScriptScope();
::score_ent_scope <- ::score_ent.GetScriptScope();
::score_ent_scope.queue <- [];
local score_ent_display = InputDisplays();
::score_ent_scope.InputDisplay <- score_ent_display.InputDisplay;
::score_ent_scope.inputdisplay <- score_ent_display.InputDisplay;

//END TEXT ENT DEFINING


//Function for checking if players are on the ground
::CTFPlayer.IsOnGround <- function()
{
    return this.GetFlags() & Constants.FPlayer.FL_ONGROUND;
}



//Class change function
function ForceChangeClassMGA(player)
{
	if (!PluginsConf["ClassRestrict"] || player.GetPlayerClass() == PluginsConf["ClassRestrict"]) {return}
	local classIndex = PluginsConf["ClassRestrict"]
	player.SetPlayerClass(classIndex);
	NetProps.SetPropInt(player, "m_Shared.m_iDesiredPlayerClass", classIndex);
	player.ForceRegenerateAndRespawn();
}



//Weapon update function
::UpdateWeapons <- function(player)
{

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(PluginsConf["PreFuncs"]["UpdateWeapons"]);
	//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript()



	//Avoid updating those on the wrong class
	if (PluginsConf["ClassRestrict"] != false && player.GetPlayerClass() != PluginsConf["ClassRestrict"])
		return;
	// Define health before changes
	local health = null
	if (Config["Jpractice"] && player.IsFakeClient() == false) {health = player.GetHealth()}
	// get primary weapon first (assuming it's always index 0...)
	local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
	try {
	if (weapon && weapon.Clip1)
	{
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

		// save the old clip so we don't overwrite whatever the beggars has in it right now
		local oldClip = weapon.Clip1();
		//Only resupply if pluginsconf says so **deprecated** and if new method ways resupply
		if (PluginsConf["MgaAmmoResupply"] && player.GetScriptScope().resupply)
		{player.Regenerate(true);}

		// no spread for beggars
		if (weaponIndex == 730)
		{
			weapon.SetClip1(oldClip);
			weapon.AddAttribute("projectile spread angle penalty", 0, -1);
		}
		else if (weaponIndex == 441)
		{
			weapon.AddAttribute("energy weapon charged shot", 0, -1);
			weapon.RemoveAttribute("energy weapon charged shot");
		}
		// make liberty launcher, direct hit, and NOTairstrike like stock
		else if (weaponIndex == 127 || weaponIndex == 414)// || weaponIndex == 1104)
		{
			weapon.AddAttribute("Blast radius decreased" 1, -1);
			weapon.AddAttribute("Projectile speed increased" 1, -1);
			weapon.AddAttribute("damage bonus" 1, -1);
			weapon.AddAttribute("damage penalty" 1, -1);
			weapon.AddAttribute("rocketjump attackrate bonus" 1, -1);
			weapon.AddAttribute("mod mini-crit airborne" 0, -1);
		}
		else if (weaponIndex == 237)
			{
				weapon.AddAttribute("no self blast dmg" 0, -1)
				weapon.AddAttribute("rocket jump damage reduction" 0, -1)
		}
		else if (weaponIndex == 1104 && player.GetScriptScope().canCrit == true && player.GetScriptScope().crazy == false)
		{
			weapon.SetClip1(oldClip);
		}
	//Admincrazy command goofs
	if (player.GetScriptScope().crazy == true) {
		if (weaponIndex == 730)
		{
			weapon.SetClip1(oldClip);
			weapon.AddAttribute("projectile spread angle penalty", 0, -1);
			weapon.AddAttribute("clip size bonus", 3.33, -1);
			weapon.AddAttribute("fire rate bonus", 0.5, -1);
			weapon.AddAttribute("Reload time decreased", 0.3, -1);
			weapon.AddAttribute("move speed bonus", 3, -1);
		}
		else if (weaponIndex == 441)
		{
			weapon.AddAttribute("Blast radius increased", 4, -1);
			weapon.AddAttribute("move speed bonus", 3, -1);
			weapon.AddAttribute("deploy time decreased", 0.1, -1);
			weapon.AddAttribute("gesture speed increase", 2, -1);
			weapon.AddAttribute("Set DamageType Ignite", 1, -1);
			weapon.AddAttribute("fire rate penalty", 3, -1);
			weapon.AddAttribute("self dmg push force increased", 3, -1);
			weapon.AddAttribute("weapon burn dmg reduced", 0, -1);
			weapon.AddAttribute("increased jump height", 2, -1);
		}
		// make liberty launcher, direct hit, and airstrike like stock
		else if (weaponIndex == 127 || weaponIndex == 414 || weaponIndex == 1104)
		{
			weapon.AddAttribute("Projectile speed increased" 0.75, -1);
			weapon.AddAttribute("damage bonus" 1, -1);
			weapon.AddAttribute("damage penalty" 1, -1);
			weapon.AddAttribute("rocketjump attackrate bonus" 0.1, -1);
			weapon.AddAttribute("mod mini-crit airborne" 0, -1);
		}
		else if (weaponIndex == 237)
			{
				// printl("test")
				weapon.AddAttribute("no self blast dmg" 0, -1)
				weapon.AddAttribute("rocket jump damage reduction" 0, -1)
				weapon.AddAttribute("damage bonus" 10, -1)
				weapon.AddAttribute("Blast radius decreased" 0.1, -1)
				weapon.AddAttribute("damage penalty" 1, -1)
				weapon.AddAttribute("Projectile speed increased" 0.3, -1);
		}


	}
	//Juggernaut modifications
	if (player.GetScriptScope().jugg == true) {
		// no spread for beggars
		if (weaponIndex == 730)
		{
			weapon.SetClip1(oldClip);
			weapon.AddAttribute("projectile spread angle penalty", 0, -1);
		}
		else if (weaponIndex == 441)
		{
			weapon.AddAttribute("energy weapon charged shot", 0, -1);
			weapon.RemoveAttribute("energy weapon charged shot");
		}
		// make liberty launcher, direct hit, and NOTairstrike like stock
		else if (weaponIndex == 127 || weaponIndex == 414)// || weaponIndex == 1104)
		{
			weapon.AddAttribute("Blast radius decreased" 1, -1);
			weapon.AddAttribute("Projectile speed increased" 1, -1);
			weapon.AddAttribute("damage bonus" 1, -1);
			weapon.AddAttribute("damage penalty" 1, -1);
			weapon.AddAttribute("rocketjump attackrate bonus" 1, -1);
			weapon.AddAttribute("mod mini-crit airborne" 0, -1);
		}
		else if (weaponIndex == 237)
			{
				// printl("test")
				weapon.AddAttribute("no self blast dmg" 0, -1)
				weapon.AddAttribute("rocket jump damage reduction" 0, -1)
		}

		if (weaponIndex == 18 ||
		weaponIndex == 205 ||
		weaponIndex == 127 ||
		weaponIndex == 228 ||
		weaponIndex == 237 ||
		weaponIndex == 414 ||
		weaponIndex == 441 ||
		weaponIndex == 513 ||
		weaponIndex == 730
		) {
			weapon.AddAttribute("fire rate bonus", 0.5, -1);
			weapon.AddAttribute("Reload time decreased", 0.7, -1);
		}
		if (weaponIndex == 1104) {
			weapon.AddAttribute("Reload time decreased", 0.5, -1);
		}


	}

	//practice mode ammo reset
	if ((Config["Jpractice"] && player.GetScriptScope().practiceheal == false) && player.IsFakeClient() == false) {weapon.SetClip1(oldClip);}

	}

	//Remove banned items
	for (local i = 1; i < 7; i++)
	{
		local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i);
		if (!weapon)
			continue;
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

		// get rid of banners
		if (weaponIndex == 226	|| // battalions backup
			weaponIndex == 129	|| // buff banner
			weaponIndex == 1001 || // festive buff banner
			weaponIndex == 354	|| // conch
			weaponIndex == 1101)   // base jumper
		{
			// do NOT use .Kill(), since the entity will actually remain and progressively slow down the serverz
			weapon.Destroy();
			continue;
		}

		if (weapon.IsMeleeWeapon())
		{

//TEMP
			// this kicks off melee smack detection logic
			if (NetProps.GetPropString(weapon, "m_iszScriptThinkFunction") != "CheckMeleeSmack")
			{
				NetProps.SetPropInt(player, "m_Shared.m_iNextMeleeCrit", -2)
				AddThinkToEnt(weapon, "CheckMeleeSmack")
				// printl("add think")
			}



			// if (weaponIndex != 357) // katana
			// {
				weapon.AddAttribute("mod crit while airborne", 0, -1);
				weapon.AddAttribute("fire rate penalty", 1.2, -1);
			// }
			if (weaponIndex == 357) {
				weapon.AddAttribute("is_a_sword", 0, -1)
				weapon.AddAttribute("honorbound", 0, -1)
				weapon.AddAttribute("restore_health_on_kill", 0, -1)
			}
			if (weaponIndex == 447) // disciplinary action
			{
				weapon.AddAttribute("melee range multiplier", 1, -1);
				weapon.AddAttribute("melee bounds multiplier", 1, -1);
				weapon.AddAttribute("speed buff ally", 0, -1);
				weapon.AddAttribute("damage penalty", 1, -1);
			}
			else if (weaponIndex == 775) // escape plan
			{
				weapon.AddAttribute("self mark for death", 0, -1);
			}
			if (player.GetScriptScope().crazy == true) {
				weapon.AddAttribute("turn to gold",1,-1);
			}

			continue;
		}
	}
	//Practice health reset
	if (Config["Jpractice"] && player.IsFakeClient() == false) {player.SetHealth(health)}
} catch(exception) {return;}



local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["UpdateWeapons"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

}

//Jumppad script for enabling crit with triggers
::jumppad <- function(params) {
	local self = activator
	if (self.GetScriptScope().canCrit == false)
	{
		// local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0);
		// if (weapon)
		// {
		// 	local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
		// 	if (weaponIndex == 237) {
		// 		EmitSoundEx({
		// 		sound_name = "BlastJump.Whistle",
		// 		flags = 0,
		// 		volume = 0.8,
		// 		channel = 0,
		// 		entity = self,
		// 		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
		// 		});
		// 	}
		// }
	self.GetScriptScope().canCrit <- true
	}


}

::PlayerStuckPrevent <- function(player)
{
			for (local found; found = Entities.FindByClassnameWithin(found, "player", player.GetOrigin(), 100);)
			{
				//if not invis, and teammate nearby, unfreeze
				if (player.GetCondDuration(Constants.ETFCond.TF_COND_STEALTHED_USER_BUFF) == 0 && found.GetTeam() == player.GetTeam() && found != player && found.GetCondDuration(Constants.ETFCond.TF_COND_HALLOWEEN_THRILLER) == 0) {
				player.RemoveCondEx(Constants.ETFCond.TF_COND_HALLOWEEN_THRILLER, true)
				player.RemoveCondEx(Constants.ETFCond.TF_COND_INVULNERABLE, true)
				player.RemoveCondEx(Constants.ETFCond.TF_COND_MEGAHEAL, true)
				return}

				//set nearby opponents to debris collision + self
				if (found.GetTeam() != player.GetTeam() && found && found != player)
				{

					if (player.GetCollisionGroup() != 2)
					{player.SetCollisionGroup(2)}
					if (found.GetCollisionGroup() != 2)
					{found.SetCollisionGroup(2)}
				}
				continue
			}
}




//===================================DEPRECATED===================================
//use vpush2
::vpush <- function(speed) {
	if (activator.GetCondDuration(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF) != 0) {
		return
	}


	local avel = activator.GetAbsVelocity()
	local pvel = NetProps.GetPropVector(caller, "m_vecPushDir")

	activator.SetAbsVelocity(Vector((2*speed*pvel.x + avel.x),(2*speed*pvel.y + avel.y),(2*speed*pvel.z + avel.z)))
}
//===================================DEPRECATED===================================
//use vpush2



// Converts angles to a vector direction
::AnglesToVector <- function(angles)
{
    local pitch = angles.x * Constants.Math.Pi / 180.0
    local yaw = angles.y * Constants.Math.Pi / 180.0
    local x = cos(pitch) * cos(yaw)
    local y = cos(pitch) * sin(yaw)
    local z = sin(pitch)
    return Vector(x, y, z)
}

//Function for spawn push triggers, avoid pushing spawn invul users so no double launches
::vpush2 <- function(speed, x, y, z) {
	if (activator.GetCondDuration(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF) != 0) {
		return
	}
	local avel = activator.GetAbsVelocity()
	activator.ApplyAbsVelocityImpulse(AnglesToVector(QAngle(x,y,z))*speed*0.015)
}



if (::InitialiseNeeded == false)
{
local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	// Cleanup events on round restart. Do not remove this event.
	OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	////////// Add your events here //////////////
	// Example: "post_inventory_application" is triggered when a player receives a new set of loadout items, such as when they touch a resupply locker/respawn cabinet, respawn or spawn in.

	OnGameEvent_teamplay_round_start = function(params)
	{
		//Set convars
			Convars.SetValue("mp_waitingforplayers_cancel", 1)
			Convars.SetValue("mp_teams_unbalance_limit", 0)
			Convars.SetValue("tf_weapon_criticals", 0)
			Convars.SetValue("tf_avoidteammates_pushaway", 0)
			local lobbyspawn = Config["LobbyBot"]

		//Set if lobby bot should spawn
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i)
			if (player == null) continue
			if (player.IsFakeClient() == true){
					if ((NetProps.GetPropString(player, "m_szNetname") == "LobbyDummy")) {
						lobbyspawn = false
						break
					}
				}
		}
			if (lobbyspawn == true) {botspawn(3, null)}
		//SPEC VOLUMES DEFINING
		::SpecVolumes <- {};
		local voltest = null
		while(voltest = Entities.FindByName(voltest, "specvol_*")) {
		local max = (voltest.GetOrigin() + voltest.GetBoundingMaxs())
		local min = (voltest.GetOrigin() - voltest.GetBoundingMaxs())
		local volname = (split(voltest.GetName(), "_")[1])
		SpecVolumes.rawset(volname, [min,max])
		}
	}

	//On rocket jump managing, don't use for much because of better methods
	OnGameEvent_rocket_jump = function(params)
	{
			local player = GetPlayerFromUserID(params.userid);
			local vel = player.GetAbsVelocity();
			if (!player.GetScriptScope().inMga)
				return;
			player.GetScriptScope().jtime <- NetProps.GetPropInt(player, "m_nSimulationTick")
			return
	}


	//On rocket landing managing, don't use for much because of better methods
	OnGameEvent_rocket_jump_landed = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		local vel = player.GetAbsVelocity();
		if (vel.z != 0 && player.GetScriptScope().lastGround == 0) {
			player.GetScriptScope().landed <- false;
			player.GetScriptScope().jtime <- NetProps.GetPropInt(player, "m_nSimulationTick")
			player.GetScriptScope().canCrit <- true;
		}
		return
	}


	//Player spawn managing
	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		local needed = false
		//Check if needing scope defining
		if (!("arena" in player.GetScriptScope()) || !("inMga" in player.GetScriptScope()))
		{
			needed = true
		}

		if (player == null)
			{return;}

		//If new join or need scope, define a LOT of scope variables
		if (player.GetTeam() == 0 || needed == true)
		{
			player.ValidateScriptScope();

			player.GetScriptScope().resupply <- true

			player.GetScriptScope().inMga <- true;
			player.GetScriptScope().arena <- ["L","lobby"];
			player.GetScriptScope().waiting <- false
			player.GetScriptScope().waitingon <- false
			player.GetScriptScope().tspawn <- 0
			player.GetScriptScope().training <- 0
			player.GetScriptScope().cshow <- false
			player.GetScriptScope().buttons_last <- 0;
			player.GetScriptScope().jtime <- NetProps.GetPropInt(player, "m_nSimulationTick")
			player.GetScriptScope().lastCshow <- 0
			player.GetScriptScope().lastDshown <- 0
			player.GetScriptScope().lastCrit <- false
			player.GetScriptScope().lastGround <- 1
			player.GetScriptScope().hopnum <- 0
			player.GetScriptScope().dtype <- null
			player.GetScriptScope().lvel <- null
			player.GetScriptScope().bshow <- false
			player.GetScriptScope().killinfo <- false
			player.GetScriptScope().speedo <- 0
			player.GetScriptScope().customspeedo <- ""
			player.GetScriptScope().painsnd <- true
			player.GetScriptScope().canCrit <- false
			player.GetScriptScope().bhopped <- false

			player.GetScriptScope().style <- true

			player.GetScriptScope().landed <- false


			player.GetScriptScope().crazy <- false
			player.GetScriptScope().jugg <- false
			player.GetScriptScope().juggforce <- false
			player.GetScriptScope().juggkills <- 0

			player.GetScriptScope().respawninfo <- {
				"pos" : null
				"eye" : null
				"vel" : null
				"swap" : false
				"crit" : null
			}
			player.GetScriptScope().teamlock <- 0

			player.GetScriptScope().practicepos <- {
				"pos" : null
				"eye" : null
			}
			player.GetScriptScope().practiceheal <- false

            player.GetScriptScope().invite <- [null, null]
            player.GetScriptScope().invited <- false


			player.GetScriptScope().fovcmd <- (Convars.GetClientConvarValue("fov_desired", player.entindex()));

			player.GetScriptScope().hidteam <- (Convars.GetClientConvarValue("cl_team", player.entindex()).tostring());
			if (!("welcomed" in player.GetScriptScope()))
			{
			TextWrapSend(player,3,connectmsg)

			if (Config["Jpractice"]) {
				TextWrapSend(player, 3, (smpref+"This server is currently set to \x0700FF00jump practice mode\x01. \x07FF0000Ammo & Hp regen is disabled\x01, you cannot die and will be notified when you should have died normally. Use \x07FFFF00"+Config["Prefix1"]+"startpos\x01 to set a beginning position, then swing your market gardener to reset there and redo your jump. \x07FFFF00"+Config["Prefix1"]+"clearpos\x01 deletes this spawn position and allows you to regen hp & ammo anywhere with a melee swing"))
			}

			player.GetScriptScope().welcomed <- true
			}


				player.GetScriptScope().specduel <- null
				player.GetScriptScope().specduelauto <- true
				player.GetScriptScope().scoredisplay <- 1

			try {
				if (player.GetScriptScope().bhopinit == true) {
					if(::BhopUi){RemoveBhopUi(player)}
				player.GetScriptScope().bhopinit <- false
				player.GetScriptScope().dtype <- "ft10"
			}
			} catch(exception);



		}

		player.GetScriptScope().canCrit <- false

		//Reset things, then add spawn invul and think
		player.GetScriptScope().lastLandTime <- 0;
		player.GetScriptScope().lastVel <- Vector();
		player.AddCondEx(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF, 1.0, null);
		AddThinkToEnt(player, "PlayerThink");


		//Check team then custom game logic and dummy logic
		local team = player.GetTeam();
		local named = false
		if (team == Constants.ETFTeam.TF_TEAM_RED ||
			team == Constants.ETFTeam.TF_TEAM_BLUE)
		{
			EntFireByHandle(player, "CallScriptFunction", "CustomGameSpawn", 0, null, null);
			//TEST DUMMY HANDLING
			if (player.IsFakeClient() == true){
				player.GetScriptScope().inMga <- true;
				if ((NetProps.GetPropString(player, "m_szNetname") == "BDummy") || (NetProps.GetPropString(player, "m_szNetname") == "RDummy"))
				{
				local slot = player.GetScriptScope().tspawn;
				if (team == Constants.ETFTeam.TF_TEAM_BLUE) {
					local spawn = TSpawntab["bot"][0]
					player.Teleport(true, spawn[slot].GetOrigin(),
					true, spawn[slot].GetAbsAngles()
					true, Vector());}
				if (team == Constants.ETFTeam.TF_TEAM_RED) {
					local spawn = TSpawntab["bot"][1]
					player.Teleport(true, spawn[slot].GetOrigin(),
					true, spawn[slot].GetAbsAngles()
					true, Vector());}
				named = true
				}
				if (NetProps.GetPropString(player, "m_szNetname") == "LobbyDummy")
				{
				player.GetScriptScope().arena <- ["L","bspawn"]
				local slot = rand();
				local spawnval = SpawnTypes[player.GetScriptScope().arena[0]][player.GetScriptScope().arena[1]][-player.GetTeam() + 3]
				// printl(SpawnTypes[player.GetScriptScope().arena[0]][player.GetScriptScope().arena[1]][0][0])
				slot = slot % spawnval.len();
				player.Teleport(true, spawnval[slot].GetOrigin(),
					true, spawnval[slot].GetAbsAngles()
					true, Vector());
				named = true
				}

				if (startswith(NetProps.GetPropString(player, "m_szNetname"), "Practice"))
				{
					local num = split(NetProps.GetPropString(player, "m_szNetname"), "_")
					EntFireByHandle(player, "CallScriptFunction", "PostBotSpawn", 0, null, null);
					player.Teleport(true, ::PracticeBotPos[num[1]][0],
						true, QAngle()
						true, Vector());


					if (::PracticeBotPos[num[1]].len() < 2)
					{::PracticeBotPos[num[1]].append(player)}
					named = true
				}

				if (named) {
				EntFireByHandle(player, "CallScriptFunction", "PostBotSpawn", 0, null, null);
				}
				else {
				ForceChangeClassMGA(player);//, Constants.ETFClass.TF_CLASS_SOLDIER);
				local slot = rand();
				local teamabb = null
				try {
				local spawnval = SpawnTypes[player.GetScriptScope().arena[0]][player.GetScriptScope().arena[1]][-player.GetTeam() + 3]
				// printl("bottele")
				slot = slot % spawnval.len();
				player.Teleport(true, spawnval[slot].GetOrigin(),
					true, spawnval[slot].GetAbsAngles()
					true, Vector());
				} catch(exception);
				}
			return}


		//Remove bhopui if not in a bhop duel
		if (player.GetScriptScope().dtype == "bhop" && (player.GetScriptScope().arena[0] == "A" || player.GetScriptScope().arena[0] == "T")) {
			try {
				if (player.GetScriptScope().bhopinit == true) {
					if(::BhopUi){RemoveBhopUi(player)}
				player.GetScriptScope().bhopinit <- false
				// printl("dtype reset")
				player.GetScriptScope().dtype <- "ft10"
			}
			} catch(exception);
		}

			if (player.GetScriptScope().inMga)
			{
				//Leave training if wrong team
				if (player.GetTeam()-1 != player.GetScriptScope().training) {
					if (player.GetScriptScope().training != 0 ) {
					player.GetScriptScope().training <- 0
					player.GetScriptScope().arena <- ["L","lobby"];
					player.GetScriptScope().inMga <- true;}
				}




				ForceChangeClassMGA(player);
				local slot = rand();
				local teamabb = null
				try {
				local spawnval = SpawnTypes[player.GetScriptScope().arena[0]][player.GetScriptScope().arena[1]][-player.GetTeam() + 3]
				slot = slot % spawnval.len();
				player.Teleport(true, spawnval[slot].GetOrigin(),
					true, spawnval[slot].GetAbsAngles()
					true, Vector());
				} catch(exception);


				//Restore crit if needed in custom gamemodes
				if (player.GetScriptScope().respawninfo["crit"]) {
				player.GetScriptScope().canCrit <- true
				player.GetScriptScope().bhopped <- true
				player.GetScriptScope().jtime <- 0
				player.GetScriptScope().landed <- false
				player.GetScriptScope().respawninfo["crit"] <- false
				player.GetScriptScope().lastCshow <- 0
				}

				//Call score checks for duels
				EntFireByHandle(player, "CallScriptFunction", "PostdScoreCheck", 1, null, null);

				//Set custom fov
				if (player.GetScriptScope().fovcmd != (Convars.GetClientConvarValue("fov_desired", player.entindex()))) {
					NetProps.SetPropInt(player, "m_iFOV", (player.GetScriptScope().fovcmd))
					NetProps.SetPropInt(player, "m_iDefaultFov", (player.GetScriptScope().fovcmd))
				}




							//Handle bshow text and bhopui
							if (player.GetScriptScope().bshow == true && player.GetScriptScope().dtype != "bhop" && player.GetScriptScope().hopnum > 0) {
								TextWrapSend(player, 3, ("\x01hop# \x07FF0000was\x01 = \x0700FF00"+player.GetScriptScope().hopnum))
							}
						if (player.GetScriptScope().dtype == "bhop" && player.GetScriptScope().hopnum > 0) {
							TextWrapSend(player, 3, ("\x01hop# \x07FF0000reset"))
							try {
								if (player.GetScriptScope().bhopinit == true && player.GetScriptScope().style == true) {
									if(::BhopUi){UpdateBhopUi(player, 0)}
								}
							} catch(exception) {return}
							}
							player.GetScriptScope().hopnum = (0)
						// }



			}
			else
			{
				//force class change
				ForceChangeClassMGA(player);
			}
		}
		return
	}

	OnGameEvent_player_death = function(params)
	{
		//define local vars
		local deadp = GetPlayerFromUserID(params.userid);
		local killp = GetPlayerFromUserID(params.attacker);
		if (killp != null) {
			if (deadp != killp) {

				//Run death management functions
				CustomGameDeath(deadp, killp)

				DummyDeathCheck(deadp)

				KillInfoSend(deadp, killp)

				DuelDeath(killp, deadp)

			}
			else {
				CustomGameSuicide(deadp)
			}
			//Run instant respawn for duels
			DuelInstSpawn(killp)
		}
	//Run instant respawn
	MgaInstSpawn(deadp)
	return
	}


	OnGameEvent_player_team = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		local parteam = params.team
		if (player == null) {return;}

		//Manage team switch and team locks
		CustomGameTeamSwitch(player, parteam)

		TeamLockManage(player, parteam, params)
	}

	OnGameEvent_player_disconnect = function(params)
	{
		//Manage disconnecting from gamemodes
		try {
		local player = GetPlayerFromUserID(params.userid);
		if (player == null) {return;}
		CustomGameDisconnect(player)
		} catch(exception){return}
	}

	OnGameEvent_player_say = function(params)
	{

		local player = GetPlayerFromUserID(params.userid);

		if (player == null) {return;}

		local wasMga = player.GetScriptScope().inMga;
		local args = null
		local validcmd = 0

		//Check if using command
		if (startswith(params.text, Config["Prefix1"]) || startswith(params.text, Config["Prefix2"]))
		{


			//Split up command and command arguments
			local new = null
			if (startswith(params.text, Config["Prefix1"])) {
				new = params.text.slice(Config["Prefix1"].len())
			}
			else {
				new = params.text.slice(Config["Prefix2"].len())
			}
			if (new.len() > 0)
				{new = split(new," ")[0]}

			args = split(params.text.tostring(), " ")


		//Big switch of all commands
		switch (new) {
		case "help":
		{
			if (args.len() == 1) {
				for (local i = 0; i < help1["null"].len() ; i++) {
				TextWrapSend(player, 3, (help1["null"])[i])
				}
			}
			else {
                if (args.len() == 3) {
                if (args[1] == "commands" && args[2] == "all") {
					for (local i = 0; i < help1["commands"].len() ; i++) {
						TextWrapSend(player, 3, (help1["commands"])[i])
						for (local i = 0; i < ::CmdList.len() ; i++) {
						TextWrapSend(player, 2, ::CmdList[i])}
					}
                }}
				if (args[1] == "changes" || args[1] =="arenas" || args[1] =="duelsystem" || args[1] =="duelarenas" || args[1] =="dueltypes" || args[1] =="training"/* || args[1] == "misc"*/) {
					if (args.len() == 2) {
						for (local i = 0; i < help1[args[1]].len() ; i++) {
							TextWrapSend(player, 3, (help1[args[1]])[i])
						}
					}
				}
				else if (args[1] == "commands"){
                    if (args.len() != 3 || args[2] != "all") {
						TextWrapSend(player, 3, (help1["commands"])[0])
                    ::CmdListFunc(player)}
				}
			}
		break
		}

		case "credits":
		{
			TextWrapSend(player,3, ("\x0763e3fdMga-Rewrite script\x01 and \x07fdcb63Bootcamp map project \x07FFFF00credits\x01:\n    Mellow \x07ffd1d1(STEAM_0:1:149186271)\x01 - created script and mga_bootcamp map both released at https://github.com/Mellow1238/MGA-rewrite-bootcamp\n        Script basis by Lumia\n"))
			TextWrapSend(player,3, ("	Qiuki \x07ffd1d1(STEAM_0:0:206706736)\x01 - project manager and tournament organiser."))
			TextWrapSend(player,3, ("\n\nPlaytesters: Apple, Clubbanger3000, Delusional, fiwwuil, gryften, Hell Master, jarant, jestie, k41sr, Kidofcubes, Lecter, Mission, mixyad3, Neuki, Phee, pvs, s_seal, SpookyMonster, Teach, YeaNah"))
			TextWrapSend(player,3, ("\n\nServer invite: discord.gg/PgXbqcwTcx"))
		break
		}


		case "fov":
		{


			if (args.len() > 1) {
				try {
					args[1].tointeger()
				} catch(exception) {
					TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid fov parameter, use a number between 75-130"))
					return
				}


				local fovdes = args[1].tointeger()
				if (fovdes >= 75 && fovdes <= 130) {
					NetProps.SetPropInt(player, "m_iFOV", (fovdes));
					NetProps.SetPropInt(player, "m_iDefaultFov", (fovdes))
					player.GetScriptScope().fovcmd <- fovdes;
				}
				else {
					if (fovdes < 75) {
						TextWrapSend(player, 3, (smpref+"\x07940012"+"minimum fov is 75, defaulting to 75"))
						NetProps.SetPropInt(player, "m_iFOV", (75));
						NetProps.SetPropInt(player, "m_iDefaultFov", (75))
						player.GetScriptScope().fovcmd <- 75
					}
					else {
						TextWrapSend(player, 3, (smpref+"\x07940012"+"maximum fov is 130, defaulting to 130"))
						NetProps.SetPropInt(player, "m_iFOV", (130));
						NetProps.SetPropInt(player, "m_iDefaultFov", (130))
						player.GetScriptScope().fovcmd <- 130
					}

				}
			}
			else {
				TextWrapSend(player, 3, (smpref+"resetting fov to default"))
				NetProps.SetPropInt(player, "m_iFOV", (Convars.GetClientConvarValue("fov_desired", player.entindex())).tointeger());
				NetProps.SetPropInt(player, "m_iDefaultFov", (Convars.GetClientConvarValue("fov_desired", player.entindex())).tointeger());
				player.GetScriptScope().fovcmd <- (Convars.GetClientConvarValue("fov_desired", player.entindex()))
			}

			if (player.GetScriptScope().dtype == "bhop") {
				if(::BhopUi){ShiftBhopUi(player, player.GetScriptScope().fovcmd.tointeger())}
				TextWrapSend(player, 3, (smpref+"\x07940012"+"bhopstyle ui reset"))
			}
		break
		}

		case "tick":
		{
			TextWrapSend(player, 3, ("tick: "+NetProps.GetPropInt(player, "m_nSimulationTick")));
			break
		}

		case "speedo":
		{
				if (args.len() > 1)
				{
					switch (args[1])
					{
					case "custom":
					{
						if (args.len() >= 3)
						{
							local pref = args[2]
							if (args[2].len() >= 10) {
								pref = pref.slice(0,10)
							}
							TextWrapSend(player, 3, (smpref+"speedo set to custom \x0700FF00"+ pref))
							player.GetScriptScope().speedo <- 2
							player.GetScriptScope().customspeedo <- pref
						}
						else
						{
							TextWrapSend(player, 3, (smpref + "\x07940012" + "when using custom, provide another argument with the abbreviations of the measures you desire.\n Available measures are A(absolute), V(vertical), H(Horizontal), x, y\n E.g m/speedo custom xyA"))
						}
						break
					}
					case "abs":
						TextWrapSend(player, 3, (smpref+"speedo set to \x0700FF00absolute"))
						player.GetScriptScope().speedo <- 1
						break
					case "axis":
						TextWrapSend(player, 3, (smpref+"speedo set to \x0700FF00axis"))
						player.GetScriptScope().speedo <- -1

						break
					case "none":
						TextWrapSend(player, 3, (smpref+"speedo set to \x07FF0000none"))
						player.GetScriptScope().speedo <- 0
						// ShowTextSpeedo(player, "")
						ShowAnyText(player,"",speedo_ent)
						ShowAnyText(player, null, score_ent)
						ShowAnyText(player, null, text_ent)
						break
					default:
						TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid parameter use abs (absolute), axis, custom, or none"))
						break
					}
				}
				else {
					TextWrapSend(player, 3, (smpref+"speedo set to \x07FF0000none"))
					TextWrapSend(player, 3, ("Parameters \x07FFFF00abs (absolute), axis, custom, or none\x01 can be used if another mode is desired"))
					player.GetScriptScope().speedo <- 0
				}
		break
		}


		case "painsnd":
		{
			if (player.GetScriptScope().painsnd == false) {
				player.GetScriptScope().painsnd = true
				TextWrapSend(player, 3, (smpref+"Pain sounds \x07FF0000disabled"))
			}
			else {
				player.GetScriptScope().painsnd = false
				TextWrapSend(player, 3, (smpref+"Pain sounds \x0700FF00enabled"))
			}
		break
		}

		case "killinfo":
		{
			if (player.GetScriptScope().killinfo == false) {
				player.GetScriptScope().killinfo = true
				TextWrapSend(player, 3, (smpref+"Kill info \x0700FF00enabled"))
			}
			else {
				player.GetScriptScope().killinfo = false
				TextWrapSend(player, 3, (smpref+"Kill info \x07FF0000disabled"))
			}
		break
		}



		case "arena":
		{

			if (player.GetScriptScope().waiting == false && player.GetScriptScope().waitingon == false && player.GetScriptScope().invited == false) {
			local aNum = 1
			if (args.len() > 1) {
				if (AvailableA.find(args[1]) == null || args[1].slice(0,1) == (".")) {
					TextWrapSend(player, 3, (smpref+"\x07940012"+"Invalid arena, use "+ListConv(AvailableA, false, false)))
					return
				}
				if (player.GetScriptScope().arena[1] == args[1]) {return}
				else {

		if (CustomsList["all"].find(player.GetScriptScope().arena[1]) != null) {


		local list = null
		foreach(key, value in CustomsList) {
			if (key == "all") {continue}
			if (value.find(player.GetScriptScope().arena[1]) != null) {
				list = CustomListMatchip[key]
			}
		}

		if (list[player.GetTeam().tostring()].find(player) != null) {
			list[player.GetTeam().tostring()].remove(list[player.GetTeam().tostring()].find(player))}

				}
				player.GetScriptScope().inMga <- true;
				player.GetScriptScope().arena = ["A",args[1]]
				player.GetScriptScope().teamlock <- 0


				player.ForceRegenerateAndRespawn();
				player.GetScriptScope().score <- 0
				}
			}

			else {
				TextWrapSend(player, 3, (smpref+"This map includes arenas: "+ListConv(AvailableA, false, false)))
				return
			}
		}
		else {TextWrapSend(player, 3, (smpref+"\x07940012"+"already waiting for a duel to begin"))}
		break
		}

		case "mga":
		{
			if (player.GetScriptScope().waiting == false && player.GetScriptScope().waitingon == false && player.GetScriptScope().invited == false) {
			player.GetScriptScope().inMga <- true;
			local slot = rand();
			slot = slot % AvailableA.len();
			player.GetScriptScope().arena <- ["A",AvailableA[slot]];

			player.ForceRegenerateAndRespawn();
			player.GetScriptScope().score <- 0
			}
			else {TextWrapSend(player, 3, (smpref+"\x07940012"+"already waiting for a duel to begin"))}
		break
		}
		case "r":
		{
			if (player.GetScriptScope().waiting == false && player.GetScriptScope().waitingon == false && player.GetScriptScope().invited == false) {
			player.GetScriptScope().arena <- ["L","lobby"];
			player.GetScriptScope().inMga <- true;
			player.GetScriptScope().score <- 0
			player.ForceRegenerateAndRespawn();
			}
			else {TextWrapSend(player, 3, (smpref+"\x07940012"+"already waiting for a duel to begin"))}


		if (player.GetScriptScope().inMga != wasMga)
		{
			player.ForceRegenerateAndRespawn();
			player.GetScriptScope().score <- 0
		}
		if (player.GetScriptScope().arena[0] != "T") {
			player.GetScriptScope().training <- 0;
		}
		break
		}
		default:
		{
			validcmd += 1
			break
		}
	}

		//Check for admin commands
		if (Config["Admins"].find(GetPlayerNetID(player)) != null) {

		switch (new) {

		case "config":
		{
			if (args.len() > 3) {
			if (!(args[1] in Config) || args[1] == "Admins" || args[1] == "AutoRunPlugins") {return}
			local setting = null
			if (args[2] != "null") {
			if (args[3] == "int") {
				setting = args[2].tointeger()
			}
			if (args[3] == "arr") {
				local splits = split(args[2], ",")
				foreach (i in splits) {
					setting = []
					setting.append(i)
				}
			}
			if (args[3] == "str") {
				setting = args[2].tostring()
			}
			if (args[3] == "bool") {
				if (args[2] == "true") {setting = true}
				else {setting = false}
			}
			}
			TextWrapSend(player, 3, ("changing "+args[1]+" from "+Config[args[1]]+" to "+setting))
			Config.rawset(args[1], setting)
			::ConfigRefresh()
			}
			else {
				TextWrapSend(player, 3, smpref+"printing config to console")
				TextWrapSend(player, 1, "_____________________________Config:_____________________________\n")
				foreach (key, value in Config) {
					TextWrapSend(player, 1, (key+" = "+value+"\n"))
				}
				TextWrapSend(player, 1, "________________________________________________________________________")

			}
		break
		}
		case "admincrazy": {

			local picker = null
			if (args.len() == 1) {return}
			if (args[1] != "me") {
			picker = player
            try {
                player = GetPlayerFromUserID(args[1].tointeger())
            } catch(exception) {
                TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid playerid"))
                return
            }

            if (player == null) {
                TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid playerid"))
                return
            }
			}


			if (player.GetScriptScope().crazy == false) {
				player.GetScriptScope().crazy <- true
				TextWrapSend(picker, 3, (smpref+"crazy \x0700FF00enabled\x01 for "+GetColouredName(player)))
				TextWrapSend(player, 3, (smpref+"crazy \x0700FF00enabled\x01 graciously"))
				player.ForceRegenerateAndRespawn();
			}
			else {
				player.GetScriptScope().crazy <- false
				TextWrapSend(picker, 3, (smpref+"crazy \x07FF0000disabled\x01 for "+GetColouredName(player)))
				TextWrapSend(player, 3, (smpref+"crazy \x07FF0000disabled\x01 thankfully"))

		local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
		if (weapon && weapon.Clip1)
		{
			local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

			// save the old clip so we don't overwrite whatever the beggars has in it right now
			local oldClip = weapon.Clip1();

			if (weaponIndex == 730)
			{
				weapon.SetClip1(oldClip);
				weapon.RemoveAttribute("projectile spread angle penalty")
				weapon.RemoveAttribute("clip size bonus")
				weapon.RemoveAttribute("fire rate bonus")
				weapon.RemoveAttribute("Reload time decreased")
				weapon.RemoveAttribute("move speed bonus")
			}
			else if (weaponIndex == 441)
			{
				weapon.RemoveAttribute("Blast radius increased")
				weapon.RemoveAttribute("move speed bonus")
				weapon.RemoveAttribute("deploy time decreased")
				weapon.RemoveAttribute("gesture speed increase")
				weapon.RemoveAttribute("Set DamageType Ignite")
				weapon.RemoveAttribute("fire rate penalty")
				weapon.RemoveAttribute("self dmg push force increased")
				weapon.RemoveAttribute("weapon burn dmg reduced")
				weapon.RemoveAttribute("increased jump height")
			}
			// make liberty launcher, direct hit, and airstrike like stock
			else if (weaponIndex == 127 || weaponIndex == 414 || weaponIndex == 1104)
			{
				weapon.RemoveAttribute("Projectile speed increased")
				weapon.RemoveAttribute("damage bonus")
				weapon.RemoveAttribute("damage penalty")
				weapon.RemoveAttribute("rocketjump attackrate bonus")
				weapon.RemoveAttribute("mod mini-crit airborne")
			}
			else if (weaponIndex == 237)
				{
					// printl("test")
					weapon.RemoveAttribute("no self blast dmg")
					weapon.RemoveAttribute("rocket jump damage reduction")
					weapon.RemoveAttribute("damage bonus")
					weapon.RemoveAttribute("Blast radius decreased")
					weapon.RemoveAttribute("damage penalty")
					weapon.RemoveAttribute("Projectile speed increased")
			}
		}

		for (local i = 1; i < 7; i++)
		{
			local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i);
			if (!weapon)
				continue;
			local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

			// get rid of banners
			if (weaponIndex == 226	|| // battalions backup
				weaponIndex == 129	|| // buff banner
				weaponIndex == 1001 || // festive buff banner
				weaponIndex == 354	|| // conch
				weaponIndex == 1101)   // base jumper
			{
				// do NOT use .Kill(), since the entity will actually remain and progressively slow down the serverz
				weapon.Destroy();
				continue;
			}

			if (weapon.IsMeleeWeapon())
			{
			weapon.RemoveAttribute("turn to gold")
			continue;
			}
		}


			player.ForceRegenerateAndRespawn();
			}
		break
		}
		default:
		{
			validcmd += 1
			break
		}
		}}


		//Check for debug commands
		//===================================WARNING CONTAINS OLD DEPRECATED CODE AS COMMENTS===================================
		if (Config["Debug"]) {
			switch (new) {
		case "debug":
		{
			// printl(GetPlayerNetID(player))
			// printl(GetMapName())
			if (args[0] == Config["Prefix1"]+"debug" || args[0] == Config["Prefix2"]+"debug") {
			// printl(player.GetScriptScope().inMga)
			// printl(NOMGA)
			// printl("ft10"+", "+ListConv(Config["AllowedDtypes"], false, false))
			local text2 = split(params.text.tostring(), "|")
			// // printl(text[0]+"	"+text[1])
			// printl(args[1].tointeger())
			if (args[1] != "all") {
			Say(GetPlayerFromUserID(args[1].tointeger()), (text2[1]), false)}
			else {
				for (local i = 1; i <= MaxPlayers ; i++)
				{
					if (player == null) {continue}
					local player = PlayerInstanceFromIndex(i);
					if (!player || !player.IsPlayer() ||
						!(player.GetTeam() == Constants.ETFTeam.TF_TEAM_RED || player.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE))
					{
						continue;
					}
					if (!player.GetScriptScope().inMga)
						continue;
					Say(player, (text2[1]), false)}

				}
			}




			// TextWrapSend(player,3, (AvailableA))
			// local voltest = null
			// voltest = Entities.FindByName(voltest, "testvol")
			// local max = (voltest.GetOrigin() + voltest.GetBoundingMaxs())
			// local min = (voltest.GetOrigin() - voltest.GetBoundingMaxs())
			// local ploc = (player.GetOrigin())
			// if (ploc.x >= min.x && ploc.x <= max.x &&
			// ploc.y >= min.y && ploc.y <= max.y &&
			// ploc.z >= min.z && ploc.z <= max.z) {
			// 	printl("CRAZY")
			// }
			// local ploc = (player.GetOrigin())
			// foreach (key, value in ::SpecVolumes) {
			// 	// printl("Key: " + key + " has the value: " + value);
			// 	if (ploc.x >= value[0].x && ploc.x <= value[1].x &&
			// 	ploc.y >= value[0].y && ploc.y <= value[1].y &&
			// 	ploc.z >= value[0].z && ploc.z <= value[1].z) {
			// 		printl("in "+key)
			// 	}
			// 	printl(value[0])
			// 	printl(value[1])
			// 	}





			// TextWrapSend(player, 3, (player.GetScriptScope().dtype).tostring())
			// printl(CheckArenaPop(9))
			// printl(::GetPlayerName(player))
			// player.GetScriptScope().score <- 0
			// dScoreCheck(player.GetScriptScope().arena, player, true)
			break
		}
		case "debug2":
		{


			// local args = split(params.text.tostring(), " ")





			// local pos = player.GetOrigin();
			// // local ang = player.EyeAngles();
			// // local velo = player.GetAbsVelocity();

			// local newTeam = 0
			// if (player.GetTeam() == 2) // Checks if the !activator's team number is 2 (Red), and sets the newTeam variable to 3 (Blu)
			// {
			// 	newTeam = 3
			// } else { // If the !activator's team number is not 2 (Red), sets the newTeam variable to 2 (Red) instead
			// 	newTeam = 2
			// }

			// 	local rockets = []
			// 	for (local rocket; rocket = Entities.FindByClassnameWithin(rocket, "tf_projectile_rocket", pos, 1000);)
			// 	{

			// 		if (rocket.GetOwner() == player) {
			// 		rockets.append(rocket)
			// 		rocket.SetOwner(null)
			// 		}
			// 	}

			player.GetScriptScope().teamlock <- 5
			ForceSwapTeam(player)


			// foreach (i in rockets) {
			// 	i.SetOwner(player)
			// 	i.SetTeam(newTeam)
			// }
			// player.ForceRegenerateAndRespawn();

			// player.SetAbsOrigin(pos);
			// player.SnapEyeAngles(ang);
			// player.SetAbsVelocity(velo);

			// // // // player.GetScriptScope().hopnum <- args[1].tointeger()

			// // BhopUiTest(player)
			// // NetProps.SetPropInt(player, "m_iFov", (args[1]).tointeger());
			// Say(botcheck(2), (args[1]+" "+args[2]), false)
			// printl("test")



			// ::BhopTickWindow <- (args[1].tointeger())
			// printl(0.015*::BhopTickWindow)


			// printl((Convars.GetClientConvarValue("fov_desired", player.entindex())).tostring());


			// local args = split(params.text.tostring(), " ")
			// if (args.len() == 3) {
			// 	printl(args[0]+"\n"+args[1]+"\n"+args[2])
			// }
			// printl(player.GetScriptScope().dtype)
			// player.GetScriptScope().cshow = true
			// player.GetScriptScope().waitend <- (Time() + 10);
			// player.GetScriptScope().waiting <- true
			// player.GetScriptScope().adest <- "9"
			// if (player.GetScriptScope().waiting == false && player.GetScriptScope().waitingon == false) {
			// player.GetScriptScope().arena <- 5;
			// player.GetScriptScope().inMga <- true;
			// player.ForceRegenerateAndRespawn();
			// player.GetScriptScope().score <- 0
			// }
			// else {TextWrapSend(player, 3, ("already waiting for a duel to begin"))}
			// botcheck()
			// printl(::TBSpawns[0]+"\n"+::TBSpawns[1]+"\n"+::TBSpawns[2]+"\n"+::TBSpawns[3]+"\n"+::TBSpawns[4]+"\n"+::TBSpawns[5])
			// printl(::TRSpawns[0]+"\n"+::TRSpawns[1]+"\n"+::TRSpawns[2]+"\n"+::TRSpawns[3]+"\n"+::TRSpawns[4]+"\n"+::TRSpawns[5])
			// printl(player.GetScriptScope().training)
			// printl (player.GetTeam())
			// printl(Constants.FPlayer.FL_ONGROUND)
			//blue = 3 red = 2 spec=1


		break
		}
		case "debug3":
		{
            player.GetScriptScope().invited <- false
            player.GetScriptScope().invite <- [null, null]
			// if (args.len() == 2)
			// {player.GetScriptScope().teamlock <- args[1].tointeger()}
			// else {
			// 	printl(player.GetScriptScope().arena[1])
			// 	foreach (i in CustomsList["all"]) {printl(i)}
			// 	printl(CustomsList["all"].find(player.GetScriptScope().arena[1]) != null)
			// }
			break
		}
		case "debug4":
		{

				// 97,120,121,118,104
				// "A:"+format("%5u", (player.GetScriptScope().lvel.tointeger()))
				// "x:"+vel.x.tointeger()
				// "y:"+vel.y.tointeger()
				// "V:"+vel.z.tointeger()
				// "H:" + sqrt(pow(vel.x, 2) + pow(vel.y, 2)).tointeger()




			// if (PluginsConf["ClassRestrict"] == false || player.GetPlayerClass() == PluginsConf["ClassRestrict"])
			// {printl("matches")}
			// if (PluginsConf["ClassRestrict"] != false && player.GetPlayerClass() != PluginsConf["ClassRestrict"])
			// {printl("mismatch")}
			// printl("____________________________")
			// foreach(key, value in testtab)
			// {printl(key+" = "+value)}

			// printl(player.GetPlayerClass() == Constants.ETFClass.("TF_CLASS_"+"SOLDIER"))
            // printl(::CmdListFunc(player))
            // ::CmdListFunc(player)
            // printl(ListConv(::CmdListFunc(player), false, false))
			// NetProps.SetPropEntity(player, "m_hGlowEnt", null)
			// DoEntFire("CustomScore", "Display", "", 0.0, player, null);

			break
		}
		case "debug5":
		{
			printl("inf")
			foreach (key, value in InfList) {
				printl(key)
				foreach (i in value) {printl(i)}
			}
			printl("jugg")
			foreach (key, value in JuggList) {
				printl(key)
				foreach (i in value) {printl(i)}
			}
			printl("freeze")
			foreach (key, value in FreezeList) {
				printl(key)
				foreach (i in value) {printl(i)}
			}
		break
		}


		case "cshow": {
			if (player.GetScriptScope().cshow == false) {
				player.GetScriptScope().cshow = true
				TextWrapSend(player, 3, (smpref+"Crit display \x0700FF00enabled"))
			}
			else {
				player.GetScriptScope().cshow = false
				TextWrapSend(player, 3, (smpref+"Crit display \x07FF0000disabled"))
			}
		break
		}

		case "bshow": {
			if (player.GetScriptScope().bshow == false) {
				player.GetScriptScope().bshow = true
				TextWrapSend(player, 3, (smpref+"Bhop log \x0700FF00enabled"))
			}
			else {
				player.GetScriptScope().bshow = false
				TextWrapSend(player, 3, (smpref+"Bhop log \x07FF0000disabled"))
			}
		break
		}
		default:
		{
			validcmd += 1
			break
		}
		}}

		//Check for practice commands
		if (Config["Jpractice"]) {
			switch (new) {
			case "startpos":
			{
				TextWrapSend(player, 3, (smpref+"Saving practice start pos"))
			player.GetScriptScope().practicepos.rawset("pos",player.GetOrigin())
			player.GetScriptScope().practicepos.rawset("eye",player.EyeAngles())
			break
			}

			case "clearpos":
			{
				TextWrapSend(player, 3, (smpref+"Clearing practice start pos"))
			player.GetScriptScope().practicepos.rawset("pos",null)
			player.GetScriptScope().practicepos.rawset("eye",null)
			break
			}

			case "dummy":
			{
			if (args.len() < 2) {return}
			if (player.GetTeam() != 2 && player.GetTeam() != 3) {return}

			if (!(args[1] in ::PracticeBotPos)) {
			if (player.GetTeam() == 3)
			{
			::PracSpawnerR.KeyValueFromString("bot_name", ("Practice_"+args[1]));
			::PracSpawnerR.AcceptInput("CreateBot","",null,null);
			}
			else
			{
			::PracSpawnerB.KeyValueFromString("bot_name", ("Practice_"+args[1]));
			::PracSpawnerB.AcceptInput("CreateBot","",null,null);
			}
			::PracticeBotPos.rawset(args[1],[player.GetOrigin()])
			}
			else {
				::PracticeBotPos[args[1]].remove(0)

				::PracticeBotPos[args[1]].insert(0,player.GetOrigin())
				::PracticeBotPos[args[1]][1].ForceRegenerateAndRespawn()
			}


			break
			}
			case "regen":
			{
				if (player.GetScriptScope().practiceheal == false) {
					player.GetScriptScope().practiceheal = true
					TextWrapSend(player, 3, (smpref+"Regen \x0700FF00enabled"))
				}
				else {
					player.GetScriptScope().practiceheal = false
					TextWrapSend(player, 3, (smpref+"Regen \x07FF0000disabled"))
				}
				break
			}
			default:
			{
				validcmd += 1
				break
			}
		}}


		//Check for duel commands
        if (Config["DuelsAllowed"]){
		switch (new) {
            case "spec":{

                if (args.len() > 1) {
                    if (args[1] == "auto") {
                        player.GetScriptScope().specduelauto <- true
                        TextWrapSend(player, 3, (smpref+"now receiving auto score updates"))
                        return
                    }
                    if (AvailableD.find(args[1]) != null) {
                        player.GetScriptScope().specduel <- args[1];
                        player.GetScriptScope().specduelauto <- false
                        TextWrapSend(player, 3, (smpref+"now receiving score updates for arena "+args[1]))
                    }
                    else {
                        TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid duel arena please use "+ListConv(AvailableD, false, false)))
                    }
                }
                else {
                    TextWrapSend(player, 3, (smpref+"clearing spectated duel, disabling auto"))
                    player.GetScriptScope().specduelauto <- false
                    player.GetScriptScope().specduel <- null
                }


            break
            }

            case "scoredisplay": {
                    if (args.len() > 1)
                    {
                        switch (args[1])
                        {
                        case "both":
                            TextWrapSend(player, 3, (smpref+"score display set to \x0700FF00both ui and text"))
                            player.GetScriptScope().scoredisplay <- 1
                            break
                        case "text":
                            TextWrapSend(player, 3, (smpref+"score display set to \x07FF0000only text"))
                            player.GetScriptScope().scoredisplay <- -1
                            // ShowText(player, "")
							ShowAnyText(player,"",text_ent)
                            break
                        case "ui":
                            TextWrapSend(player, 3, (smpref+"score display set to \x07FF0000only ui"))
                            player.GetScriptScope().scoredisplay <- 0
                            break
                        default:
                            TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid parameter use both, ui, text"))
                            break
                        }
                    }
                    else {
                        TextWrapSend(player, 3, (smpref+"score display set to \x0700FF00both ui and text"))
                        TextWrapSend(player, 3, ("Parameters both, ui, or text can be used if another mode is desired"))
                        player.GetScriptScope().scoredisplay <- 1
                    }
			break
            }

            case "duels":
            {
            local message = ("");
            foreach (i, value in DSpawntab) {
				local arenapop = CheckArenaPop(i)
                if (arenapop[0] > 0) {
                        if (arenapop[1].GetScriptScope().invited != true) {
                        message = (message + "\n")
                        if (arenapop[0] == 1){
                            message = (message + (i+" t:"+ "\x07FFFF00"+arenapop[1].GetScriptScope().dtype+"\x01"+ " : "+::GetColouredName(arenapop[1])))
                        }
                        if (arenapop[0] == 2){
                            if (arenapop[1].GetScriptScope().dtype == "ft10" || arenapop[1].GetScriptScope().dtype == "bhop" || arenapop[1].GetScriptScope().dtype == "vel") {
                            message = (message + (i+" t:\x07FFFF00"+arenapop[1].GetScriptScope().dtype+"\x01 : "+::GetColouredName(arenapop[1])+" v "+::GetColouredName(arenapop[2]))+" ("+arenapop[1].GetScriptScope().score+("/")+arenapop[2].GetScriptScope().score+")")
                            }
                            if (arenapop[1].GetScriptScope().dtype == "dom") {
                                message = (message + (i+" t:\x07FFFF00dom\x01 : "+::GetColouredName(arenapop[1])+" v "+::GetColouredName(arenapop[2]))+" ("+arenapop[1].GetScriptScope().score+("/")+arenapop[2].GetScriptScope().score+")"+" r:("+(arenapop[1].GetScriptScope().restarts)+"/4)")
                            }
                        }
                }}

            }
            foreach (i, value in DISpawntab) {
				local arenapop = CheckArenaPop(i)
                if (arenapop[0] > 0) {
                        message = (message + "\n")
                        if (arenapop[0] == 1){
                            message = (message + (i+" t:"+ "\x07FFFF00"+arenapop[1].GetScriptScope().dtype+"\x01"+ " : "+::GetColouredName(arenapop[1])))
                        }
                        if (arenapop[0] == 2){
                            if (arenapop[1].GetScriptScope().dtype == "ft10" || arenapop[1].GetScriptScope().dtype == "bhop" || arenapop[1].GetScriptScope().dtype == "vel") {
                            message = (message + (i+" t:\x07FFFF00"+arenapop[1].GetScriptScope().dtype+"\x01 : "+::GetColouredName(arenapop[1])+" v "+::GetColouredName(arenapop[2]))+" ("+arenapop[1].GetScriptScope().score+("/")+arenapop[2].GetScriptScope().score+")")
                            }
                            if (arenapop[1].GetScriptScope().dtype == "dom") {
                                message = (message + (i+" t:\x07FFFF00dom\x01 : "+::GetColouredName(arenapop[1])+" v "+::GetColouredName(arenapop[2]))+" ("+arenapop[1].GetScriptScope().score+("/")+arenapop[2].GetScriptScope().score+")"+" r:("+(arenapop[1].GetScriptScope().restarts)+"/4)")
                            }
                        }
                }

            }
            TextWrapSend(player, 3, (smpref+"Ongoing and available duels:"+message))
			break
            }

            case "invite":
            {
                if (player.GetScriptScope().invited || player.GetScriptScope().waiting || player.GetScriptScope().waitingon)

				{TextWrapSend(player, 3, (smpref+"\x07940012"+"Already have an outbound invite"));return}
                if (args.len() == 1) {
                    local message = ("");
                    message = (message)
                    for (local i = 1; i <= MaxPlayers ; i++)
                    {
                        local fetchedp = PlayerInstanceFromIndex(i);
                        if (!fetchedp || !fetchedp.IsPlayer() || fetchedp.IsFakeClient() || (fetchedp == player))
                        {
                            continue;
                        }
                        if (!fetchedp.GetScriptScope().inMga)
                            continue;
                        message = (message + "\n"+GetPlayerUserID(fetchedp)+" : "+GetColouredName(fetchedp))

                    }
                    TextWrapSend(player,3,(smpref+"Available players:"+message))
                }
                if (args.len() >= 2) {
                    if  (((player.GetScriptScope().arena[0] == "D" || player.GetScriptScope().arena[0] == "DI") && CheckArenaPop(player.GetScriptScope().arena[1])[0] < 2))
                    {
						local string = false
                        local invp = null
                        try {
                            invp = GetPlayerFromUserID(args[1].tointeger())
                        } catch(exception) {
							string = true;
                        };

						if (string) {
						for (local i = 1; i <= MaxPlayers ; i++)
						{
							local fetchedp = PlayerInstanceFromIndex(i);
							if (!fetchedp || !fetchedp.IsPlayer() || fetchedp.IsFakeClient() || (fetchedp == player))
							{
								continue;
							}
							if (!fetchedp.GetScriptScope().inMga)
								continue;

							if ((NetProps.GetPropString(fetchedp, "m_szNetname")).tolower().find(args[1].tolower()) != null)
							{
								invp = fetchedp
								break
							}
						}}

                        if (invp == null) {
							if (!string) {
                            TextWrapSend(player, 3, (smpref+"\x07940012"+"Invalid playerid"))}
							else {TextWrapSend(player, 3, (smpref+"\x07940012"+"No player found"))}
                            return
                        }

                        if (!invp || !invp.IsPlayer() || invp.IsFakeClient() || (invp == player)) {TextWrapSend(player, 3, (smpref+"\x07940012"+"Invalid player"));return}


                        if (invp.GetScriptScope().invite[0] == null) {



                        TextWrapSend(player, 3, (smpref+"Inviting "+GetColouredName(invp))+" to "+player.GetScriptScope().dtype+" duel in "+player.GetScriptScope().arena[1])
                        TextWrapSend(invp, 3, (smpref+"Invited by "+GetColouredName(player))+" to "+player.GetScriptScope().dtype+" duel in "+player.GetScriptScope().arena[1]+". You have 30 seconds to "+Config["Prefix1"]+"accept or "+Config["Prefix1"]+"decline")
                        invp.GetScriptScope().invite <- [player.GetScriptScope().arena[1], (Time()+30)]
                        player.GetScriptScope().invited <- true
                        }
                        else {
                            TextWrapSend(player, 3, (smpref+"\x07940012"+"Player already has a pending invite"))
                        }
                    }
                    else {
						if (args.len() > 2)
						{

							if ((AvailableD.find(args[2]) != null) && CheckArenaPop(args[2])[0] == 0) {


							if (args.len() > 3)
							{
								SendGlobalGameEvent("player_say",
								{
									userid = GetPlayerUserID(player)
									priority = 1
									text = (Config["Prefix1"]+"duel "+args[2]+" "+args[3])
								})
							}
							else
							{
								SendGlobalGameEvent("player_say",
								{
									userid = GetPlayerUserID(player)
									priority = 1
									text = (Config["Prefix1"]+"duel "+args[2])
								})
							}

							SendGlobalGameEvent("player_say",
							{
								userid = GetPlayerUserID(player)
								priority = 1
								text = (Config["Prefix1"]+"invite "+args[1])
							})

						}
						else {TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid or occupied duel arena, please use "+ListConv(AvailableD, false, false)))}

					}
						else
						{
                        	TextWrapSend(player, 3, (smpref+"\x07940012"+"Need to join a duel arena first with "+Config["Prefix1"]+"duel"))
						}

                    }
                }

            break
            }

            case "accept":
            {
                if (player.GetScriptScope().invite[0] != null)
                {
					local arenapop = CheckArenaPop(player.GetScriptScope().invite[0])
                    if (arenapop[0] == 1) {
                        arenapop[1].GetScriptScope().invited <- false
                    }
                    else {TextWrapSend(player, 3, (smpref+"\x07940012"+"Opponent left"))
                    player.GetScriptScope().invite <- [null, null]
                    return}

                    SendGlobalGameEvent("player_say",
                    {
                        userid = GetPlayerUserID(player)
                        priority = 1
                        text = (Config["Prefix1"]+"duel "+player.GetScriptScope().invite[0])
                    })
                    player.GetScriptScope().invite <- [null, null]
                }
                else {TextWrapSend(player, 3, (smpref+"\x07940012"+"No pending invites"))}
            break
            }
            case "decline":
            {
                if (player.GetScriptScope().invite[0] != null)
                {
                    TextWrapSend(player, 3, (smpref+"Invitation declined"))
					local arenapop = CheckArenaPop(player.GetScriptScope().invite[0])
                    if (arenapop[0] == 1) {
                        arenapop[1].GetScriptScope().invited <- false
                        TextWrapSend(arenapop[1], 3, (smpref+"Outbound invite declined"))
                    }
                    player.GetScriptScope().invite <- [null, null]

                }
                else {TextWrapSend(player, 3, (smpref+"\x07940012"+"No pending invites"))}
            break
            }

            case "duel":
            {
                if (args[0] == Config["Prefix1"]+"duel" || args[0] == Config["Prefix2"]+"duel") {
                if (player.GetScriptScope().waiting == false && player.GetScriptScope().waitingon == false && player.GetScriptScope().invited == false) {

                if (args.len() > 1) {
                local arenaval = (args[1])
                if (AvailableD.find(arenaval) != null || AvailableD.len() == 0) {
				local arenapop = CheckArenaPop(arenaval)
                if (arenapop[0] < 2) {



        ///FIX------------------
                if (arenapop[0] == 0) {
                    TextWrapSend(player, 3, (smpref+"entering "+arenaval+" duel arena"))
                    if (args.len() == 3) {
                        if (args[2] == "ft10" || (Config["AllowedDtypes"].find(args[2]) != null)) {
                            player.GetScriptScope().dtype <- args[2]}
                        else {
                            TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid duel type, defaulting to ft10 next time use "+("ft10"+", "+ListConv(Config["AllowedDtypes"], false, false))))
                            player.GetScriptScope().dtype <- "ft10"
                        }
                    }
                    else {
                        TextWrapSend(player, 3, (smpref+"\x07940012"+"no dueltype, defaulting to ft10 next time use "+("ft10"+", "+ListConv(Config["AllowedDtypes"], false, false))))
                        player.GetScriptScope().dtype <- "ft10"
                    }
                    if (arenaval in DSpawntab) {
                    player.GetScriptScope().arena <- ["D",arenaval];}
                    else {player.GetScriptScope().arena <- ["DI",arenaval];}
                    player.GetScriptScope().inMga <- true;
                    player.ForceRegenerateAndRespawn();
                    player.GetScriptScope().score <- 0
                }
                else {
                    if (arenapop[1].GetScriptScope().waitingon == false) {

                        if (arenapop[1].GetScriptScope().invited == true && player.GetScriptScope().invite[0] != arenapop[1].GetScriptScope().arena[1])
                        {TextWrapSend(player, 3, (smpref+"\x07940012"+"Opponent is waiting on another")); return}

                        if (arenapop[1] == player) {
                            if (args.len() == 3) {
                                if (args[2] != player.GetScriptScope().dtype) {
                                    if (args[2] == "ft10" || (Config["AllowedDtypes"].find(args[2]) != null)) {
                                        player.GetScriptScope().dtype <- args[2]
                                        TextWrapSend(player,3, (smpref+"selected current duel, updating duel type"))
                                    }
                                    else {
                                        TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid duel type, duel type unchanged"))
                                    }
                                }
                                else {
                                    TextWrapSend(player,3, (smpref+"selected current duel type, remains unchanged"))
                                }
                            return
                        }
                        else {
                            TextWrapSend(player, 3, (smpref+"\x07940012"+"no duel type provided, remains unchanged"))
                        }
                        return
                        }
                TextWrapSend(player, 3, (smpref+"10 seconds until entering "+arenaval+" duel arena with "+ (::GetColouredName(arenapop[1])+" t:\x07FFFF00"+arenapop[1].GetScriptScope().dtype+"\x01")))
                TextWrapSend(arenapop[1], 3, (smpref+"10 seconds until "+::GetColouredName(player)+ " begins a duel with you t:\x07FFFF00"+arenapop[1].GetScriptScope().dtype+"\x01"))

                player.GetScriptScope().waitend <- (Time() + 10);
                player.GetScriptScope().waiting <- true
                arenapop[1].GetScriptScope().waitingon <- true
                player.GetScriptScope().adest <- arenapop[1].GetScriptScope().arena;
                player.GetScriptScope().opp <- arenapop[1]
                }
                else {TextWrapSend(player, 3, (smpref+"\x07940012"+"Opponent is waiting on another"))}
                }

                }
                else {
                    TextWrapSend(player, 3, (smpref+"\x07940012"+arenaval+ " duel arena is full"))
                }
                }
                else {
                    TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid duel arena, please use "+ListConv(AvailableD, false, false)))
                }
            }
            else { TextWrapSend(player, 3, (smpref+"This map includes duel arenas: "+ListConv(AvailableD, false, false)))}
            }
            else {TextWrapSend(player, 3, (smpref+"\x07940012"+"already waiting for a duel to begin"))}
            }
			break
			}

			case "style":
				{
					if (player.GetScriptScope().style == false) {
						player.GetScriptScope().style = true
						TextWrapSend(player, 3, (smpref+"Bhop style meter \x0700FF00enabled"))
					}
					else {
						player.GetScriptScope().style = false
						TextWrapSend(player, 3, (smpref+"Bhop style meter \x07FF0000disabled"))
						if (player.GetScriptScope().bhopinit == true) {
							if(::BhopUi){RemoveBhopUi(player)}}
						player.GetScriptScope().bhopinit <- false

					}
				break
				}


			default:
			{
				validcmd += 1
				break
			}
        }}


		//Check for training command
        if (Config["TrainingAllowed"]) {
            if (params.text == Config["Prefix1"]+"training" || params.text == Config["Prefix2"]+"training")
            {
                if (player.GetScriptScope().waiting == false && player.GetScriptScope().waitingon == false) {
                local team = 0
                local allowed = true
                if (player.GetTeam() == Constants.ETFTeam.TF_TEAM_RED) {team = 1}
                if (player.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE) {team = 2}
                for (local i = 1; i <= MaxPlayers ; i++) {
                    local player = PlayerInstanceFromIndex(i)
                    if (player == null) continue
                    if (player.GetScriptScope().training == team) {
                        TextWrapSend(player, 3, (smpref+"\x07940012"+"Player already training"))
                        allowed = false
                        return
                    }}
                if (allowed == true) {
                    player.GetScriptScope().arena <- ["T","training"];
                    local ptarg = player
                    botspawn(team, ptarg)
                    player.GetScriptScope().inMga <- true;
                    player.ForceRegenerateAndRespawn();
                    player.GetScriptScope().score <- 0

                    }
            }
            else {TextWrapSend(player, 3, (smpref+"\x07940012"+"already waiting for a duel to begin"))}
            }
			else {validcmd += 1}
        }

		//Check for plugin commands
		if (new in PluginsConf["CommandsHelp"] || "."+new in PluginsConf["CommandsHelp"])
		{
			validcmd += 1
		}

		}

		//Check how many command opportunities are present
		local required = 1
		foreach (i in [Config["TrainingAllowed"],Config["DuelsAllowed"],Config["Jpractice"],Config["Debug"],(Config["Admins"].find(GetPlayerNetID(player)) != null)])
		{
			if (i) {
				required += 1
			}
		}


		//Check if a valid command was used
		//Compares the number of fails to the amount needed to fail all opportunities
		if (validcmd == required) {
			TextWrapSend(player, 3, (smpref+"\x07940012"+"invalid command, maybe try \x07FFFF00"+Config["Prefix1"]+"help commands"))
		}

		}





	OnScriptHook_OnTakeDamage = function(params)
	{
		local ent = params.const_entity;
		local inflictor = params.inflictor;
		local weapon = params.weapon;
		local attacker = params.attacker;


		if (!ent.IsPlayer())
			return;
		if (!ent.GetScriptScope().inMga)
			return;

		//Run func for managing damage
		MgaDamageManage(ent, inflictor, weapon, attacker, params)
		return
	}


}


local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)
}


//Define function for checking arena populations
::CheckArenaPop <- function(ArenaNum)
{
local PopCheck = []
for (local i = 1; i <= MaxPlayers ; i++)
{
    local player = PlayerInstanceFromIndex(i)
    if (player == null) continue
    if (player.GetScriptScope().arena[1] == ArenaNum){
    PopCheck.append(player)
    }


}
switch (PopCheck.len())
{
	case 0: return ([0]);break
	case 1: return ([1, PopCheck[0]]);break
	case 2: return ([2, PopCheck[0], PopCheck[1]]);break
}
}



//Instant respawn func
::InstaSpawn <- function()
{
	self.ForceRespawn();
}

//Spawn keeping crit and pos in custom games and swap team if needed
::CustomGameSpawn <- function()
{
	local player = self
	if (player.GetScriptScope().respawninfo["pos"] != null) {
		player.Teleport(true, player.GetScriptScope().respawninfo["pos"],
			true, player.GetScriptScope().respawninfo["eye"]
			true, player.GetScriptScope().respawninfo["vel"]);
		player.GetScriptScope().respawninfo.rawset("pos",null)
		if (player.GetScriptScope().respawninfo["swap"]) {
			player.GetScriptScope().teamlock <- 5
			ForceSwapTeam(player)
		}
	}
	if (player.GetScriptScope().respawninfo["swap"] == null) {
		player.AddCond(Constants.ETFCond.TF_COND_HALLOWEEN_THRILLER)
		player.AddCondEx(Constants.ETFCond.TF_COND_STEALTHED_USER_BUFF, 2, null)
		player.AddCond(Constants.ETFCond.TF_COND_INVULNERABLE)
		player.AddCond(Constants.ETFCond.TF_COND_MEGAHEAL)
		player.GetScriptScope().respawninfo.rawset("swap",false)
	}

}

//Team change prevention funcs
::TChangePreventB <- function()
{
	self.ForceChangeTeam(3,true)
	TextWrapSend(self, 3, (smpref+"\x07940012 Cannot change team while in infection/juggernaut2"))
}

::TChangePreventR <- function()
{
	self.ForceChangeTeam(2,true)
	TextWrapSend(self, 3, (smpref+"\x07940012 Cannot change team while in infection/juggernaut3"))
}


//Func for knockback immune bots
::PostBotSpawn <- function()
{
    // "self" is the player entity here
    self.AddCond(Constants.ETFCond.TF_COND_MEGAHEAL)
}

// Function to change the volume of the currently playing sound
::ChangeVolume <- function(soundName, newVolume)
{
    // Ensure the new volume is within the 0.0 - 1.0 range using the Clamp function
    local clampedVolume = newVolume

    // Emit the sound with the new volume
    EmitSoundEx({
        sound_name = soundName,  // The name of the sound to change volume
        volume = clampedVolume,  // New volume level to set
        flags = 1                //SND_CHANGE_VOL
    });
}

//Stop pain sounds func
::PainStop <- function(/*self*/)
{
		if (self.IsFakeClient() == false && self.GetPlayerClass() == Constants.ETFClass.TF_CLASS_SOLDIER && self.GetScriptScope().inMga == true && self.GetScriptScope().painsnd){
		for (local i=1; i <= 6; i++) {
			EmitSoundEx({
			sound_name = ("Soldier.PainSevere0"+i),
			channel = 6,
			flags = 4,
			entity = self,
			filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_SINGLE_PLAYER
		});
		}
	}
}


//Function checks if player is off the ground 1 tick after explosion
//Ensures players will never be given crit for a single tick without leaving the ground
::PostRocketHit <- function()
{


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["PostRocketHit"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	local vel = self.GetAbsVelocity()
	if (vel.z != 0) {
	if (self.GetScriptScope().canCrit == false)
	{
	self.GetScriptScope().canCrit <- true
	}


	}
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["PostRocketHit"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

}

//Delayed score check function
::PostdScoreCheck <- function() {
	dScoreCheck(self.GetScriptScope().arena[1], self, true)
}

//Score check and update function
::dScoreCheck <- function(arena, player, new) {
	if ((player.GetScriptScope().scoredisplay != -1) && (new == true || Time() > player.GetScriptScope().lastDshown + 9)) {
		if (player.GetScriptScope().arena[0] == "D" || player.GetScriptScope().arena[0] == "DI") {
			arena = player.GetScriptScope().arena[1]
		}
		else {
			if (player.GetScriptScope().specduel != null && player.GetTeam() == 1) {
				arena = player.GetScriptScope().specduel
			}
			else {return;}
		}
		local arenapop = CheckArenaPop(arena)
		if (arenapop[0] == 2) {
		local p1 = NetProps.GetPropString(arenapop[1], "m_szNetname");
		local p2 = NetProps.GetPropString(arenapop[2], "m_szNetname");
		local score = null
		if (arenapop[1].GetScriptScope().dtype == "dom") {
			score = (p1+": "+arenapop[1].GetScriptScope().score+", "+p2+": "+arenapop[2].GetScriptScope().score+" r:("+(arenapop[1].GetScriptScope().restarts)+"/4)")
		}
		else {
		score = p1+": "+arenapop[1].GetScriptScope().score+", "+p2+": "+arenapop[2].GetScriptScope().score
		}
		// ShowText(player, score)
		ShowAnyText(player,score,text_ent)
		player.GetScriptScope().lastDshown <- Time()
	} else {
		// ShowText(player, "")
		ShowAnyText(player,"",text_ent)
	}
	}
}


//Bot creation func
function botspawn(params, pt) {
	if (botcheck(params) == null) {
		local ent = ("DumSpawn"+params+"2").tostring()
		EntFire(ent, "CreateBot","",0.0,null);
		if (pt != null) {
		pt.GetScriptScope().training <- params;}
	}
	else {
		local targ = botcheck(params)
		targ.GetScriptScope().tspawn = 0;
		if (pt != null) {
		pt.GetScriptScope().training <- params;}
		targ.ForceRegenerateAndRespawn();

	}
}

//Check for bot on team func
function botcheck(params) {
for (local i = 1; i <= MaxPlayers ; i++)
{
    local player = PlayerInstanceFromIndex(i)
    if (player == null) continue
    if (player.IsFakeClient() == true){
			if (params == 1 && player.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE && (NetProps.GetPropString(player, "m_szNetname") == "BDummy")) {
				return (player)
			}
			if (params == 2 && player.GetTeam() == Constants.ETFTeam.TF_TEAM_RED) {
				return (player)
			}
		}
}
}

//Team swap function
::ForceSwapTeam <- function(player) // Call this in map via RunScriptCode > ActivatorSwapTeam() or CallScriptFunction > ActivatorSwapTeam on a logic_script that has an Entity Script with this function
{


	local pos = player.GetOrigin();
	// local ang = player.EyeAngles();
	// local velo = player.GetAbsVelocity();

    // The following snippet checks if an !player has been specified and if they are a player
    // If either question's answer is no, then don't execute the rest of the function
    if (player == null || player.IsPlayer() == false)
    {
        return
    }

    // The following snippet compares the !player's team number (Ranging from 0 to 3) to the ones used by Unassigned (0) and Spectator (1)
    // If they match with either Unassigned or Spectator, we don't execute the rest of the function
    // Used to ignore any potentional spectator !players
    if (player.GetTeam() == 0 || player.GetTeam() == 1)
    {
        return
    }

    // The following snippet specifies a local newTeam variable, and then we set it to a team number based off the !player's current team number
    local newTeam = 0
    if (player.GetTeam() == 2) // Checks if the !player's team number is 2 (Red), and sets the newTeam variable to 3 (Blu)
    {
        newTeam = 3
    } else { // If the !player's team number is not 2 (Red), sets the newTeam variable to 2 (Red) instead
        newTeam = 2
    }

		local rockets = []
		for (local rocket; rocket = Entities.FindByClassnameWithin(rocket, "tf_projectile_rocket", pos, 1000);)
		{

			if (rocket.GetOwner() == player) {
			rockets.append(rocket)
			rocket.SetOwner(null)
			NetProps.SetPropBool(rocket, "m_bForcePurgeFixedupStrings", true)
			}
		}




    // The following snippet calls the ForceChangeTeam method on the !player
    // First parameter: Team number to switch to
    // Second parameter: If false, the game will reset the player's dominations and nemesises, and kill them if mp_highlander is on
    player.ForceChangeTeam(newTeam, true)

    local cosmetic = null // Assign the "cosmetic" variable to null, will be assigned new values when going over cosmetic items
    // The following snippet will go over every cosmetic item currently present, and will change its colours to the appropriate team if they are the !player's
    while (cosmetic = Entities.FindByClassname(cosmetic, "tf_wearable")) // Goes over every cosmetic item, executing code below
    {
        if (cosmetic.GetOwner() == player) // Checks if the currently iterated cosmetic item's wearer is the !player
        {
            cosmetic.SetTeam(newTeam) // Sets the team of the cosmetic item to the new team number that we stored in newTeam
        }
    }



	foreach (i in rockets) {
		i.SetOwner(player)
		i.SetTeam(newTeam)
	}
}


//Fetch player names
::GetPlayerName <- function(player)
{
    return NetProps.GetPropString(player, "m_szNetname");
}


//Fetch team coloured player names
::GetColouredName <- function(player)
{
	if (player == null) {return;}
	local name = NetProps.GetPropString(player, "m_szNetname");
		if (player.GetTeam() == 3) {
			return ("\x0799CCFF"+name+"\x01");
		}
		if (player.GetTeam() == 2) {
			return ("\x07FF3F3F"+name+"\x01")
		}
		if (player.GetTeam() == 1) {
			return ("\x07CCCCCC"+name+"\x01")
		}
}

//Sending scores in chat function
::ScoreTextWrapSend <- function(player,loc,string) {
if (player.GetScriptScope().scoredisplay == 0) {return;}
TextWrapSend(player,loc,string)

}


//Replaced ClientPrint command, ensures splitting of messages greater than the max character limit
//Splits at newlines and avoids cutting words
::TextWrapSend <- function(player,loc,string)
{
    local i = 0
    local size = 246
    local words = split(string, " ")
    local lines = ["\x01"]
    foreach (n in words) {
        local len = n.len()
        if (len + 1 + lines.top().len() <= size) {
            lines[lines.len()-1] = (lines.top()+n+" ")
        }
        else {
            if (len <= size) {lines.append("\x01"+n)}
            else {
                local size2 = size-1
                local len2 = n.len()
                for(i = 0; i < (len2 / size2) ; i++) {
                    lines.append("\x01"+n.slice(i*size2,(i+1)*size2) + "-")
                }
                if (len2 > i*size2) {
                    lines.append("\x01"+n.slice(i*size2,len2))
                }
            }
        }
    }

    foreach (i in lines) {
        ClientPrint(player,loc,i)
    }
}

//Function for sending messages during duels
::SpecDuelMsg <- function(arena, deadp, killp, dtype, arenapop1, arenapop2)
{
// local arenapop = CheckArenaPop(arena)
local p1 = ::GetColouredName(arenapop1)
local p2 = ::GetColouredName(arenapop2)
local prefix = (smpref+"\x07FFFF00"+arena+" "+dtype+"\x01: ")
for (local i = 1; i <= MaxPlayers ; i++)
{
    local player = PlayerInstanceFromIndex(i)
    if (player == null) continue
    if (player.GetScriptScope().arena[1] == player.GetScriptScope().specduel) {return}
	if (player.GetScriptScope().specduel == arena) {
		// printl("spec test")
			if (dtype == "ft10" || dtype == "bhop" || dtype == "vel") {
				if (dtype != "bhop") {
					TextWrapSend(player, 3, (prefix+p1+": "+arenapop1.GetScriptScope().score+", "+p2+": "+arenapop2.GetScriptScope().score))
				} else {
					TextWrapSend(player, 3, (prefix+p1+": "+arenapop1.GetScriptScope().score+", "+p2+": "+arenapop2.GetScriptScope().score+ " "+combocheck(killp.GetScriptScope().hopnum)))
				}
			}
			if (dtype == "dom") {
				TextWrapSend(player, 3, (prefix+p1+": "+arenapop1.GetScriptScope().score+", "+p2+": "+arenapop2.GetScriptScope().score+" r:("+(killp.GetScriptScope().restarts)+"/4)"))
			}
			dScoreCheck(player.GetScriptScope().arena[1], player, true)
	}
}



}


//Check and return combo names
function combocheck(params) {
	if (params >= 25) {
		return combonames["25"]
	}
	if (params == 0) {
		return ("S: \x074a4a4a:(\x01")
	}
	if (params < 25 && params != 0) {
		return ("S: "+combonames[params.tostring()])
	}
}


//Rebound rockets vertically
::RocketRebound <- function(params) {
	local rocket = activator
	local vel = rocket.GetAbsVelocity()
	local ang = rocket.GetAbsAngles()

	NetProps.SetPropBool(rocket, "m_bForcePurgeFixedupStrings", true)

	if (params == 1) {
	rocket.SetAbsVelocity(Vector(vel.x,vel.y,-vel.z))
	rocket.SetAbsAngles(QAngle(360-ang.x, ang.y, ang.z))
	}
	else {
	rocket.SetAbsVelocity(Vector(0,0,-175))
	rocket.SetAbsAngles(QAngle(90, 0, 0))
	}
}

//Explode volume function
::TestExplodeVol <- function(box) {
	local ent = null
	local rocket = activator

	NetProps.SetPropBool(rocket, "m_bForcePurgeFixedupStrings", true)

	local text = ("Air_" + box.tostring())
	local test_relay = SpawnEntityFromTable("logic_relay",
	{
		targetname = text
	});
	NetProps.SetPropBool(test_relay, "m_bForcePurgeFixedupStrings", true)
	ent = Entities.FindByName(ent, (test_relay.GetName()))
	NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
	test_relay.Destroy()
	try {
	ent.SetAbsOrigin(rocket.GetOrigin())
	} catch(exception) {return}
}


//AUTO EDGEBUG TRIGGER, USE CAREFULLY!!
function autoeb(params)
{
	if (params != 1) {return;}
	local vel = activator.GetAbsVelocity();

	if (vel.z <= -100)
	{
		activator.SetAbsVelocity(Vector(vel.x, vel.y, 0))

	}

}


//Portal doors function, see map prefabs for use cases
function portaldoor(params)
{
	if (activator.GetScriptScope().waiting == false && activator.GetScriptScope().waitingon == false) {
		if (params == 0) {
				activator.GetScriptScope().score <- 0;
				activator.GetScriptScope().arena <- ["L","lobby"];
				activator.GetScriptScope().training <- 0;
				activator.GetScriptScope().inMga <- true;
				activator.ForceRegenerateAndRespawn();
				return
		}

		if (params == -1) {
			activator.SetTeam(2)
				activator.GetScriptScope().score <- 0;
				activator.GetScriptScope().arena <- ["L","lobby"];
				activator.GetScriptScope().training <- 0;
				activator.GetScriptScope().inMga <- true;
				activator.ForceRegenerateAndRespawn();

			return
		}
		if (params == "training" && Config["TrainingAllowed"]) {
			local team = 0
			local allowed = true
			if (activator.GetTeam() == Constants.ETFTeam.TF_TEAM_RED) {team = 1}
			if (activator.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE) {team = 2}
			for (local i = 1; i <= MaxPlayers ; i++) {
				local player = PlayerInstanceFromIndex(i)
    			if (player == null) continue
				if (player.GetScriptScope().training == team) {
					TextWrapSend(activator, 3, (smpref+"Player already training"))
					allowed = false
					return
				}}
			if (allowed == true) {
				activator.GetScriptScope().arena <- ["T","training"];
				local ptarg = activator
				botspawn(team, ptarg)
				activator.GetScriptScope().inMga <- true;
				activator.ForceRegenerateAndRespawn();
				activator.GetScriptScope().score <- 0

			}


			}
		else {
		if (params.slice(0,1) == (".") || (AvailableA.find(params) != null)) {
        activator.GetScriptScope().arena <- ["A",params];
        activator.GetScriptScope().inMga <- true;
        activator.ForceRegenerateAndRespawn();
		activator.GetScriptScope().score <- 0
		}
		}
	}
		else {TextWrapSend(activator, 3, (smpref+"already waiting for a duel to begin"))}
}







::PlayerThink <- function()
{

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["PlayerThink"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

	//define locals
	local player = self;
	local bhopped = false

	//Return of not sourcetv player
	if (player == null) {return;}

	//Silly check for hidden chat commands using cl_team value
	if (player.IsFakeClient() == false) {
	if (Convars.GetClientConvarValue("cl_team", player.entindex()).tostring() != player.GetScriptScope().hidteam) {
		player.GetScriptScope().hidteam <- (Convars.GetClientConvarValue("cl_team", player.entindex()).tostring())
		SendGlobalGameEvent("player_say",
		{
			userid = GetPlayerUserID(player)
			priority = 1
			text = (Convars.GetClientConvarValue("cl_team", player.entindex()).tostring())
		})
	}
	}


		//Unfree check + set nearby opponents to debris collision to prevent player stucks :)
		if (player.GetCondDuration(Constants.ETFCond.TF_COND_HALLOWEEN_THRILLER) != 0)
		{
			PlayerStuckPrevent(player)
		}

		//If debris collision, check if not near players if not then set back to normal
		if (player.GetCollisionGroup() == 2)
		{
			local foundl = false
			for (local found2; found2 = Entities.FindByClassnameWithin(found2, "player", player.GetOrigin(), 100);)
			{

				//stop players getting stuck
				if (found2 != player && found2 && !foundl && found2.GetTeam() != player.GetTeam())
				{
				    foundl = true;
				}
				continue
			}
				if (!foundl)
				{
					player.SetCollisionGroup(5)
				}
		}

		//Removing jugg affects if needed
		if (JuggList["3"].find(player) == null && player.GetScriptScope().jugg && !player.GetScriptScope().juggforce)
		{
			// printl("not jugg!!")
				player.GetScriptScope().jugg <- false
		local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
		if (weapon && weapon.Clip1)
		{
			local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

			// save the old clip so we don't overwrite whatever the beggars has in it right now
			local oldClip = weapon.Clip1();
			if (weaponIndex == 18 ||
			weaponIndex == 205 ||
			weaponIndex == 127 ||
			weaponIndex == 228 ||
			weaponIndex == 237 ||
			weaponIndex == 414 ||
			weaponIndex == 441 ||
			weaponIndex == 513 ||
			weaponIndex == 730 ||
			weaponIndex == 1104
			) {
				weapon.RemoveAttribute("fire rate bonus");
				weapon.RemoveAttribute("Reload time decreased");
			}
		}
				player.ForceRegenerateAndRespawn();

		}
		//If jugg add effects
		if (JuggList["3"].find(player) != null && (player.GetScriptScope().jugg == false || player.GetCondDuration(Constants.ETFCond.TF_COND_SODAPOPPER_HYPE) == 0))
		{
				player.GetScriptScope().jugg <- true
				player.AddCond(Constants.ETFCond.TF_COND_SODAPOPPER_HYPE)
		}


	//Custom Game Team Lock Needed
	if (player.GetTeam() == 3 || player.GetTeam() == 2) {
		if ((CustomsList["inf"].find(player.GetScriptScope().arena[1]) != null) && player.GetScriptScope().teamlock == 0)
		{

			local list = null
			foreach(key, value in CustomsList) {
				if (key == "all") {continue}
				if (value.find(player.GetScriptScope().arena[1]) != null) {
					list = CustomListMatchip[key]
				}
			}

			if (list["3"].len() != 0)
			{
				player.GetScriptScope().teamlock <- 3
				player.ForceChangeTeam(3,true)
			}
			else
			{
				player.GetScriptScope().teamlock <- 2
				player.ForceChangeTeam(2,true)
			}

			player.ForceRespawn()
			list[player.GetTeam().tostring()].append(player)
		}

		if ((CustomsList["jugg"].find(player.GetScriptScope().arena[1]) != null) && player.GetScriptScope().teamlock == 0)
		{

			local list = null
			foreach(key, value in CustomsList) {
				if (key == "all") {continue}
				if (value.find(player.GetScriptScope().arena[1]) != null) {
					list = CustomListMatchip[key]
				}
			}

				player.GetScriptScope().teamlock <- 2
				player.ForceChangeTeam(2,true)

			player.ForceRespawn()
			list[player.GetTeam().tostring()].append(player)
		}

		if ((CustomsList["freeze"].find(player.GetScriptScope().arena[1]) != null) && player.GetScriptScope().teamlock == 0)
		{

			local list = null
			foreach(key, value in CustomsList) {
				if (key == "all") {continue}
				if (value.find(player.GetScriptScope().arena[1]) != null) {
					list = CustomListMatchip[key]
				}
			}

				player.GetScriptScope().teamlock <- player.GetTeam()
			list[player.GetTeam().tostring()].append(player)
		}


		if ((CustomsList["all"].find(player.GetScriptScope().arena[1]) == null) && player.GetScriptScope().teamlock != 0)
		{
			player.GetScriptScope().teamlock <- 0
			foreach(key, list in CustomListMatchip) {
			if (list[player.GetTeam().tostring()].find(player) != null) {
				list[player.GetTeam().tostring()].remove(list[player.GetTeam().tostring()].find(player))
			}
		}
		}
	} else {player.GetScriptScope().teamlock <- 0}


	//Voice line checker
	if (player.IsFakeClient() == false)
	{

		local ent = null;
		while (ent = Entities.FindByClassname(ent, "instanced_scripted_scene"))
		{
			NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
			local owner = NetProps.GetPropEntity(ent, "m_hOwner");
			if (owner != null) {
				OnPlayerVoiceline(owner, ent);

				local text = ("_scene")
				local test_relay = SpawnEntityFromTable("logic_relay",
				{
					targetname = text
				});
				NetProps.SetPropBool(test_relay, "m_bForcePurgeFixedupStrings", true)


				ent.KeyValueFromString("classname", test_relay.GetName());
				test_relay.Destroy()
			}
		}

	}





	//SPEC VOL CHECK
	if (("SpecVolumes" in getroottable()) && (player.GetTeam() == 1 || player.GetTeam() == null) && player.GetScriptScope().specduelauto == true) {
		local ploc = (player.GetOrigin())
		foreach (key, value in ::SpecVolumes) {
			if (ploc.x >= value[0].x && ploc.x <= value[1].x &&
			ploc.y >= value[0].y && ploc.y <= value[1].y &&
			ploc.z >= value[0].z && ploc.z <= value[1].z) {
				if (player.GetScriptScope().specduel == null || player.GetScriptScope().specduel != key ) {
					player.GetScriptScope().specduel <- key;
					TextWrapSend(player, 4, ("now receiving score updates for arena "+key))
					dScoreCheck(key, player, true)
				}
			}
			}
	}

	//Bhopui updater and fov scaler
	if (player.GetScriptScope().dtype == "bhop" && player.GetScriptScope().style == true) {
    try {
        if (player.GetScriptScope().bhopinit == false) {
			player.GetScriptScope().bhopinit <- true
			player.SetVar("hud_props", {});
			if(::BhopUi){SpawnBhopUi(player, player.GetScriptScope().fovcmd.tointeger())}
            return
        }
    } catch(exception) {
        player.GetScriptScope().bhopinit <- true
		player.SetVar("hud_props", {});
        if(::BhopUi){SpawnBhopUi(player, player.GetScriptScope().fovcmd.tointeger())}
    }
	}


	//Duel waiting end and team switch + duel vars reset
	if (player.GetScriptScope().waiting == true) {
		if (Time() > waitend)
		{

		if (player.GetScriptScope().opp.GetTeam() != 1) {
			player.SetTeam(-player.GetScriptScope().opp.GetTeam() + 5)
		}
		else {
			if (player.GetTeam() != 1) {
			player.GetScriptScope().opp.SetTeam(-player.GetTeam() + 5)
			}
			else {
				player.SetTeam(2)
				player.GetScriptScope().opp.SetTeam(3)
			}
		}

		player.GetScriptScope().arena <- player.GetScriptScope().adest;
		player.GetScriptScope().dtype <- opp.GetScriptScope().dtype
        player.GetScriptScope().inMga <- true;
        player.ForceRegenerateAndRespawn();
		player.GetScriptScope().score <- 0
		player.GetScriptScope().restarts <- 4
		player.GetScriptScope().waiting <- false

		player.GetScriptScope().opp.ForceRegenerateAndRespawn();
		player.GetScriptScope().opp.GetScriptScope().score <- 0
		player.GetScriptScope().opp.GetScriptScope().restarts <- 4
		player.GetScriptScope().opp.GetScriptScope().waitingon <- false
		}
	}


	if (!player.GetScriptScope().inMga)
		return;

	//Tick heal
	if ((Config["Jpractice"] == false || player.GetScriptScope().practiceheal) || player.IsFakeClient()) {
	player.SetHealth(500);}

	//Define locals needed for bhop checking
	local vel = player.GetAbsVelocity();
	local lastVel = player.GetScriptScope().lastVel;
	local buttons = NetProps.GetPropInt(player, "m_nButtons");
	local buttons_changed = buttons_last ^ buttons;
	local buttons_pressed = buttons_changed & buttons;
	local buttons_released = buttons_changed & (~buttons);
	local lastjtime = player.GetScriptScope().jtime


	//Check if landed
	if ((player.IsOnGround() == 1) || vel.z == 0)
	{
			if (player.GetScriptScope().canCrit == true && player.GetScriptScope().landed == false)
			{
				//Set landed and get tick when first landed
				player.GetScriptScope().landed <- true;
				player.GetScriptScope().lastLandTime <- NetProps.GetPropInt(player, "m_nSimulationTick")
			}
	}


		//Manage rocket jumper whistle
		local weapon = NetProps.GetPropEntityArray(self, "m_hMyWeapons", 0);
		if (weapon)
		{
			local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
			if (weaponIndex == 1104) {
				if (player.GetScriptScope().canCrit == true && player.GetCondDuration(Constants.ETFCond.TF_COND_BLASTJUMPING) == 0) {
					player.AddCondEx(Constants.ETFCond.TF_COND_BLASTJUMPING, -1, null);
				}
				if (player.GetScriptScope().canCrit == false && player.GetCondDuration(Constants.ETFCond.TF_COND_BLASTJUMPING) != 0) {
					player.RemoveCondEx(Constants.ETFCond.TF_COND_BLASTJUMPING, true)
					if (((player.IsOnGround() == 1) || vel.z == 0) && Config["Jpractice"] == false)
					{player.Regenerate(true);}
				}
			}
		}





	//JUMP DETECT
		if ((buttons_pressed & Constants.FButtons.IN_JUMP))
		{
			if (((player.IsOnGround() == 1) || vel.z == 0) && player.GetScriptScope().canCrit) {
				local tdiff = (NetProps.GetPropInt(player, "m_nSimulationTick") - player.GetScriptScope().lastLandTime)
				if (tdiff <= Config["BhopTickWindow"]) { //Check if number of ticks between landing and next jump is less or equal to the amount of allowed ticks
					player.GetScriptScope().bhopped <- true
					//Run function on hop for plugins. Saves them manually checking as well
					Bhopped()

				}
			}

			//Set tick we input jump
			player.GetScriptScope().jtime <- NetProps.GetPropInt(player, "m_nSimulationTick")

	}
	//Set last pressed buttons
	buttons_last = buttons;


	//Another ground check AFTER checking for jumps
	if ((player.IsOnGround() == 1) || vel.z == 0)
	{
			if (player.GetScriptScope().canCrit == true && player.GetScriptScope().landed == false)
			{
				player.GetScriptScope().landed <- true;
				player.GetScriptScope().lastLandTime <- NetProps.GetPropInt(player, "m_nSimulationTick")
			}




			//Checking if bhopped and then updating bhop number and ui
			if (player.GetScriptScope().bhopped == true){
				player.GetScriptScope().landed <- false;
				player.GetScriptScope().canCrit <- true;
				bhopped = true
				player.GetScriptScope().hopnum = (player.GetScriptScope().hopnum + 1)
				if (player.GetScriptScope().dtype == "bhop" && (player.GetScriptScope().arena[0] == "D" || player.GetScriptScope().arena[0] == "DI")){
					TextWrapSend(player, 3, ("\x01hop# = \x0700FF00"+player.GetScriptScope().hopnum))
					if (player.GetScriptScope().style == true) {
						try {
							if (player.GetScriptScope().bhopinit == true) {
								if(::BhopUi){UpdateBhopUi(player, hopnum)}
							}
						} catch(exception) {
							player.SetVar("hud_props", {});
							if(::BhopUi){SpawnBhopUi(player, player.GetScriptScope().fovcmd.tointeger())}
							if(::BhopUi){UpdateBhopUi(player, hopnum)}
						}
					}
				}

				player.GetScriptScope().bhopped <- false;
				return
			}

			//If current tick is passed the land tick + allowed leniancy ticks and can crit, and hasn't hopped, and hasn't jumped in the allowed window
			//Then cancel whistle, update variables, update ui, bshow printing
			if ((NetProps.GetPropInt(player, "m_nSimulationTick") > (player.GetScriptScope().lastLandTime + (Config["BhopTickWindow"]))) && player.GetScriptScope().lastCrit == true && bhopped == false && (player.GetScriptScope().jtime < player.GetScriptScope().lastLandTime || player.GetScriptScope().jtime > (Config["BhopTickWindow"]))) {
				player.GetScriptScope().canCrit <- false;
						EmitSoundEx({
						sound_name = "BlastJump.Whistle",
						flags = 4,
						channel = 0,
						entity = self
						filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
					});
				player.GetScriptScope().landed <- false;

				if (player.GetScriptScope().hopnum > 0) {
					if (player.GetScriptScope().bshow == true && (player.GetScriptScope().dtype != "bhop")) {
							TextWrapSend(player, 3, ("\x01hop# \x07FF0000was\x01 = \x0700FF00"+player.GetScriptScope().hopnum))
						}
					player.GetScriptScope().hopnum = (0)
					if (player.GetScriptScope().dtype == "bhop" && (player.GetScriptScope().arena[0] == "D" || player.GetScriptScope().arena[0] == "DI")) {
						TextWrapSend(player, 3, ("\x01hop# \x07FF0000reset"))
						if (player.GetScriptScope().style == true) {
							if(::BhopUi){UpdateBhopUi(player, 0)}}
						}
				}
			}
	}


		if (player.GetScriptScope().lastCrit == false && player.GetScriptScope().canCrit)
		{
			local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
			if (weapon)
			{
				local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
				if (weaponIndex == 237) {
					EmitSoundEx({
						sound_name = "BlastJump.Whistle",
						flags = 0,
						volume = 0.8,
						channel = 0,
						entity = player,
						filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
					});
			}
		}
		}









	//Checks if player has cshow toggled, is crit, and had the indicator put up more than 10s ago, if so put it back up and set new time for lastcshow
	if ((player.GetScriptScope().cshow == true && player.GetScriptScope().canCrit == true) && (Time() - player.GetScriptScope().lastCshow > 10)) {
		player.GetScriptScope().lastCshow <- Time();
		DoEntFire("cshow test2", "Display", "", 0.0, player, null);
	}


		dScoreCheck(player.GetScriptScope().arena[1], player, false)


	//bhop fail check
	//Checks if cshow toggled, no crit, and the player has changed from crit to no crit this tick
	if ((player.GetScriptScope().canCrit == false && player.GetScriptScope().cshow == true) && player.GetScriptScope().canCrit != player.GetScriptScope().lastCrit) {
		DoEntFire("wipe test2", "Display", "", 0.0, player, null); //Abuses the source limits that only 1 text can be shown per channel to wipe the indicator instantly by displaying empty text on the channel
		player.GetScriptScope().lastCshow <- 0 //Sets last time shown to 0 so above if statement will return true next time the player jumps

	}

	//Set ground and crit stats for this tick
	player.GetScriptScope().lastCrit <- player.GetScriptScope().canCrit
	player.GetScriptScope().lastGround <- player.IsOnGround()


	//Calculate current abs vel
	player.GetScriptScope().lvel <- vel.Length()

	//Check speedo mode and what display what is needed
	switch (player.GetScriptScope().speedo)
	{
	case 2:
		{
		ShowAnyText(player, (CustomSpeedo(player, player.GetScriptScope().customspeedo)), speedo_ent)
		ShowAnyText(player, null, score_ent)
		ShowAnyText(player, null, text_ent)

		break
		}
	case 1:
		// ShowTextSpeedo(player, format("%5u", (player.GetScriptScope().lvel.tointeger())))
		//_________THIS IS JANK NEEDED TO PREVENT SPEEDO PREVENTING OTHER TEXT ENTS FROM DISPLAYING, FUN_________
		ShowAnyText(player, format("%5u", (player.GetScriptScope().lvel.tointeger())) ,speedo_ent)
		ShowAnyText(player, null, score_ent)
		ShowAnyText(player, null, text_ent)
		break
	case -1:
		// ShowTextSpeedo(player, "x:"+vel.x.tointeger()+"\ny:"+vel.y.tointeger()+"\nv:"+vel.z.tointeger()+"\nH:"+sqrt(pow(vel.x,2)+pow(vel.y,2)).tointeger())
		//_________THIS IS JANK NEEDED TO PREVENT SPEEDO PREVENTING OTHER TEXT ENTS FROM DISPLAYING, FUN_________
		ShowAnyText(player, "x:"+vel.x.tointeger()+"\ny:"+vel.y.tointeger()+"\nV:"+vel.z.tointeger()+"\nH:"+sqrt(pow(vel.x,2)+pow(vel.y,2)).tointeger(), speedo_ent)
		ShowAnyText(player, null, score_ent)
		ShowAnyText(player, null, text_ent)
		break
	case 0:
		break
	default:
		break
	}




	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["PlayerThink"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	return -1;
}

::CustomGameLogic <- function()
{
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["CustomGameLogic"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	// Freezetag logic
	if (FreezeRunning == false) {
		if (FreezeList["2"].len() > 0 && FreezeList["3"].len() > 0) {

		local playlist = []
		foreach (i in FreezeList["2"]) {
			playlist.append(i)
		}
		foreach (i in FreezeList["3"]) {
			playlist.append(i)
		}

			foreach (i in playlist) {
			i.ForceRespawn()
			TextWrapSend(i, 3, (smpref+"\x0703DFFCFREEZE THEM!"))
			}
			FreezeRunning <- true;
		}
	}
	local RFroze = 1
	local BFroze = 1
	if(FreezeRunning) {


		foreach(i in FreezeList["2"]) {
			RFroze = RFroze * i.GetCondDuration(Constants.ETFCond.TF_COND_HALLOWEEN_THRILLER)
		}

		foreach(i in FreezeList["3"]) {
			BFroze = BFroze * i.GetCondDuration(Constants.ETFCond.TF_COND_HALLOWEEN_THRILLER)
		}


	if ((RFroze != 0 && RFroze != -0) || (BFroze != 0 && BFroze != -0)) {
		FreezeRunning <- false;

		local playlist = []
		foreach (i in FreezeList["2"]) {
			playlist.append(i)
		}
		foreach (i in FreezeList["3"]) {
			playlist.append(i)
		}

		if (RFroze == 0 || RFroze == -0) {
			foreach(i in playlist) {
				TextWrapSend(i, 3, (smpref+"\x07FF3F3FRed WINS!"))
			}}
		else {
						foreach(i in playlist) {
				TextWrapSend(i, 3, (smpref+"\x0799CCFFBlue WINS!"))
			}
		}
		RunWithDelay(0, function(){CustomGameLogic()})
		}
	}

	// JUGG logic
	if (JuggRunning == false) {
		if (JuggList["2"].len() > 0 && JuggList["3"].len() == 0) {
			JuggRunning <- true;

			local picked = []
			local amount = 1
			if (JuggList["2"].len() >= Config["JuggRatio"]) {
				amount = ((JuggList["2"].len()/Config["JuggRatio"]).tointeger())
			}
			local searched = JuggList["2"]
			for (local j = 0; j < amount ; j++)
			{
			local slot = rand();
			slot = slot % searched.len();
			picked.append(searched[slot])
			searched.remove(slot)
			}

			foreach (i in picked) {
			i.GetScriptScope().teamlock <- 5
			i.ForceChangeTeam(3,true)
			i.ForceRespawn()
			TextWrapSend(i, 3, (smpref+"\x07FC0324YOU ARE JUGGERNAUT!"))
			// printl("pick new1")
			i.GetScriptScope().juggkills <- 0
			}

			foreach (i in JuggList["2"])
			{
				i.ForceRespawn()
				i.GetScriptScope().juggkills <- 0
				TextWrapSend(i, 3, (smpref+"\x07FC0324JUGGERNAUT BEGINS\x01, player/s: "))
				foreach (g in picked) {
					TextWrapSend(i, 3, (::GetColouredName(g)))
				}
			}


		}
	}

	if(JuggRunning) {
		if (JuggList["3"].len() == 0)
		{
		JuggRunning <- false;

		local playlist = []
		foreach (i in JuggList["2"]) {
			playlist.append(i)
		}
		foreach (i in JuggList["3"]) {
			playlist.append(i)
		}

		foreach (i in playlist)
		{
			i.GetScriptScope().teamlock <- 5
			TextWrapSend(i, 3, (smpref+"NEW JUGG!"))
			i.ForceChangeTeam(2,true)
			i.ForceRespawn()
		}
	RunWithDelay(0, function(){CustomGameLogic()})
	}
	else {
		local topjugg = 0
		local topplay = 0
		local playlist = []
		foreach (i in JuggList["2"]) {
			playlist.append(i)
			if (i.GetScriptScope().juggkills > topplay) {
				topplay = i.GetScriptScope().juggkills
			}
		}
		foreach (i in JuggList["3"]) {
			if (i.GetScriptScope().juggkills > topjugg) {
				topjugg = i.GetScriptScope().juggkills
			if (i.GetScriptScope().juggkills > topplay) {
				topplay = i.GetScriptScope().juggkills
			}
			}
			playlist.append(i)
		}

		foreach (i in playlist) {
			// ::ShowTextScore(i, ("You:"+i.GetScriptScope().juggkills+"\nJugg:"+topjugg+" \nTop:"+topplay+"\nof:"+(2*Config["JuggRatio"])))
			ShowAnyText(i, ("You:"+i.GetScriptScope().juggkills+"\nJugg:"+topjugg+" \nTop:"+topplay+"\nof:"+(2*Config["JuggRatio"])), score_ent)
		}
	}

	foreach (jugg in JuggList["3"]) {
	if (jugg.GetScriptScope().juggkills >= (2*Config["JuggRatio"]))
	{
		JuggRunning <- false;

		local playlist = []
		foreach (i in JuggList["2"]) {
			playlist.append(i)
		}
		foreach (i in JuggList["3"]) {
			playlist.append(i)
		}

		foreach (i in playlist)
		{
			i.GetScriptScope().teamlock <- 5
			TextWrapSend(i, 3, (smpref+GetColouredName(jugg)+" has won as Juggernaut!"))
			i.ForceChangeTeam(2,true)
			i.ForceRespawn()
		}
	RunWithDelay(0, function(){CustomGameLogic()})
	}
	}
	}


	//INFECTION logic
	if (InfRunning == false) {
		if (InfList["2"].len() >= Config["InfRatio"]) {
			InfRunning <- true;
			::InfLives <- (1 * Config["InfRatio"].tointeger())

			local picked = []
			local amount = ((InfList["2"].len()/Config["InfRatio"]).tointeger())
			local searched = InfList["2"]
			for (local j = 0; j < amount ; j++)
			{
			local slot = rand();
			slot = slot % searched.len();
			picked.append(searched[slot])
			searched.remove(slot)
			}

			foreach (i in picked) {
			i.GetScriptScope().teamlock <- 5
			i.ForceChangeTeam(3,true)
			i.ForceRespawn()
			TextWrapSend(i, 3, (smpref+"\x070C9143INFECTION BEGINS\x01, \x07FC0324WITH YOU!"))
			}

			foreach (i in InfList["2"])
			{
				i.ForceRespawn()
				TextWrapSend(i, 3, (smpref+"\x070C9143INFECTION BEGINS\x01, player/s: "))
				TextWrapSend(i, 4, (""))
				foreach (g in picked) {
					TextWrapSend(i, 3, (::GetColouredName(g)))
				}
			}


		}
		else {
			foreach (i in InfList["2"]) {
			// ::ShowTextScore(i, (InfList["2"].len()+"/"+Config["InfRatio"]+" players"))
			ShowAnyText(i, (InfList["2"].len()+"/"+Config["InfRatio"]+" players"), score_ent)
			}
		}
	}
	else {
			foreach (i in InfList["2"])
			{
				// ::ShowTextScore(i, ("Zomb Lives: "+::InfLives+"/"+(1*Config["InfRatio"])))
				ShowAnyText(i, ("Zomb Lives: "+::InfLives+"/"+(1*Config["InfRatio"])), score_ent)
			}
			foreach (i in InfList["3"])
			{
				// ::ShowTextScore(i, ("Zomb Lives: "+::InfLives+"/"+(1*Config["InfRatio"])))
				ShowAnyText(i, ("Zomb Lives: "+::InfLives+"/"+(1*Config["InfRatio"])), score_ent)
			}

	}
	if (InfRunning) {
	if(InfList["2"].len() == 0 || InfList["3"].len() == 0) {
		InfRunning <- false;

		local playlist = []
		foreach (i in InfList["2"]) {
			playlist.append(i)
		}
		foreach (i in InfList["3"]) {
			playlist.append(i)
		}

		foreach (i in playlist)
		{
			i.GetScriptScope().teamlock <- 5
			TextWrapSend(i, 3, (smpref+"\x070C9143INFECTED WIN!"))
			i.ForceChangeTeam(2,true)
			i.ForceRespawn()
		}
	RunWithDelay(0, function(){CustomGameLogic()})
	}
	if (::InfLives < 1) {
		InfRunning <- false;

		local playlist = []
		foreach (i in InfList["2"]) {
			playlist.append(i)
		}
		foreach (i in InfList["3"]) {
			playlist.append(i)
		}

		foreach (i in playlist)
		{
			i.GetScriptScope().teamlock <- 5
			TextWrapSend(i, 3, (smpref+"\x07C98C16SURVIVORS WIN!"))
			i.ForceChangeTeam(2,true)
			i.ForceRespawn()
		}
	RunWithDelay(0, function(){CustomGameLogic()})
	}
}


local testtab = this
foreach (key, value in getstackinfos(1)["locals"]){

testtab.rawset(key, value)
}
local compiledscript=compilestring(::PluginsConf["PostFuncs"]["CustomGameLogic"]);
//Run plugin support functions
compiledscript.bindenv(testtab)
compiledscript();
}


::RunWithDelay <- function(delay, func, ...)
{
    local scope = null;
    local params = vargv;
    if (func.getinfos().parameters.len() - 1 < vargv.len())
        scope = vargv.pop();

    if (scope == null)
        scope = this;
    else if (scope && "IsValid" in scope && scope.IsValid())
    {
        scope.ValidateScriptScope();
        scope = scope.GetScriptScope();
    }
    local scoperef = [scope.weakref()];
    local tmpEnt = Entities.CreateByClassname("point_template");
    local name = tmpEnt.GetScriptId();
    local code = format("delays.%s[0]()", name);
    delays[name] <- [function()
    {
        local scope = (delete delays[name])[1][0];
        if (!scope || ("self" in scope && (!scope.self || !scope.self.IsValid())))
            return;
        func.acall([scope].extend(params));
    }, scoperef];
    NetProps.SetPropBool(tmpEnt, "m_bForcePurgeFixedupStrings", true);
    NetProps.SetPropString(tmpEnt, "m_iName", code);
    EntFireByHandle(main_script_entity, "RunScriptCode", code, delay, null, null);
    EntFireByHandle(tmpEnt, "Kill", null, delay, null, null)
}




::PerSecond <- function()
{



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["PerSecond"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

	//Timed message checker
	if (Time() > ::NextChatMsg) {
		TextWrapSend(null,3, timedmsg)
		::NextChatMsg <- (Time() + 300)
	}

	//For all players run update weapons and invite checks
	for (local i = 1; i <= MaxPlayers ; i++)
	{
		local player = PlayerInstanceFromIndex(i);
		if (!player || !player.IsPlayer())
		{
			continue;
		}
		if (!player.GetScriptScope().inMga)
			continue;
        if ((player.GetTeam() == Constants.ETFTeam.TF_TEAM_RED || player.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE))
			{UpdateWeapons(player);}


		if (!("invite" in player.GetScriptScope()))
			{player.GetScriptScope().invite <- null}
        if (player.GetScriptScope().invite[0] != null)
        {
            if (Time() > player.GetScriptScope().invite[1]) {
				local arenapop = CheckArenaPop(player.GetScriptScope().invite[0])
                if (arenapop[0] == 1) {
                    arenapop[1].GetScriptScope().invited <- false
                    TextWrapSend(arenapop[1], 3, (smpref+"Outbound invite expired"))
                }
                player.GetScriptScope().invite <- [null, null]
                TextWrapSend(player, 3, (smpref+"Pending invite expired"))

            }
        }

	}

	//Delete banned items
	for (local item; item = Entities.FindByClassname(item, "tf_wearable");)
	{
		local itemIndex = NetProps.GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
		if (itemIndex != 444) // mantreads
			continue;

		item.AddAttribute("damage force reduction", 1, -1);
		item.AddAttribute("airblast vulnerability multiplier", 1, -1);
		item.AddAttribute("boots falling stomp", 0, -1);
		item.AddAttribute("mod_air_control_blast_jump", 1, -1);
	}

	//Run custom game logic once per second
	//===================================NOTE===================================
	//You can run this whenever you like, eg on player deaths or on kills, or on scores reaching a certain values
	//This is an easy way to speed up custom game checks and rounds, just BEWARE this affects all custom game functions
	CustomGameLogic();



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["PerSecond"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	return 1; // return after a second
}



//find spawn entities and allocate to the correct tables
local slot = null
local spawn = null
while(spawn = Entities.FindByName(spawn, "V_*")) {
        local i = spawn.GetName()
        local val = split(i, "_")
        local Spawntab = (SpawnTypes[val[1]])
        if (val[3] in Spawntab == false) {
        Spawntab.rawset(val[3], array(2))
        }
        switch(val[2]){
            case "B":
                slot = 0
                break
            case "R":
                slot = 1
                break
        }
        if (Spawntab[val[3]][slot] == null){Spawntab[val[3]][slot] =[]}
        if (val[3] != "bot") {
        Spawntab[val[3]][slot] = Spawntab[val[3]][slot].append(spawn)
        }
        else {
            if (Spawntab[val[3]][slot].len() < val[4].tointeger()) {
            Spawntab[val[3]][slot].resize(val[4].tointeger(),null)}
            Spawntab[val[3]][slot][val[4].tointeger()-1] = spawn
        }
}

//Append arenas and duel arenas to the correct globals
foreach (key, value in ::DSpawntab){
	if (Config["BannedDarenas"].find(key) == null) {
		AvailableD.append(key)
	}
}

foreach (key, value in ::DISpawntab){
	if (Config["BannedDarenas"].find(key) == null) {
		AvailableD.append(key)
	}
}

foreach (key, value in ::ASpawntab){
	if ((Config["BannedArenas"].find(key) == null)&&(key.slice(0,1) != ("."))){
		AvailableA.append(key)
	}
}

if (AvailableA.len() == 0) {AvailableA.append("default")}


AvailableA.sort()
AvailableD.sort()


//disable lobby and training bots if they have no spawns
if (!("bspawn" in SpawnTypes["L"])) {
	Config["LobbyBot"] <- false
}

if (!("bot" in SpawnTypes["T"])) {
	Config["TrainingAllowed"] <- false
}



::CheckMeleeSmack <- function()
{
	try {
	local owner = self.GetOwner()



	// when melee smacks, m_iNextMeleeCrit is 0
	if (NetProps.GetPropInt(owner, "m_Shared.m_iNextMeleeCrit") == 0)
	{
		// when switching away from melee, m_iNextMeleeCrit will also be 0 so check for that case
		if (owner.GetActiveWeapon() == self)
		{
			//Run melee swing trace to check if hit teammate and if so then check for enemies needing a hit
			SwingTrace(owner)
		}

		// continue smack detection
		NetProps.SetPropInt(owner, "m_Shared.m_iNextMeleeCrit", -2)
	}

	return -1
} catch(exception) {return}
}


::OnPlayerVoiceline <- function(player, scene)
{

    local name = NetProps.GetPropString(scene, "m_szInstanceFilename")

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["OnPlayerVoiceline"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	//If pain then cancel all pain sounds
    if (endswith(escape(name), "Soldier/low/1165.vcd") ||
	endswith(escape(name), "Soldier/low/1166.vcd") ||
	endswith(escape(name), "Soldier/low/1167.vcd") ||
	endswith(escape(name), "Soldier/low/1371.vcd") ||
	endswith(escape(name), "Soldier/low/1372.vcd") ||
	endswith(escape(name), "Soldier/low/1373.vcd"))
    {
		EntFireByHandle(player, "CallScriptFunction", "PainStop", 0.01, null, null);
	}

	//If practice mode then check for voicelines to use commands
	if (Config["Jpractice"]){

    local playerScope = player.GetScriptScope();
    if (playerScope == null)
        return;






    if (endswith(escape(name), "Soldier/low/1139.vcd") || endswith(escape(name), "Soldier/low/1140.vcd") || endswith(escape(name), "Soldier/low/1141.vcd"))
    {
		if (player.GetScriptScope().practicepos["pos"] != null) {
			player.Teleport(true, player.GetScriptScope().practicepos["pos"],
			true, player.GetScriptScope().practicepos["eye"]
			true, Vector());
		}
			player.SetHealth(200)
			TextWrapSend(player, 4, ("RESET/REGEN"))
			player.Regenerate(true);
	}
    if (endswith(escape(name), "Soldier/low/1092.vcd") || endswith(escape(name), "Soldier/low/1093.vcd") || endswith(escape(name), "Soldier/low/1094.vcd"))
    {
		SendGlobalGameEvent("player_say",
		{
			userid = GetPlayerUserID(player)
			priority = 1
			text = (Config["Prefix1"]+"clearpos")
		})
	}
    if (endswith(escape(name), "Soldier/low/1150.vcd"))
    {
		SendGlobalGameEvent("player_say",
		{
			userid = GetPlayerUserID(player)
			priority = 1
			text = (Config["Prefix1"]+"startpos")
		})
	}
    if (endswith(escape(name), "Soldier/low/1148.vcd"))
    {
		SendGlobalGameEvent("player_say",
		{
			userid = GetPlayerUserID(player)
			priority = 1
			text = (Config["Prefix1"]+"dummy default2")
		})
	}
    if (endswith(escape(name), "Soldier/low/1146.vcd"))
    {
		SendGlobalGameEvent("player_say",
		{
			userid = GetPlayerUserID(player)
			priority = 1
			text = (Config["Prefix1"]+"dummy default1")
		})
	}
	}

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["OnPlayerVoiceline"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


}



::SwingTrace <- function(player) {
    local eyePosition = player.EyePosition()
    local eyeAngles = player.EyeAngles()
    local trace = {
        start = eyePosition
        end = eyePosition + eyeAngles.Forward() * 48
        mask = ::PlayerTraceMask // MASK_SOLID
        ignore = player
    }
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["SwingTrace"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();



	//Trace melee path to see if hit teammate
    TraceLineEx(trace)
    if (!trace.hit) {
        trace.hullmin <- Vector(-18, -18, -18)
        trace.hullmax <- Vector(18, 18, 18)
        TraceHull(trace)
    }
	// if hit player of the same team
    if (("enthit" in trace) && trace.enthit.IsPlayer() != false && trace.enthit.GetTeam() == player.GetTeam()) {

		//Create array and add all players within 300 units to the array
		//For each player set them to not be solid to the next trace function
		local skipdplayers = []
		for (local skip; skip = Entities.FindByClassnameWithin(skip, "player", eyePosition, 300);)
		{
			if (skip.GetTeam() == player.GetTeam()) {
			skipdplayers.append(skip)
			skip.SetSolid(0)
			}
		}

    local trace2 = {
        start = eyePosition
        end = eyePosition + eyeAngles.Forward() * 48
        mask = ::PlayerTraceMask // MASK_SOLID
        ignore = player
    }

	//Begin second melee trace that can no longer hit any nearby teammates
    TraceLineEx(trace2)
    if (!trace2.hit) {
        trace2.hullmin <- Vector(-18, -18, -18)
        trace2.hullmax <- Vector(18, 18, 18)
        TraceHull(trace2)
    }

	//Make all teammates in the array solid again
	foreach (skip in skipdplayers) {skip.SetSolid(2)}


	//If hit an enemy
    if (("enthit" in trace2) && trace2.enthit.IsPlayer() != false && trace2.enthit.GetTeam() != player.GetTeam()) {

		//Fetch melee weapon
		local melee = null
		for (local i = 0; i < 8; i++)
		{
			local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
			if (weapon == null || !weapon.IsMeleeWeapon())
				continue

			melee = weapon
			break
		}

		//Make enemy take damage from the found melee weapon
		trace2.enthit.TakeDamageCustom(player,player, melee, Vector(), eyePosition, 65, 134221952, 0)
	}

	}

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["SwingTrace"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

return null;

}


//NEW FUNCS
::CustomGameDeath <- function(deadp, killp)
{



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["CustomGameDeath"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

	if ("arena" in deadp.GetScriptScope()) {
	if (CustomsList["inf"].find(deadp.GetScriptScope().arena[1]) != null) {
		if (killp.GetTeam() == 3) {
			deadp.GetScriptScope().respawninfo.rawset("pos",deadp.GetOrigin())
			deadp.GetScriptScope().respawninfo.rawset("eye",deadp.EyeAngles())
			deadp.GetScriptScope().respawninfo.rawset("vel",deadp.GetAbsVelocity())
			deadp.GetScriptScope().respawninfo.rawset("swap",true)
			deadp.GetScriptScope().respawninfo["crit"] <- deadp.GetScriptScope().lastCrit
			PlayerStuckPrevent(deadp)
			::InfLives <- ::InfLives + 2
			if (::InfLives > 1 * Config["InfRatio"]) {
				::InfLives <- (1 * Config["InfRatio"])
			}
		}
		if (killp.GetTeam() == 2) {
			::InfLives <- ::InfLives -1
		}

	}

	if (CustomsList["jugg"].find(deadp.GetScriptScope().arena[1]) != null) {
		if (killp.GetTeam() == 2) {
		killp.GetScriptScope().teamlock <- 5
		ForceSwapTeam(killp)

		TextWrapSend(killp, 3, (smpref+"\x07FC0324YOU ARE JUGGERNAUT!"))
		PlayerStuckPrevent(killp)
		// printl("pick new2")
		deadp.GetScriptScope().teamlock <- 5
		killp.AddCondEx(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF, 1.0, null);
		ForceSwapTeam(deadp)
		}
		if (killp.GetTeam() == 3) {
			killp.GetScriptScope().juggkills <- killp.GetScriptScope().juggkills + 1
		}
	}

	if (CustomsList["freeze"].find(deadp.GetScriptScope().arena[1]) != null && killp.GetTeam() != deadp.GetTeam()) {
		deadp.GetScriptScope().respawninfo.rawset("pos",deadp.GetOrigin())
		deadp.GetScriptScope().respawninfo.rawset("eye",deadp.EyeAngles())
		deadp.GetScriptScope().respawninfo.rawset("vel",deadp.GetAbsVelocity())
		deadp.GetScriptScope().respawninfo.rawset("swap",null)
		deadp.GetScriptScope().respawninfo["crit"] <- deadp.GetScriptScope().lastCrit
	}
	}



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["CustomGameDeath"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

}

::DummyDeathCheck <- function(deadp)
{


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["DummyDeathCheck"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

	if ((NetProps.GetPropString(deadp, "m_szNetname") == "BDummy") || (NetProps.GetPropString(deadp, "m_szNetname") == "RDummy"))
	{
		deadp.GetScriptScope().tspawn <- (deadp.GetScriptScope().tspawn +1)
		if (deadp.GetScriptScope().tspawn >= TSpawntab["bot"][-1*deadp.GetTeam()+3].len()) {deadp.GetScriptScope().tspawn <- 0}
	}


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["DummyDeathCheck"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

}

::KillInfoSend <- function(deadp,killp)
{


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["KillInfoSend"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

	if (deadp.GetScriptScope().killinfo == true)
	{
		TextWrapSend(deadp, 3, (smpref+"You died with: V:\x07FFFF00"+deadp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+deadp.GetScriptScope().hopnum+"\x01\n"+smpref+"Opponent had: V:\x07FFFF00"+killp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+killp.GetScriptScope().hopnum))
	}
	if (killp.GetScriptScope().killinfo == true)
	{
		TextWrapSend(killp, 3, (smpref+"Got a kill with: V:\x07FFFF00"+killp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+killp.GetScriptScope().hopnum+"\x01\n"+smpref+"Opponent had: V:\x07FFFF00"+deadp.GetScriptScope().lvel+"\x01 B:\x07FFFF00"+deadp.GetScriptScope().hopnum))
	}



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["KillInfoSend"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();
}

::DuelDeath <- function(killp, deadp)
{



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["DuelDeath"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

	if (killp.GetScriptScope().arena[0] == "D"|| killp.GetScriptScope().arena[0] == "DI") {
		if (killp.GetScriptScope().arena[1] != deadp.GetScriptScope().arena[1]) {return;}

		local arenapopN = CheckArenaPop(killp.GetScriptScope().arena[1])
		local arenapop1 = arenapopN[1]
		local arenapop2 = arenapopN[2]



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


			if (killp.GetScriptScope().dtype != "bhop") {
			ScoreTextWrapSend(deadp, 3, (smpref+"You: "+deadp.GetScriptScope().score+", "+::GetColouredName(killp)+": "+killp.GetScriptScope().score))
			ScoreTextWrapSend(killp, 3, (smpref+"You: "+killp.GetScriptScope().score+", "+::GetColouredName(deadp)+": "+deadp.GetScriptScope().score))}
			else {
			ScoreTextWrapSend(deadp, 3, (smpref+"You: "+deadp.GetScriptScope().score+", "+::GetColouredName(killp)+": "+killp.GetScriptScope().score + " "+combocheck(killp.GetScriptScope().hopnum)))
			ScoreTextWrapSend(killp, 3, (smpref+"You: "+killp.GetScriptScope().score+", "+::GetColouredName(deadp)+": "+deadp.GetScriptScope().score + " "+combocheck(killp.GetScriptScope().hopnum)))
			}


			if (killp.GetScriptScope().score >= 10 && killp.GetScriptScope().dtype == "ft10") {
				TextWrapSend(null, 3, (smpref+(killp.GetScriptScope().arena[1])+" t:\x07FFFF00"+killp.GetScriptScope().dtype+"\x01 "+::GetColouredName(killp)+" won against "+::GetColouredName(deadp)+" ("+killp.GetScriptScope().score+("/")+deadp.GetScriptScope().score+")"))

				DuelWon(killp, deadp, killp.GetScriptScope().score, deadp.GetScriptScope().score, killp.GetScriptScope().arena[1], killp.GetScriptScope().dtype)

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
		if (killp.GetScriptScope().score >= 25 && (killp.GetScriptScope().dtype == "bhop" || killp.GetScriptScope().dtype == "vel")) {
			TextWrapSend(null, 3, (smpref+(killp.GetScriptScope().arena[1])+" t:\x07FFFF00"+killp.GetScriptScope().dtype+"\x01 "+::GetColouredName(killp)+" won against "+::GetColouredName(deadp)+" ("+killp.GetScriptScope().score+("/")+deadp.GetScriptScope().score+")"))

			DuelWon(killp, deadp, killp.GetScriptScope().score, deadp.GetScriptScope().score, killp.GetScriptScope().arena[1], killp.GetScriptScope().dtype)

			killp.GetScriptScope().inMga <- true;
			killp.GetScriptScope().arena <- ["L","lobby"];
			killp.ForceRegenerateAndRespawn();
			killp.GetScriptScope().score <- 0

			deadp.GetScriptScope().inMga <- true;
			deadp.GetScriptScope().arena <- ["L","lobby"];
			deadp.ForceRegenerateAndRespawn();
			deadp.GetScriptScope().score <- 0

		}

		if (killp.GetScriptScope().dtype == "dom") {
			killp.GetScriptScope().score <- (killp.GetScriptScope().score + 1)
			if (killp.GetScriptScope().restarts != 0)
			{
				if (deadp.GetScriptScope().score > 0 ) {
				deadp.GetScriptScope().score <- 0
				killp.GetScriptScope().restarts <- killp.GetScriptScope().restarts -1
				deadp.GetScriptScope().restarts <- deadp.GetScriptScope().restarts - 1
				if (killp.GetScriptScope().restarts == 0) {killp.GetScriptScope().score <- 0}
				TextWrapSend(deadp, 3, smpref+"score restarted")
				TextWrapSend(killp, 3, smpref+"restarted opponent")}
			}
			ScoreTextWrapSend(deadp, 3, (smpref+"You: "+deadp.GetScriptScope().score+", "+::GetColouredName(killp)+": "+killp.GetScriptScope().score+" r:("+(killp.GetScriptScope().restarts)+"/4)"))
			ScoreTextWrapSend(killp, 3, (smpref+"You: "+killp.GetScriptScope().score+", "+::GetColouredName(deadp)+": "+deadp.GetScriptScope().score+" r:("+(killp.GetScriptScope().restarts)+"/4)"))
			if (killp.GetScriptScope().score == 4) {
				TextWrapSend(null, 3, (smpref+(killp.GetScriptScope().arena[1])+" t:\x07FFFF00"+killp.GetScriptScope().dtype+"\x01 "+::GetColouredName(killp)+" won against "+::GetColouredName(deadp)+" ("+killp.GetScriptScope().score+("/")+deadp.GetScriptScope().score+")"+" r:("+(killp.GetScriptScope().restarts)+"/4)"))

				DuelWon(killp, deadp, killp.GetScriptScope().score, deadp.GetScriptScope().score, killp.GetScriptScope().arena[1], killp.GetScriptScope().dtype, true, (4 - killp.GetScriptScope().restarts))

				killp.GetScriptScope().inMga <- true;
				killp.GetScriptScope().arena <- ["L","lobby"];
				killp.ForceRegenerateAndRespawn();
				killp.GetScriptScope().score <- 0
				killp.GetScriptScope().restarts <- 4

				deadp.GetScriptScope().inMga <- true;
				deadp.GetScriptScope().arena <- ["L","lobby"];
				deadp.ForceRegenerateAndRespawn();
				deadp.GetScriptScope().score <- 0
				deadp.GetScriptScope().restarts <- 4
			}

		}
	dScoreCheck(killp.GetScriptScope().arena[1], killp, true)
	SpecDuelMsg(deadp.GetScriptScope().arena[1], deadp, killp, deadp.GetScriptScope().dtype, arenapop1, arenapop1)
	}



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["DuelDeath"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

}

::CustomGameSuicide <- function(deadp)
{
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["CustomGameSuicide"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	if (CustomsList["inf"].find(deadp.GetScriptScope().arena[1]) != null && deadp.GetTeam() == 2) {
		deadp.GetScriptScope().teamlock <- 5
		ForceSwapTeam(deadp)
	}

	if (CustomsList["jugg"].find(deadp.GetScriptScope().arena[1]) != null && deadp.GetTeam() == 3 && deadp.GetScriptScope().teamlock == 3) {
		deadp.GetScriptScope().teamlock <- 5
		EntFireByHandle(deadp, "CallScriptFunction", "TChangePreventR", 0, null, null);

		local picked = []
		local searched = JuggList["2"]
		for (local j = 0; j < 1 ; j++)
		{
		local slot = rand();
		slot = slot % searched.len();
		picked.append(searched[slot])
		searched.remove(slot)
		}

		foreach (i in picked) {
		i.GetScriptScope().teamlock <- 5
		i.ForceChangeTeam(3,true)
		i.ForceRespawn()
		TextWrapSend(i, 3, (smpref+"\x07FC0324YOU ARE JUGGERNAUT!"))
		i.GetScriptScope().juggkills <- 0
		}

	}

	if (CustomsList["freeze"].find(deadp.GetScriptScope().arena[1]) != null) {
		deadp.GetScriptScope().respawninfo.rawset("pos",deadp.GetOrigin())
		deadp.GetScriptScope().respawninfo.rawset("eye",deadp.EyeAngles())
		deadp.GetScriptScope().respawninfo.rawset("vel",deadp.GetAbsVelocity())
		deadp.GetScriptScope().respawninfo.rawset("swap",null)
		deadp.GetScriptScope().respawninfo.rawset("freeze",true)
	}

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["CustomGameSuicide"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

}

::DuelInstSpawn <- function(killp)
{
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["DuelInstSpawn"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	if (killp.GetScriptScope().arena[0] == "DI") {
		EntFireByHandle(killp, "CallScriptFunction", "InstaSpawn", 0.02, null, null);
	}



	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["DuelInstSpawn"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();

}

::MgaInstSpawn <- function(deadp)
{


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["MgaInstSpawn"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	EntFireByHandle(deadp, "CallScriptFunction", "InstaSpawn", 0.02, null, null);


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["MgaInstSpawn"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


}


::CustomGameTeamSwitch <- function(player, parteam)
{
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["CustomGameTeamSwitch"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	if (parteam == 0 || parteam == 1) {
		player.GetScriptScope().teamlock <- 0

	if (CustomsList["all"].find(player.GetScriptScope().arena[1]) == null) {return}


	local list = null
	foreach(key, value in CustomsList) {
		if (key == "all") {continue}
		if (value.find(player.GetScriptScope().arena[1]) != null) {
			list = CustomListMatchip[key]
		}
	}

	if (list[player.GetTeam().tostring()].find(player) != null) {
		list[player.GetTeam().tostring()].remove(list[player.GetTeam().tostring()].find(player))}
}


local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["CustomGameTeamSwitch"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


}


::TeamLockManage <- function(player, parteam, params)
{

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["TeamLockManage"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	if (player.GetScriptScope().teamlock == 0) {return}


	if (player.GetScriptScope().teamlock == 3 && params.oldteam == 3)
	{

	if (CustomsList["jugg"].find(player.GetScriptScope().arena[1]) != null) {
		player.GetScriptScope().teamlock <- 5
		EntFireByHandle(player, "CallScriptFunction", "TChangePreventR", 0, null, null);

		local picked = []
		local searched = JuggList["2"]
		for (local j = 0; j < 1 ; j++)
		{
		local slot = rand();
		slot = slot % searched.len();
		picked.append(searched[slot])
		searched.remove(slot)
		}

		foreach (i in picked) {
		i.GetScriptScope().teamlock <- 5
		i.ForceChangeTeam(3,true)
		i.ForceRespawn()
		TextWrapSend(i, 3, (smpref+"\x07FC0324YOU ARE JUGGERNAUT!"))
		i.GetScriptScope().juggkills <- 0
		}

	}
	else
	{EntFireByHandle(player, "CallScriptFunction", "TChangePreventB", 0, null, null);}

}

	if (player.GetScriptScope().teamlock == 2 && params.oldteam == 2)
	{EntFireByHandle(player, "CallScriptFunction", "TChangePreventR", 0, null, null);}

	if (player.GetScriptScope().teamlock == 5) {
		player.GetScriptScope().teamlock <- parteam

	local list = null
	foreach(key, value in CustomsList) {
		if (key == "all") {continue}
		if (value.find(player.GetScriptScope().arena[1]) != null) {
			list = CustomListMatchip[key]
		}
	}

	if (parteam == 3 && (list["2"].find(player) != null)) {
	list["2"].remove(list["2"].find(player))

	}
	if (parteam == 2 && (list["3"].find(player) != null)) {
	list["3"].remove(list["3"].find(player))
	}
	list[parteam.tostring()].append(player)
	}

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["TeamLockManage"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();



}


::CustomGameDisconnect <- function(player)
{

	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["CustomGameDisconnect"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	if (!("arena" in player.GetScriptScope())) {return}
	if (CustomsList["all"].find(player.GetScriptScope().arena[1]) == null) {return}

	local list = null
	foreach(key, value in CustomsList) {
		if (key == "all") {continue}
		if (value.find(player.GetScriptScope().arena[1]) != null) {
			list = CustomListMatchip[key]
		}
	}

	if (list[player.GetTeam().tostring()].find(player) != null) {
		list[player.GetTeam().tostring()].remove(list[player.GetTeam().tostring()].find(player))}


		local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["CustomGameDisconnect"]);
		//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


}


::MgaDamageManage <- function(ent, inflictor, weapon, attacker, params)
{


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["MgaDamageManage"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	if (attacker.GetClassname() == "trigger_hurt") {return}


	if ((Config["Jpractice"] == false || ent.GetScriptScope().practiceheal) && params.damage_type == Constants.FDmgType.DMG_FALL) {params.damage = 0}

	if ((params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_PLASMA_CHARGED) ||
		(attacker && attacker.IsPlayer() && (PluginsConf["ClassRestrict"] != false && attacker.GetPlayerClass() != PluginsConf["ClassRestrict"])) ||
		(weapon && (PluginsConf["ClassRestrict"] == Constants.ETFClass.TF_CLASS_SOLDIER && weapon.GetSlot() && weapon.GetSlot() == 1)) ||
		(params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_TAUNTATK_GRENADE && ent != attacker))
	{
		params.damage = 0;
	}
	else if ((weapon && weapon.IsMeleeWeapon && weapon.IsMeleeWeapon()) &&
		(attacker && attacker.IsPlayer() && attacker.GetScriptScope().canCrit) && attacker != ent)
	{
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
			params.damage = 65;
			params.damage_type = 1048576;
			ent.SetHealth(195)
	}
	else if (inflictor.GetClassname() == "tf_projectile_rocket" || inflictor.GetClassname() == "tf_projectile_energy_ball")
	{
		NetProps.SetPropBool(inflictor, "m_bForcePurgeFixedupStrings", true)
		EntFireByHandle(ent, "CallScriptFunction", "PostRocketHit", 0.015, null, null);
	}

	if (ent.GetScriptScope().jugg && attacker != ent && params.damage_type != 1048576 && params.damage != 0) {
		params.damage = 1
	}

	if (Config["Jpractice"] && params.damage >= ent.GetHealth() && ent == attacker)
	{
		TextWrapSend(ent, 4, ("DIED"))
		ent.SetHealth(200)
		params.damage = 0;
	}


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["MgaDamageManage"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();



}


::Bhopped <- function()
{
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["Bhopped"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["Bhopped"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


}


::DuelWon <- function(p1,p2,s1,s2,a,t,dom = false, r = 0)
{
	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PreFuncs"]["DuelWon"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


	local testtab = this
	foreach (key, value in getstackinfos(1)["locals"]){

	testtab.rawset(key, value)
	}
	local compiledscript=compilestring(::PluginsConf["PostFuncs"]["DuelWon"]);
//Run plugin support functions
	compiledscript.bindenv(testtab)
	compiledscript();


}